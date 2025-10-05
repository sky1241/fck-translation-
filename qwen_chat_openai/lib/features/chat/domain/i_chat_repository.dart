import '../data/models/translation_result.dart';

abstract class IChatRepository {
  Future<TranslationResult> translate({
    required String text,
    required String sourceLang, // 'fr' | 'zh'
    required String targetLang, // 'fr' | 'zh'
    required String tone, // 'casual' | 'affectionate' | 'business'
    required bool wantPinyin,
  });
}


