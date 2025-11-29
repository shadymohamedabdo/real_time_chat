import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_chat/auth/register_controller.dart';
import '../Component/Button.dart';
import '../Component/logo.dart';
import '../Component/text.dart';
import '../Component/textForm.dart';
import 'login.dart';

class Register extends StatelessWidget {
  const Register({super.key});
  @override
  Widget build(BuildContext context) {
    final RegisterController controller = Get.find<RegisterController>();

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(7.0),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: controller.formRegister,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CustomLogo(),
                const customText(title: 'Sign up', fontSize: 25),
                const Text('Sign up for using app ', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 10),
                const customText(title: 'Username', fontSize: 18),
                customTextForm(
                  prefixIcon: const Icon(Icons.person_add_rounded),
                  validator: 'please Enter your name',
                  hintText: 'Username',
                  myController: controller.username,
                ),
                const customText(title: 'Email', fontSize: 20),
                customTextForm(
                  prefixIcon: const Icon(Icons.email_outlined),
                  validator: 'please Enter your email',
                  hintText: 'Enter your email',
                  myController: controller.email,
                ),
                const customText(title: 'Password', fontSize: 18),
                customTextForm(
                  onFieldSubmitted: (value) async {
                    await controller.signUp();
                  },
                  prefixIcon: const Icon(Icons.password),
                  validator: 'please Enter your password',
                  hintText: 'Enter your password',
                  myController: controller.password,
                ),

                const SizedBox(height: 12),

                // <-- Obx + AbsorbPointer to prevent double taps and show Loading text
                Obx(
                      () => AbsorbPointer(
                    absorbing: controller.isLoading.value,
                    child: customButton(
                      onPressed: controller.signUp,
                      color: Colors.blue,
                      text: controller.isLoading.value ? 'Loading...' : 'Sign Up',
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const customText(title: 'Have an account ?', fontSize: 14),
                    TextButton(
                      onPressed: () {
                        Get.offAll(() => const Login());
                      },
                      child: const Text('Login', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    )
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
