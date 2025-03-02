import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  // Stream to get the total number of unread messages for a user
  Stream<int> getUnreadMessageCountStream(String currentUserUsername) {
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserUsername)
        .snapshots()
        .asyncMap((chatsSnapshot) async {
      int totalUnread = 0;

      for (final chat in chatsSnapshot.docs) {
        final messagesSnapshot = await FirebaseFirestore.instance
            .collection('chats')
            .doc(chat.id)
            .collection('messages')
            .get();

        final unreadMessages = messagesSnapshot.docs
            .where((message) => !message['readBy'].contains(currentUserUsername))
            .length;

        totalUnread += unreadMessages;
      }

      return totalUnread;
    });
  }

  Future<void> markMessagesAsRead(String chatId, String currentUserUsername) async {
    final messagesSnapshot = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    for (final message in messagesSnapshot.docs) {
      if (!message['readBy'].contains(currentUserUsername)) {
        await message.reference.update({
          'readBy': FieldValue.arrayUnion([currentUserUsername]),
        });
      }
    }
  }
}