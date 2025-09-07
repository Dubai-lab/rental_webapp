import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/message_model.dart';

class ChatBubbleController extends StateNotifier<List<MessageModel>> {
  ChatBubbleController() : super([]) {
    // Add initial bot greeting
    state = [
      MessageModel(
        text: "Hi! How can I help you today?",
        isUser: false,
      )
    ];
  }

  void addMessage(MessageModel message) {
    state = [...state, message];
  }
}

final chatBubbleProvider =
    StateNotifierProvider<ChatBubbleController, List<MessageModel>>(
        (ref) => ChatBubbleController());