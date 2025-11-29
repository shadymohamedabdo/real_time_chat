import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class UserListController extends GetxController with WidgetsBindingObserver {
  final search = ''.obs;

  String? currentUserId;

  @override
  void onInit() {
    super.onInit();
    currentUserId = FirebaseAuth.instance.currentUser?.uid;
    WidgetsBinding.instance.addObserver(this);
    _setOnline(true); // فوراً Online
  }

  @override
  void onClose() {
    _setOnline(false); // Offline عند إغلاق
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }

  /// مراقبة حالة التطبيق
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (currentUserId == null) return;

    if (state == AppLifecycleState.resumed) {
      _setOnline(true);
    } else if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _setOnline(false);
    }
  }

  Future<void> _setOnline(bool online) async {
    if (currentUserId == null) return;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .set({'isOnline': online}, SetOptions(merge: true));
  }

  // 🔹 باقي الدوال
  Stream<QuerySnapshot> loadUsers() {
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  Stream<DocumentSnapshot> chatStream(String chatId) {
    return FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .snapshots();
  }

  String chatId(String a, String b) {
    return (a.compareTo(b) <= 0) ? "${a}_$b" : "${b}_$a";
  }
}
