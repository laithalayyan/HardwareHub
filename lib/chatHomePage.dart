import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chatPage.dart';
import 'chat_service.dart';
import 'common/widgets/appbar/appbar.dart';

class ChatHomePage extends StatelessWidget {
  final String currentUserUsername;

  const ChatHomePage({super.key, required this.currentUserUsername});

  @override
  Widget build(BuildContext context) {
    final ChatService chatService = ChatService();
    return Scaffold(
      appBar: const TAppBar(title: Text('Messages'), showBackArrow: true,),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('participants', arrayContains: currentUserUsername)
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final chats = snapshot.data!.docs;

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final participants = chat['participants'] as List<dynamic>;
              final lastMessage = chat['lastMessage'] ?? '';
              final timestamp = chat['timestamp'] != null
                  ? (chat['timestamp'] as Timestamp).toDate()
                  : null;
              // final otherUser = participants.firstWhere(
              //         (participant) => participant != currentUserUsername);
              final otherUser = participants.isNotEmpty
                  ? participants.firstWhere(
                    (participant) => participant != currentUserUsername,
                orElse: () => 'Unknown', // Fallback value if no participant is found
              )
                  : 'Unknown'; // Fallback value if the list is empty


              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .doc(chat.id)
                    .collection('messages')
                    //.where('readBy', arrayContains: currentUserUsername)
                    .snapshots(),
                builder: (context, messagesSnapshot) {
                  if (!messagesSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final unreadMessagesCount = messagesSnapshot.data!.docs
                      .where((message) => !message['readBy'].contains(currentUserUsername))
                      .length;

                  return ListTile(
                    leading: Stack(
                      children: [
                        CircleAvatar(child: Text(otherUser[0].toUpperCase())),
                        if (unreadMessagesCount > 0)
                          Positioned(
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$unreadMessagesCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    title: Text(otherUser),
                    subtitle: Text(lastMessage),
                    trailing: Text(timestamp != null
                        ? "${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}"
                        : ''),
                    onTap: () async {
                      await chatService.markMessagesAsRead(chat.id, currentUserUsername);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChatScreen(
                                  chatId: chat.id,
                                  currentUserUsername: currentUserUsername,
                                otherUserUsername: otherUser,),
                        ),
                      );

                      // Mark all messages as read
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(chat.id)
                          .collection('messages')
                          .get()
                          .then((messages) {
                        for (var message in messages.docs) {
                          if (!message['readBy'].contains(currentUserUsername)) {
                            message.reference.update({
                              'readBy': FieldValue.arrayUnion([currentUserUsername]),
                            });
                          }
                        }
                      });
                    },
                  );

                },
              );
            },
          );
        },
      ),
    );
  }
}
