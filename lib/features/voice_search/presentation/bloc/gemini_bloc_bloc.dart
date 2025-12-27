import 'package:carseva/features/voice_search/domain/models/conversation_message.dart';
import 'package:carseva/features/voice_search/domain/usecase/generate_text.dart';
import 'package:carseva/features/voice_search/presentation/bloc/gemini_bloc_event.dart';
import 'package:carseva/features/voice_search/presentation/bloc/gemini_bloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AiBloc extends Bloc<AiEvent, AiState> {
  final GenerateText generateText;

  // Conversation history - maintains last 5 turns (10 messages max)
  final List<ConversationMessage> _conversationHistory = [];
  static const int _maxHistoryTurns = 5;

  AiBloc(this.generateText) : super(const AiInitial()) {
    on<AskAiEvent>((event, emit) async {
      // Get current messages for loading state
      final currentMessages = List<ConversationMessage>.from(_conversationHistory);
      final userMessage = ConversationMessage.user(event.prompt);
      
      // Add user message temporarily for loading state
      final messagesWithUser = [...currentMessages, userMessage];
      emit(AiLoading(messages: messagesWithUser, currentQuery: event.prompt));
      
      try {
        // Get recent history (last 5 turns = 10 messages max)
        final recentHistory = _getRecentHistory();
        
        // Generate response with conversation history
        final result = await generateText.call(
          event.prompt,
          recentHistory,
        );

        // Add assistant response to history
        final assistantMessage = ConversationMessage.assistant(result);
        _conversationHistory.add(userMessage);
        _conversationHistory.add(assistantMessage);

        // Keep history size manageable (last 5 turns)
        _trimHistory();

        // Emit success with updated messages
        final updatedMessages = List<ConversationMessage>.from(_conversationHistory);
        emit(AiSuccess(messages: updatedMessages, response: result));
      } catch (e) {
        // On error, keep messages without the user message
        emit(AiError(messages: currentMessages, message: e.toString()));
      }
    });

    on<ClearConversationEvent>((event, emit) {
      _conversationHistory.clear();
      emit(const AiInitial());
    });
  }

  /// Get recent conversation history (last 5 turns)
  List<ConversationMessage> _getRecentHistory() {
    if (_conversationHistory.length <= _maxHistoryTurns * 2) {
      return List.from(_conversationHistory);
    }
    
    // Get the last 10 messages (5 turns)
    return _conversationHistory.sublist(
      _conversationHistory.length - (_maxHistoryTurns * 2),
    );
  }

  /// Trim conversation history to maintain max size
  void _trimHistory() {
    if (_conversationHistory.length > _maxHistoryTurns * 2) {
      // Keep only the last 10 messages (5 turns)
      final keepCount = _maxHistoryTurns * 2;
      _conversationHistory.removeRange(
        0,
        _conversationHistory.length - keepCount,
      );
    }
  }
}
