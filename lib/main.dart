import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_chat/auth/Login.dart';
import 'package:real_chat/user_controller.dart';
import 'auth/login_controller.dart';
import 'auth/register_controller.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_list_screen.dart'; // الشاشة اللي تروح لها لو المستخدم مسجل دخول

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => LoginController(), fenix: true);
  Get.lazyPut(() => RegisterController(), fenix: true);
  Get.lazyPut(() => UserListController(), fenix: true);






  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home:  Directionality(
        textDirection: TextDirection.rtl,
        child: AuthWrapper(),),
    );
  }
}

/// ---------------------------
///    AUTH WRAPPER
/// ---------------------------
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // listens to login/logout
      builder: (context, snapshot) {
        // 1) Still loading Firebase / checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2) User is logged in → go to home
        if (snapshot.hasData) {
          return  UserListScreen();
        }

        // 3) User NOT logged in → show login screen
        return Login();
      },
    );
  }
}
