import 'package:flutter/material.dart';
import 'package:carseva/features/market_trends/data/market_analysis_ai_service.dart';
import 'package:carseva/core/widgets/ai_analyzing_animation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AIMarketTrendsPage extends StatefulWidget {
  const AIMarketTrendsPage({super.key});

  @override
  State<AIMarketTrendsPage> createState() => _AIMarketTrendsPageState();
}

class _AIMarketTrendsPageState extends State<AIMarketTrendsPage> with SingleTickerProviderStateMixin {
  bool _showNewCars = true;
  bool _isLoading = true;
  Map<String, dynamic>? _marketData;
  late MarketAnalysisAIService _aiService;
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );
    _aiService = MarketAnalysisAIService(model);
    
    _loadMarketData();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() => _isLoading = true);
    
    final data = await _aiService.getMarketTrends(
      segment: _showNewCars ? 'new' : 'used',
    );
    
    setState(() {
      _marketData = data;
      _isLoading = false;
    });
    
    _animController.forward(from: 0);
  }

  void _toggleSegment(bool showNew) {
    if (_showNewCars != showNew) {
      setState(() => _showNewCars = showNew);
      _loadMarketData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Market Trends',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: _isLoading
          ? const AIAnalyzingAnimation(message: 'Analyzing market trends')
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_marketData == null) {
      return const Center(child: Text('No data available'));
    }

    final topCars = (_marketData!['topCars'] as List?) ?? [];
    final priceTrend = _marketData!['priceTrend'] as Map<String, dynamic>?;
    final insights = (_marketData!['insights'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleCard(),
          const SizedBox(height: 24),
          if (priceTrend != null) _buildPriceTrendCard(priceTrend),
          const SizedBox(height: 24),
          if (insights.isNotEmpty) _buildInsightsCard(insights),
          const SizedBox(height: 24),
          const Text(
            'Top Selling Cars',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...topCars.asMap().entries.map((entry) {
            final index = entry.key;
            final car = entry.value as Map<String, dynamic>;
            return _buildCarCard(car, index + 1, topCars.length);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return Container(
      padding: const EdgeInsets.all(4),
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
          Expanded(
            child: _buildToggleButton('New Cars', _showNewCars, () => _toggleSegment(true)),
          ),
          Expanded(
            child: _buildToggleButton('Second-Hand', !_showNewCars, () => _toggleSegment(false)),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4CAF50) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTrendCard(Map<String, dynamic> priceTrend) {
    final months = (priceTrend['months'] as List?)?.cast<String>() ?? [];
    final values = (priceTrend['values'] as List?)?.cast<int>() ?? [];
    
    if (months.isEmpty || values.isEmpty) return const SizedBox.shrink();

    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();
    final minValue = values.reduce((a, b) => a < b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4CAF50).withOpacity(0.8),
            const Color(0xFF66BB6A).withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.trending_up, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                _showNewCars ? 'New Car Price Index' : 'Used Car Price Index',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildAnimatedBarChart(months, values, maxValue),
          const SizedBox(height: 12),
          Text(
            values.last > values.first
                ? '↑ ${((values.last - values.first) / values.first * 100).toStringAsFixed(1)}% increase'
                : '↓ ${((values.first - values.last) / values.first * 100).toStringAsFixed(1)}% decrease',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBarChart(List<String> months, List<int> values, double maxValue) {
    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (index) {
          final value = values[index];
          final heightPercent = value / maxValue;

          return AnimatedBuilder(
            animation: _animController,
            builder: (context, child) {
              final animatedHeight = heightPercent * 100 * _animController.value;
              
              return Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 40,
                    height: animatedHeight,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    months[index],
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildInsightsCard(List insights) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.lightbulb_outline, color: Color(0xFF6366F1), size: 20),
              SizedBox(width: 8),
              Text(
                'Market Insights',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6366F1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map((insight) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ', style: TextStyle(color: Color(0xFF6366F1))),
                    Expanded(
                      child: Text(
                        insight.toString(),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[800],
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

  Widget _buildCarCard(Map<String, dynamic> car, int rank, int totalCars) {
    final maxSales = _showNewCars ? 25000 : 10000;
    final sales = (car['sales'] as num?)?.toInt() ?? 0;
    final salesPercentage = sales / maxSales;
    final priceChange = ((car['priceChange'] as num?) ?? 0).toDouble();
    final isPositive = priceChange > 0;
    final avgPrice = ((car['avgPrice'] as num?) ?? 0).toDouble();

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) {
        final delay = (rank - 1) / totalCars;
        final animValue = (_animController.value - delay).clamp(0.0, 1.0);
        
        return Opacity(
          opacity: animValue,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animValue)),
            child: child,
          ),
        );
      },
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: rank <= 3 ? const Color(0xFF4CAF50) : Colors.grey[600],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        car['name'] as String? ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        car['segment'] as String? ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? const Color(0xFF4CAF50).withOpacity(0.1)
                        : const Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFEF4444),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${priceChange.abs().toStringAsFixed(1)}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isPositive ? const Color(0xFF4CAF50) : const Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sales',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '${_formatSales(sales)}/month',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: salesPercentage,
                        backgroundColor: Colors.grey[200],
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                        borderRadius: BorderRadius.circular(4),
                        minHeight: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Avg. Price',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  _formatPrice(avgPrice),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4CAF50),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    if (price >= 10000000) {
      return '₹${(price / 10000000).toStringAsFixed(2)} Cr';
    } else if (price >= 100000) {
      return '₹${(price / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹${price.toStringAsFixed(0)}';
    }
  }

  String _formatSales(int sales) {
    if (sales >= 1000) {
      return '${(sales / 1000).toStringAsFixed(1)}K';
    }
    return sales.toString();
  }
}
