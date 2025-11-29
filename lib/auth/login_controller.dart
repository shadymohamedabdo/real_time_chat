import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../Component/dialog.dart';
import '../user_list_screen.dart';

class LoginController extends GetxController {
  var formLogin = GlobalKey<FormState>();
  var email = TextEditingController();
  var password = TextEditingController();
  RxBool isPassword = true.obs;
  RxBool isLoading = false.obs;
  RxBool googleLoading = false.obs;



  @override
  void onClose() {
    email.dispose();
    password.dispose();
    super.onClose();
  }

  Future<void> signInWithEmailAndPassword() async {
    if (formLogin.currentState == null || !formLogin.currentState!.validate()) {
      customDialog('Error', 'Please enter your email and password');
      return;
    }

    try {
      isLoading.value = true;
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: password.text.trim(),
      );
      Get.offAll(() => UserListScreen());
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        customDialog('Error', 'No user found for that email');
      } else if (e.code == 'wrong-password') {
        customDialog('Error', 'Wrong password');
      } else if (e.code == 'invalid-email') {
        customDialog('Error', 'Email is not valid');
      } else {
        customDialog('Error', e.message ?? 'Something went wrong');
      }
    } catch (e) {
      customDialog('Error', 'Unexpected error: $e');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> signInWithGoogle() async {
    try {
      googleLoading.value = true;
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      Get.offAll(() => UserListScreen());

    } catch (e) {
      customDialog('Error', 'Google Sign-In failed: $e');
    } finally {
      googleLoading.value = false;
    }
  }

  Future<void> sendPasswordResetEmail() async {
    if (email.text.trim().isEmpty) {
      customDialog('Error', 'Please enter your email');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.text.trim());
      customDialog('Warning', 'Check your email to reset your password');
    } catch (e) {
      customDialog('Error', 'This email is unavailable, please register');
    }
  }
}

