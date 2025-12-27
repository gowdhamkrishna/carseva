import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:carseva/features/voice_search/presentation/bloc/gemini_bloc_bloc.dart';
import 'package:carseva/features/voice_search/presentation/bloc/gemini_bloc_event.dart';
import 'package:carseva/features/voice_search/presentation/bloc/gemini_bloc_state.dart';
import 'package:carseva/features/voice_search/presentation/widgets/chat_message_bubble.dart';
import 'package:carseva/features/voice_search/presentation/widgets/typing_indicator.dart';

class VoiceSearchPage extends StatefulWidget {
  const VoiceSearchPage({super.key});

  @override
  State<VoiceSearchPage> createState() => _VoiceSearchPageState();
}

class _VoiceSearchPageState extends State<VoiceSearchPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late AnimationController _waveController;
  late AnimationController _rotateController;

  late SpeechToText _speech;
  late ScrollController _scrollController;

  bool isListening = false;
  String recognizedText = '';

  @override
  void initState() {
    super.initState();

    _speech = SpeechToText();
    _scrollController = ScrollController();

    _pulseController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
          ..repeat(reverse: true);

    _fadeController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))
          ..forward();

    _waveController =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
          ..repeat();

    _rotateController =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _waveController.dispose();
    _rotateController.dispose();
    _scrollController.dispose();
    _speech.stop();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _toggleListening() {
    setState(() {
      isListening = !isListening;
      if (isListening) {
        _startListening();
      } else {
        _stopListening();
      }
    });
  }

  Future<void> _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => debugPrint("STT Status: $status"),
      onError: (error) => debugPrint("STT Error: $error"),
    );

    if (available) {
      recognizedText = "";

      await _speech.listen(
        onResult: (result) {
          setState(() {
            recognizedText = result.recognizedWords;
          });
        },
      );
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();

    if (recognizedText.trim().isNotEmpty) {
      if (mounted) {
        context.read<AiBloc>().add(AskAiEvent(recognizedText));
        recognizedText = '';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AiBloc, AiState>(
      listener: (context, state) {
        if (state is AiSuccess || state is AiError) {
          _scrollToBottom();
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF0A0E27),
                Color(0xFF1A1F3A),
                Color(0xFF0F1535),
              ],
            ),
          ),
          child: Stack(
            children: [
              _buildAnimatedBackground(),
              SafeArea(
                child: Column(
                  children: [
                    _buildAppBar(),
                    Expanded(child: _buildChatSection()),
                  ],
                ),
              ),
              _buildMicrophoneButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (_, __) => Stack(
        children: [
          Positioned(
            top: -100,
            right: -100,
            child: Transform.rotate(
              angle: _rotateController.value * 2 * math.pi,
              child: _bgCircle(300, const Color(0xFF6C63FF), 0.15),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -100,
            child: Transform.rotate(
              angle: -_rotateController.value * 2 * math.pi,
              child: _bgCircle(400, const Color(0xFFFF6584), 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bgCircle(double size, Color color, double opacity) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withOpacity(opacity), Colors.transparent],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome, color: Color(0xFF6C63FF), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              "Voice Assistant",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          BlocBuilder<AiBloc, AiState>(
            builder: (context, state) {
              if (state.messages.isNotEmpty) {
                return IconButton(
                  icon: const Icon(Icons.clear_all, color: Colors.white70),
                  onPressed: () {
                    context.read<AiBloc>().add(ClearConversationEvent());
                  },
                  tooltip: 'Clear conversation',
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChatSection() {
    return BlocBuilder<AiBloc, AiState>(
      builder: (context, state) {
        if (state.messages.isEmpty && state is! AiLoading) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 100),
          itemCount: state.messages.length + (state is AiLoading ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == state.messages.length) {
              return const TypingIndicator();
            }
            return ChatMessageBubble(message: state.messages[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: FadeTransition(
        opacity: _fadeController,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6C63FF).withOpacity(0.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6C63FF).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              "Start a conversation",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                "Tap the microphone below to ask me about car maintenance, diagnostics, or service centers",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrophoneButton() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              const Color(0xFF0A0E27).withOpacity(0.95),
            ],
          ),
        ),
        child: Center(
          child: GestureDetector(
            onTap: _toggleListening,
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) => Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isListening
                      ? const Color(0xFFFF6584)
                      : const Color(0xFF6C63FF),
                  boxShadow: [
                    BoxShadow(
                      color: (isListening
                              ? const Color(0xFFFF6584)
                              : const Color(0xFF6C63FF))
                          .withOpacity(isListening ? 0.6 : 0.4),
                      blurRadius: 25,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  isListening ? Icons.mic : Icons.mic_none,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
