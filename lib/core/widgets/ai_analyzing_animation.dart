import 'package:flutter/material.dart';
import 'dart:math' as math;

class AIAnalyzingAnimation extends StatefulWidget {
  final String message;
  final VoidCallback? onCancel;

  const AIAnalyzingAnimation({
    super.key,
    this.message = 'Analyzing with AI...',
    this.onCancel,
  });

  @override
  State<AIAnalyzingAnimation> createState() => _AIAnalyzingAnimationState();
}

class _AIAnalyzingAnimationState extends State<AIAnalyzingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    // Animate dots
    Future.doWhile(() async {
      if (!mounted) return false;
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _dotCount = (_dotCount + 1) % 4;
        });
      }
      return mounted;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated AI Brain Icon
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * math.pi,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF6366F1).withOpacity(0.8),
                        const Color(0xFF8B5CF6).withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 32),

          // Animated Message
          Text(
            widget.message + ('.' * _dotCount),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          // Progress Steps
          _buildProgressSteps(),
          
          const SizedBox(height: 32),

          // Cancel Button
          if (widget.onCancel != null)
            TextButton.icon(
              onPressed: widget.onCancel,
              icon: const Icon(Icons.close),
              label: const Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey[600],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProgressSteps() {
    final steps = [
      'Processing symptoms',
      'Consulting AI database',
      'Generating diagnosis',
    ];

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isActive = (_dotCount % 3) == index;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive
                      ? const Color(0xFF6366F1)
                      : Colors.grey[300],
                ),
              ),
              const SizedBox(width: 12),
              Text(
                step,
                style: TextStyle(
                  fontSize: 14,
                  color: isActive ? Colors.grey[800] : Colors.grey[500],
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
