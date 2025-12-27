import 'package:flutter/material.dart';
import 'package:carseva/features/vehicle_insights/data/vehicle_insights_ai_service.dart';
import 'package:carseva/core/widgets/ai_analyzing_animation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VehicleInsightsPage extends StatefulWidget {
  final String make;
  final String model;
  final int year;
  final int mileage;

  const VehicleInsightsPage({
    super.key,
    required this.make,
    required this.model,
    required this.year,
    required this.mileage,
  });

  @override
  State<VehicleInsightsPage> createState() => _VehicleInsightsPageState();
}

class _VehicleInsightsPageState extends State<VehicleInsightsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _insights;
  late VehicleInsightsAIService _aiService;

  @override
  void initState() {
    super.initState();
    
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    _aiService = VehicleInsightsAIService(model);
    
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    setState(() => _isLoading = true);
    
    final insights = await _aiService.getVehicleInsights(
      make: widget.make,
      model: widget.model,
      year: widget.year,
      mileage: widget.mileage,
    );
    
    setState(() {
      _insights = insights;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Vehicle Insights',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInsights,
          ),
        ],
      ),
      body: _isLoading
          ? const AIAnalyzingAnimation(message: 'Analyzing your vehicle')
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_insights == null) {
      return const Center(child: Text('No insights available'));
    }

    final overallHealth = _insights!['overallHealth'] as String? ?? 'Good';
    final healthScore = ((_insights!['healthScore'] as num?) ?? 75).toInt();
    final keyInsights = (_insights!['keyInsights'] as List?) ?? [];
    final upcomingMaintenance = (_insights!['upcomingMaintenance'] as List?) ?? [];
    final tips = (_insights!['tips'] as List?) ?? [];
    final resaleValue = _insights!['resaleValue'] as Map<String, dynamic>?;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVehicleHeader(),
          const SizedBox(height: 20),
          _buildHealthScoreCard(overallHealth, healthScore),
          const SizedBox(height: 20),
          if (keyInsights.isNotEmpty) _buildKeyInsights(keyInsights),
          const SizedBox(height: 20),
          if (upcomingMaintenance.isNotEmpty) _buildUpcomingMaintenance(upcomingMaintenance),
          const SizedBox(height: 20),
          if (tips.isNotEmpty) _buildTipsCard(tips),
          const SizedBox(height: 20),
          if (resaleValue != null) _buildResaleValueCard(resaleValue),
        ],
      ),
    );
  }

  Widget _buildVehicleHeader() {
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.make} ${widget.model}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.year} • ${_formatMileage(widget.mileage)}',
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
    );
  }

  Widget _buildHealthScoreCard(String health, int score) {
    Color scoreColor = score >= 80
        ? const Color(0xFF4CAF50)
        : score >= 60
            ? const Color(0xFFFF9800)
            : const Color(0xFFEF4444);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: scoreColor.withOpacity(0.1),
            ),
            child: Center(
              child: Text(
                '$score',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: scoreColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Overall Health',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  health,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyInsights(List insights) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Key Insights',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...insights.map((insight) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: Color(0xFF6366F1),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      insight.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            )).toList(),
      ],
    );
  }

  Widget _buildUpcomingMaintenance(List maintenance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming Maintenance',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...maintenance.map((item) {
          final itemMap = item as Map<String, dynamic>;
          final priority = itemMap['priority'] as String? ?? 'Medium';
          final priorityColor = priority == 'High'
              ? const Color(0xFFEF4444)
              : priority == 'Medium'
                  ? const Color(0xFFFF9800)
                  : const Color(0xFF4CAF50);

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
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
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: priorityColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.build,
                    color: priorityColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        itemMap['item'] as String? ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Due at ${_formatMileage((itemMap['dueAt'] as num?)?.toInt() ?? 0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        priority,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: priorityColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${(itemMap['estimatedCost'] as num?)?.toInt() ?? 0}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTipsCard(List tips) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF34D399).withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Maintenance Tips',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF10B981),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips.map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF10B981), fontSize: 16)),
                    Expanded(
                      child: Text(
                        tip.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
        ],
      ),
    );
  }

  Widget _buildResaleValueCard(Map<String, dynamic> resaleValue) {
    final current = ((resaleValue['current'] as num?) ?? 0).toInt();
    final trend = resaleValue['trend'] as String? ?? 'Stable';
    final factors = (resaleValue['factors'] as List?) ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimated Resale Value',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '₹${_formatPrice(current)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Market Trend: $trend',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Icon(
                trend == 'Rising'
                    ? Icons.trending_up
                    : trend == 'Falling'
                        ? Icons.trending_down
                        : Icons.trending_flat,
                color: trend == 'Rising'
                    ? const Color(0xFF4CAF50)
                    : trend == 'Falling'
                        ? const Color(0xFFEF4444)
                        : const Color(0xFFFF9800),
                size: 32,
              ),
            ],
          ),
          if (factors.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Factors:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ...factors.map((factor) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          factor.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
          ],
        ],
      ),
    );
  }

  String _formatMileage(int mileage) {
    if (mileage >= 100000) {
      return '${(mileage / 100000).toStringAsFixed(1)} lakh km';
    } else if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}K km';
    }
    return '$mileage km';
  }

  String _formatPrice(int price) {
    if (price >= 10000000) {
      return '${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '${(price / 100000).toStringAsFixed(2)} L';
    }
    return price.toString();
  }
}
