import 'package:dialog_flowtter/dialog_flowtter.dart';
import '../models/message_model.dart';

class DialogflowService {
  DialogFlowtter dialogFlowtter = DialogFlowtter(jsonPath: "assets/credentials/dialogflow-credentials.json");

  Future<MessageModel?> getResponse(String message) async {
    final response = await dialogFlowtter.detectIntent(
      queryInput: QueryInput(text: TextInput(text: message)),
    );

    if (response?.message == null) return null;

    return MessageModel(
      text: response!.message?.text?.text?.first ?? '',
      isUser: false,
    );
  }
}