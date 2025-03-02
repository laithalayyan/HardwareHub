import 'package:chatview/chatview.dart';

class Data {
  static const profileImage = 'https://via.placeholder.com/150'; // Replace with a valid image URL
  static final messageList = [
    Message(
      id: '1',
      createdAt: DateTime.now(),
      message: 'Hello, how can I help you?',
      sentBy: '2',
      messageType: MessageType.text,
    ),
    Message(
      id: '2',
      createdAt: DateTime.now().add(const Duration(minutes: 1)),
      message: 'Can you tell me about your services?',
      sentBy: '1',
      messageType: MessageType.text,
    ),
  ];
}
