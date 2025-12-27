import 'package:equatable/equatable.dart';

abstract class AiEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AskAiEvent extends AiEvent {
  final String prompt;

  AskAiEvent(this.prompt);

  @override
  List<Object?> get props => [prompt];
}

/// Event to clear conversation history
class ClearConversationEvent extends AiEvent {
  ClearConversationEvent();
}
