import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:carseva/features/diagnostics/presentation/bloc/diagnostic_bloc.dart';
import 'package:carseva/features/diagnostics/presentation/bloc/diagnostic_event.dart';
import 'package:carseva/features/diagnostics/presentation/bloc/diagnostic_state.dart';
import 'package:carseva/features/diagnostics/domain/entities/common_vehicle_issues.dart';
import 'package:carseva/features/diagnostics/presentation/pages/diagnosis_result_page.dart';
import 'package:carseva/core/widgets/ai_analyzing_animation.dart';

class SymptomCheckerPage extends StatefulWidget {
  final String? carId;
  final Map<String, dynamic>? carContext;

  const SymptomCheckerPage({
    super.key,
    this.carId,
    this.carContext,
  });

  @override
  State<SymptomCheckerPage> createState() => _SymptomCheckerPageState();
}

class _SymptomCheckerPageState extends State<SymptomCheckerPage> {
  final Set<String> _selectedSymptoms = {};
  final TextEditingController _additionalDetailsController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _additionalDetailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Symptom Checker',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: BlocListener<DiagnosticBloc, DiagnosticState>(
        listener: (context, state) {
          print('📱 Diagnostic State Changed: ${state.runtimeType}');
          
          if (state is DiagnosticAnalyzed) {
            print('✅ Navigating to results page...');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DiagnosisResultPage(
                  diagnostic: state.diagnostic,
                ),
              ),
            );
          } else if (state is DiagnosticError) {
            print('❌ Showing error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<DiagnosticBloc, DiagnosticState>(
          builder: (context, state) {
            if (state is DiagnosticAnalyzing) {
              return const AIAnalyzingAnimation(
                message: 'Analyzing symptoms with AI',
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInstructionCard(),
                  const SizedBox(height: 24),
                  _buildCategoryFilter(),
                  const SizedBox(height: 16),
                  _buildSymptomsList(),
                  const SizedBox(height: 24),
                  _buildAdditionalDetails(),
                  const SizedBox(height: 24),
                  _buildSelectedSymptomsChips(),
                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _selectedSymptoms.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _analyzeSymptoms,
              icon: const Icon(Icons.analytics),
              label: const Text('Analyze with AI'),
              backgroundColor: const Color(0xFF6366F1),
            )
          : null,
    );
  }

  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
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
            child: const Icon(
              Icons.info_outline,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Your Symptoms',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Choose all symptoms you\'re experiencing',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', ...CommonVehicleIssues.issuesByCategory.keys];

    return SizedBox(
      height: 45,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCategory = category;
                });
              },
              backgroundColor: Colors.white,
              selectedColor: const Color(0xFF6366F1),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              elevation: 2,
              shadowColor: Colors.black26,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSymptomsList() {
    final Map<String, List<Map<String, String>>> filteredIssues;

    if (_selectedCategory == 'All') {
      filteredIssues = CommonVehicleIssues.issuesByCategory;
    } else {
      filteredIssues = {
        _selectedCategory: CommonVehicleIssues.issuesByCategory[_selectedCategory]!
      };
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: filteredIssues.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            ...entry.value.map((issue) => _buildSymptomCard(issue, entry.key)),
            const SizedBox(height: 8),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSymptomCard(Map<String, String> issue, String category) {
    final symptom = issue['symptom']!;
    final isSelected = _selectedSymptoms.contains(symptom);
    final severity = issue['severity']!;
    final severityColor = _getSeverityColor(severity);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? const Color(0xFF6366F1) : Colors.grey[200]!,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedSymptoms.remove(symptom);
              } else {
                _selectedSymptoms.add(symptom);
              }
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFF6366F1) : Colors.grey[400],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        symptom,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? const Color(0xFF6366F1) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Possible: ${issue['causes']}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: severityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    severity.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: severityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Additional Details (Optional)',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _additionalDetailsController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Describe any other symptoms or details...',
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSymptomsChips() {
    if (_selectedSymptoms.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selected Symptoms (${_selectedSymptoms.length})',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedSymptoms.map((symptom) {
            return Chip(
              label: Text(symptom),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedSymptoms.remove(symptom);
                });
              },
              backgroundColor: const Color(0xFF6366F1).withOpacity(0.1),
              labelStyle: const TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return const Color(0xFFF44336);
      case 'high':
        return const Color(0xFFFF5722);
      case 'medium':
        return const Color(0xFFFF9800);
      case 'low':
        return const Color(0xFF4CAF50);
      default:
        return Colors.grey;
    }
  }

  void _analyzeSymptoms() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    final carContext = widget.carContext ?? {
      'make': 'Unknown',
      'model': 'Unknown',
      'year': DateTime.now().year,
      'mileage': 0,
    };

    context.read<DiagnosticBloc>().add(
          AnalyzeSymptomsEvent(
            userId: user.uid,
            carId: widget.carId ?? 'default',
            selectedSymptoms: _selectedSymptoms.toList(),
            additionalDetails: _additionalDetailsController.text.isNotEmpty
                ? _additionalDetailsController.text
                : null,
            carContext: carContext,
          ),
        );
  }
}
