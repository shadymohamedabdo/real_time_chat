import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Component/dialog.dart';
import '../user_list_screen.dart';


class RegisterController extends GetxController {
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController email = TextEditingController();
  final RxBool isLoading = false.obs;

  var formRegister = GlobalKey<FormState>();

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    username.dispose();
    super.onClose();
  }


  Future<void> signUp() async {
    if (formRegister.currentState!.validate()) {
      try {
        isLoading.value = true;

        final userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
          email: email.text.trim(),
          password: password.text.trim(),
        );

        final user = userCredential.user!;

        await user.updateDisplayName(username.text.trim());

        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
          'name': username.text.trim(),
          'email': user.email,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 🚫 مفيش verify
        // 🚫 ومفيش signOut

        await customDialog('Success', 'Account created successfully');

        Get.offAll(() =>  UserListScreen());

      } on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          customDialog('Error', 'Password is too weak');
        } else if (e.code == 'email-already-in-use') {
          customDialog('Error', 'Email already exists');
        }
      } catch (e) {
        customDialog('Error', '$e');
      }
      finally {
        isLoading.value = false;
      }
    }
  }
}