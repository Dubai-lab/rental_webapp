import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/dialogflow_service.dart';

final dialogflowServiceProvider = Provider<DialogflowService>((ref) {
  return DialogflowService();
});