import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_page.dart';
import 'auth/Login.dart';
import 'user_controller.dart';

class UserListScreen extends StatelessWidget {
  UserListScreen({super.key});
  final UserListController userController = Get.find<UserListController>();
  final TextEditingController searchCtrl = TextEditingController();

  /// Avatar + Online/Offline dot
  Widget _avatar(Map<String, dynamic> data) {
    final name = (data['name'] ?? '').trim();
    final initials = name.isEmpty ? '?' : name[0].toUpperCase();
    final isOnline = data['isOnline'] ?? false;

    return Stack(
      children: [
        CircleAvatar(child: Text(initials)),
        if (isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        if (!isOnline)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userController.currentUserId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select User"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Get.offAll(() => Login());
            },
          )
        ],
      ),

      body: Column(
        children: [

          // 🔎 Search
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: searchCtrl,
              onChanged: (v) => userController.search.value = v.toLowerCase(),
              decoration: const InputDecoration(
                hintText: "Search user...",
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),

          // 👥 Users List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userController.loadUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final raw = snapshot.data!.docs;

                // فلترة البحث
                final users = raw.where((doc) {
                  if (doc.id == userController.currentUserId) return false;
                  final name = (doc['name'] as String?)?.toLowerCase() ?? '';
                  return userController.search.isEmpty || name.contains(userController.search.value);
                }).toList();

                if (users.isEmpty) {
                  return const Center(child: Text("No users found"));
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (_, i) {
                    final doc = users[i];
                    final data = doc.data() as Map<String, dynamic>;
                    final otherId = doc.id;

                    final chatId = userController.chatId(userController.currentUserId!, otherId);

                    return StreamBuilder<DocumentSnapshot>(
                      stream: userController.chatStream(chatId),
                      builder: (context, chatSnap) {
                        String lastMsg = "";
                        bool unread = false;

                        if (chatSnap.hasData && chatSnap.data!.exists) {
                          final ch = chatSnap.data!.data() as Map<String, dynamic>;
                          lastMsg = ch["lastMessage"] ?? "";

                          final unreadMap = (ch["unreadFor"] ?? {}) as Map<String, dynamic>;
                          unread = unreadMap[userController.currentUserId] == true;
                        }

                        return ListTile(
                          leading: _avatar(data),
                          title: Text(
                            data['name'] ?? '',
                            style: TextStyle(
                              fontWeight: unread ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                          subtitle: Text(
                            lastMsg.isEmpty ? data['email'] : lastMsg,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Get.to(() => ChatScreen(
                              userId: otherId,
                              userName: data['name'],
                            ))!.then((_) {
                              FirebaseFirestore.instance
                                  .collection('chats')
                                  .doc(chatId)
                                  .set({
                                "unreadFor": {userController.currentUserId!: false}
                              }, SetOptions(merge: true));
                            });
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          )

        ],
      ),
    );
  }
}
