import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:t_store/utils/constants/colors.dart';

import 'common/widgets/appbar/appbar.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String currentUserUsername;
  final String otherUserUsername;

  const ChatScreen({super.key, 
    required this.chatId,
    required this.currentUserUsername,
    required this.otherUserUsername,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? messageText;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(title: Text('Chat'), showBackArrow: true),
      body: Column(
        children: [
          /// Messages Stream
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('time', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                // Mark messages as read
                for (var message in messages) {
                  if (!message['readBy'].contains(widget.currentUserUsername)) {
                    message.reference.update({
                      'readBy': FieldValue.arrayUnion([widget.currentUserUsername]),
                    });
                  }
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final sender = message['sender'];
                    final text = message['text'];
                    final timestamp = message['time'] != null
                        ? (message['time'] as Timestamp).toDate()
                        : null;

                    return MessageLine(
                      sender: sender,
                      text: text,
                      timestamp: timestamp,
                      isMe: sender == widget.currentUserUsername,
                    );
                  },
                );
              },
            ),
          ),

          /// Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
              //color: TColors.darkGrey,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                /// Message Input
                Expanded(
                  child: TextField(
                    controller: messageTextController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 20,
                      ),
                      hintText: 'Write your message here...',
                      hintStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: TColors.darkGrey,
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50000),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(50000),
                      ),
                    ),
                  ),
                ),

                /// Send Button
                IconButton(
                  icon: const Icon(Icons.send, color: TColors.primary, size: 30),
                  onPressed: () {
                    final messageText = messageTextController.text.trim();
                    if (messageText.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.chatId)
                          .collection('messages')
                          .add({
                        'sender': widget.currentUserUsername,
                        'text': messageText,
                        'time': FieldValue.serverTimestamp(),
                        'readBy': [], // Initialize with an empty array
                      });

                      FirebaseFirestore.instance
                          .collection('chats')
                          .doc(widget.chatId)
                          .update({
                        'lastMessage': messageText,
                        'timestamp': FieldValue.serverTimestamp(),
                      });

                      messageTextController.clear();

                      // Scroll to bottom
                      _scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for Individual Message
class MessageLine extends StatelessWidget {
  const MessageLine({
    super.key,
    required this.sender,
    required this.text,
    required this.isMe,
    this.timestamp,
  });

  final String sender;
  final String text;
  final bool isMe;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final timeFormatted = timestamp != null
        ? "${timestamp!.hour}:${timestamp!.minute.toString().padLeft(2, '0')}"
        : '';

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(fontSize: 12, color: dark ? Colors.white70 : Colors.black54),
          ),
          const SizedBox(height: 5),
          Material(
            elevation: 5,
            borderRadius: isMe
                ? const BorderRadius.only(
              topLeft: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            )
                : const BorderRadius.only(
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            color: isMe ? TColors.primary : TColors.darkGrey,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: const TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  if (timestamp != null)
                    Text(
                      timeFormatted,
                      style: const TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
