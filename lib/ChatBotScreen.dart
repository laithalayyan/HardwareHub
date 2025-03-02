import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:t_store/utils/constants/colors.dart';
import 'common/widgets/appbar/appbar.dart';
import 'config/config.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});

  @override
  _ChatBotScreenState createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController messageTextController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> messages = [];
  final GetStorage storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TAppBar(title: Text('ChatBot'), showBackArrow: true),
      body: Column(
        children: [
          /// Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[messages.length - 1 - index];
                final isMe = message['sender'] == 'user';
                final text = message['text'];
                final timestamp = message['timestamp'];

                return MessageLine(
                  sender: isMe ? 'You' : 'Bot',
                  text: text,
                  isMe: isMe,
                  timestamp: timestamp,
                );
              },
            ),
          ),

          /// Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const BoxDecoration(
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
                  onPressed: () async {
                    final messageText = messageTextController.text.trim();
                    if (messageText.isNotEmpty) {
                      // Add user message to the list
                      setState(() {
                        messages.add({
                          'sender': 'user',
                          'text': messageText,
                          'timestamp': DateTime.now(),
                        });
                      });

                      // Clear the input field
                      messageTextController.clear();

                      // Scroll to the bottom
                      _scrollController.animateTo(
                        0.0,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );

                      // Send the message to the API and get the bot's response
                      final botResponse = await sendMessageToAPI(messageText);
                      if (botResponse != null) {
                        setState(() {
                          messages.add({
                            'sender': 'bot',
                            'text': botResponse,
                            'timestamp': DateTime.now(),
                          });
                        });

                        // Scroll to the bottom again after the bot responds
                        _scrollController.animateTo(
                          0.0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                        );
                      }
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

  /// Function to send a message to the API and get the bot's response
  Future<String?> sendMessageToAPI(String message) async {
    final url = Uri.parse('${AppConfig.baseUrl}/api/Chat');
    final token = storage.read('token');

    if (token == null) {
      print('Token not found in GetStorage');
      return null;
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['message']; // Extract the bot's response
      } else {
        print('Failed to get bot response: ${response.statusCode}');
        print('Response body: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error sending message to API: $e');
      return null;
    }
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