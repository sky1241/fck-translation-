import '../domain/i_chat_repository.dart';
import 'models/translation_result.dart';
import 'translation_service.dart';

class ChatRepository implements IChatRepository {
  ChatRepository({TranslationService? service})
      : _service = service ?? TranslationService();

  final TranslationService _service;

  @override
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang,
    required String targetLang,
    required String tone,
    required bool wantPinyin,
  }) async {
    return _service.translate(
      text: text,
      sourceLang: sourceLang,
      targetLang: targetLang,
      tone: tone,
      wantPinyin: wantPinyin,
    );
  }
}


