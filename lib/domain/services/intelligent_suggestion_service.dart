import '../../data/models/ai_suggestion.dart';
import '../../data/models/stem.dart';
import '../../data/models/user_settings.dart';
import 'anthropic_service.dart';
import 'suggestion_service.dart';

class SuggestionResult {
  final List<dynamic> suggestions; // Either List<Stem> or List<AISuggestion>
  final bool isAiGenerated;
  final String? errorMessage;
  final List<String> keywords;

  const SuggestionResult({
    required this.suggestions,
    required this.isAiGenerated,
    this.errorMessage,
    this.keywords = const [],
  });

  List<Stem> get stems => isAiGenerated ? [] : suggestions.cast<Stem>();
  List<AISuggestion> get aiSuggestions =>
      isAiGenerated ? suggestions.cast<AISuggestion>() : [];
}

class IntelligentSuggestionService {
  final SuggestionService _suggestionService;
  final AnthropicService _anthropicService;

  IntelligentSuggestionService({
    required SuggestionService suggestionService,
    required AnthropicService anthropicService,
  })  : _suggestionService = suggestionService,
        _anthropicService = anthropicService;

  Future<SuggestionResult> getSuggestions({
    required String completion,
    required String stemText,
    required GuidedModeType modeType,
    required String excludeStemId,
  }) async {
    final keywords = _suggestionService.extractKeywords(completion);

    if (modeType == GuidedModeType.off) {
      return SuggestionResult(
        suggestions: [],
        isAiGenerated: false,
        keywords: keywords,
      );
    }

    if (modeType == GuidedModeType.keyword) {
      final stems = await _suggestionService.getSuggestedStems(
        completion: completion,
        excludeStemId: excludeStemId,
        limit: 3,
      );
      return SuggestionResult(
        suggestions: stems,
        isAiGenerated: false,
        keywords: keywords,
      );
    }

    // Intelligent mode - try AI first, fallback to keyword
    try {
      final aiSuggestions = await _anthropicService.getStemSuggestions(
        completion: completion,
        stemText: stemText,
        count: 5,
      );

      if (aiSuggestions.isEmpty) {
        // Fallback to keyword-based
        final stems = await _suggestionService.getSuggestedStems(
          completion: completion,
          excludeStemId: excludeStemId,
          limit: 3,
        );
        return SuggestionResult(
          suggestions: stems,
          isAiGenerated: false,
          errorMessage: 'AI returned no suggestions, showing keyword-based results',
          keywords: keywords,
        );
      }

      return SuggestionResult(
        suggestions: aiSuggestions,
        isAiGenerated: true,
        keywords: keywords,
      );
    } on AnthropicApiException catch (e) {
      // Fallback to keyword-based with error message
      final stems = await _suggestionService.getSuggestedStems(
        completion: completion,
        excludeStemId: excludeStemId,
        limit: 3,
      );
      return SuggestionResult(
        suggestions: stems,
        isAiGenerated: false,
        errorMessage: 'AI unavailable: ${e.message}. Showing keyword-based suggestions.',
        keywords: keywords,
      );
    } catch (e) {
      // Fallback to keyword-based with generic error
      final stems = await _suggestionService.getSuggestedStems(
        completion: completion,
        excludeStemId: excludeStemId,
        limit: 3,
      );
      return SuggestionResult(
        suggestions: stems,
        isAiGenerated: false,
        errorMessage: 'Could not generate AI suggestions. Showing keyword-based results.',
        keywords: keywords,
      );
    }
  }
}
