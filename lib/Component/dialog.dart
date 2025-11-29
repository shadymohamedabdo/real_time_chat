import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> customDialog(String title, String desc) {
  return showDialog(
    context: Get.context!,
    barrierDismissible: false,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: Text(desc),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: const Text("OK"),
        ),
      ],
    ),
  );
}
