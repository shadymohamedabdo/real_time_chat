import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_chat/auth/register.dart';
import '../Component/Button.dart';
import '../Component/logo.dart';
import '../Component/text.dart';
import '../Component/textForm.dart';
import 'login_controller.dart';
class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.find<LoginController>();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: controller.formLogin,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomLogo(),
                const customText(title: 'Login', fontSize: 25),
                const Text('Login to continue using app',
                    style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 18),
                const customText(title: 'Email', fontSize: 20),
                customTextForm(
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: 'Please enter your email',
                  hintText: 'Enter your email',
                  myController: controller.email,
                ),
                const customText(title: 'Password', fontSize: 18),
                Obx(
                      () => TextFormField(
                    controller: controller.password,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      return null;
                    },
                    obscureText: controller.isPassword.value,
                    maxLength: 25,
                    keyboardType: TextInputType.visiblePassword,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password),
                      suffixIcon: IconButton(
                        onPressed: () =>
                        controller.isPassword.value = !controller.isPassword.value,
                        icon: Icon(controller.isPassword.value
                            ? Icons.remove_red_eye
                            : Icons.visibility_off),
                      ),
                      hintText: 'Enter your password',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: controller.sendPasswordResetEmail,
                    child: const Text(
                      'Forget Password?',
                      style:
                      TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(
                      () => AbsorbPointer(
                    absorbing: controller.isLoading.value,
                    child: customButton(
                      onPressed:

                      controller.signInWithEmailAndPassword,
                      color: Colors.blue,
                      text: controller.isLoading.value ? 'Loading...' : 'Login',
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Obx(() => customButton(
                  onPressed: controller.googleLoading.value
                      ? null
                      : controller.signInWithGoogle,
                  color: Colors.red,
                  text: controller.googleLoading.value
                      ? 'Loading...'
                      : 'Login with Google',
                )),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const customText(title: "Don't have an account?", fontSize: 14),
                    TextButton(
                      onPressed: () {
                        Get.offAll(() => const Register());
                      },
                      child: const Text('Register', style: TextStyle(color: Colors.blue)),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
