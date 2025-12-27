import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carseva/features/predictive_maintenance/presentation/bloc/maintenance_bloc.dart';
import 'package:carseva/features/predictive_maintenance/presentation/bloc/maintenance_event.dart';
import 'package:carseva/features/predictive_maintenance/presentation/bloc/maintenance_state.dart';
import 'package:carseva/features/predictive_maintenance/domain/entities/vehicle_health_questions.dart';
import 'package:carseva/features/predictive_maintenance/presentation/pages/health_result_page.dart';
import 'package:carseva/core/widgets/ai_analyzing_animation.dart';

class HealthEvaluationPage extends StatefulWidget {
  final String? carId;
  final Map<String, dynamic>? carContext;

  const HealthEvaluationPage({
    super.key,
    this.carId,
    this.carContext,
  });

  @override
  State<HealthEvaluationPage> createState() => _HealthEvaluationPageState();
}

class _HealthEvaluationPageState extends State<HealthEvaluationPage> {
  final Map<String, Map<String, dynamic>> _answers = {};
  int _currentComponentIndex = 0;
  final PageController _pageController = PageController();

  List<String> get _components => VehicleHealthQuestions.getComponents();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Health Evaluation',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocListener<MaintenanceBloc, MaintenanceState>(
        listener: (context, state) {
          if (state is HealthScoreCalculated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HealthResultPage(
                  healthScore: state.healthScore,
                  predictions: state.predictions,
                ),
              ),
            );
          } else if (state is MaintenanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
          builder: (context, state) {
            if (state is MaintenanceEvaluating) {
              return const AIAnalyzingAnimation(
                message: 'Evaluating health with AI',
              );
            }

            return Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _components.length,
                    itemBuilder: (context, index) {
                      return _buildComponentQuestions(_components[index]);
                    },
                  ),
                ),
                _buildNavigationButtons(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentComponentIndex + 1) / _components.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _components[_currentComponentIndex],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${_currentComponentIndex + 1}/${_components.length}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildComponentQuestions(String component) {
    final questions = VehicleHealthQuestions.questionsByComponent[component] ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF10B981), Color(0xFF059669)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getComponentIcon(component),
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        component,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${questions.length} questions',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ...questions.asMap().entries.map((entry) {
            final index = entry.key;
            final question = entry.value;
            return _buildQuestionCard(component, index, question);
          }).toList(),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(String component, int index, Map<String, dynamic> question) {
    final questionText = question['question'] as String;
    final type = question['type'] as String;
    final questionKey = '$component-$index';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            questionText,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          if (type == 'yesno') _buildYesNoButtons(questionKey),
          if (type == 'rating') _buildRatingSlider(questionKey),
          if (type == 'duration') _buildDurationOptions(questionKey, question),
        ],
      ),
    );
  }

  Widget _buildYesNoButtons(String questionKey) {
    final answer = _answers[questionKey]?['value'] as bool?;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _answers[questionKey] = {'value': true, 'type': 'yesno'};
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: answer == true ? const Color(0xFF10B981) : Colors.grey[200],
              foregroundColor: answer == true ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Yes'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _answers[questionKey] = {'value': false, 'type': 'yesno'};
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: answer == false ? const Color(0xFFEF4444) : Colors.grey[200],
              foregroundColor: answer == false ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('No'),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSlider(String questionKey) {
    final answer = _answers[questionKey]?['value'] as double? ?? 5.0;

    return Column(
      children: [
        Slider(
          value: answer,
          min: 0,
          max: 10,
          divisions: 10,
          label: answer.toInt().toString(),
          activeColor: const Color(0xFF10B981),
          onChanged: (value) {
            setState(() {
              _answers[questionKey] = {'value': value, 'type': 'rating'};
            });
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Poor', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
            Text('Excellent', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildDurationOptions(String questionKey, Map<String, dynamic> question) {
    final options = question['options'] as List<dynamic>;
    final answer = _answers[questionKey]?['value'] as int?;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.asMap().entries.map((entry) {
        final index = entry.key;
        final option = entry.value as String;
        final isSelected = answer == index;

        return FilterChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _answers[questionKey] = {'value': index, 'type': 'duration'};
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: const Color(0xFF10B981),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentComponentIndex > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentComponentIndex--;
                    _pageController.animateToPage(
                      _currentComponentIndex,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: const BorderSide(color: Color(0xFF10B981)),
                ),
                child: const Text('Previous'),
              ),
            ),
          if (_currentComponentIndex > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _handleNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                _currentComponentIndex == _components.length - 1
                    ? 'Evaluate with AI'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext() {
    if (_currentComponentIndex < _components.length - 1) {
      setState(() {
        _currentComponentIndex++;
        _pageController.animateToPage(
          _currentComponentIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      });
    } else {
      _submitEvaluation();
    }
  }

  void _submitEvaluation() {
    final carContext = widget.carContext ?? {
      'make': 'Unknown',
      'model': 'Unknown',
      'year': DateTime.now().year,
      'mileage': 0,
    };

    context.read<MaintenanceBloc>().add(
          EvaluateHealthEvent(
            carId: widget.carId ?? 'default',
            carContext: carContext,
            answers: _answers,
          ),
        );
  }

  String _getComponentIcon(String component) {
    switch (component.toLowerCase()) {
      case 'engine':
        return '🔧';
      case 'brakes':
        return '🛑';
      case 'transmission':
        return '⚙️';
      case 'battery':
        return '🔋';
      case 'tires':
        return '🛞';
      case 'fluids':
        return '💧';
      case 'suspension':
        return '🔩';
      default:
        return '🚗';
    }
  }
}
