import 'package:carseva/features/voice_search/domain/models/conversation_message.dart';
import 'package:equatable/equatable.dart';

abstract class AiState extends Equatable {
  final List<ConversationMessage> messages;

  const AiState({this.messages = const []});

  @override
  List<Object?> get props => [messages];
}

class AiInitial extends AiState {
  const AiInitial({super.messages});
}

class AiLoading extends AiState {
  final String? currentQuery;

  const AiLoading({super.messages, this.currentQuery});

  @override
  List<Object?> get props => [messages, currentQuery];
}

class AiSuccess extends AiState {
  final String response;

  const AiSuccess({required super.messages, required this.response});

  @override
  List<Object?> get props => [messages, response];
}

class AiError extends AiState {
  final String message;

  const AiError({required super.messages, required this.message});

  @override
  List<Object?> get props => [messages, message];
}
