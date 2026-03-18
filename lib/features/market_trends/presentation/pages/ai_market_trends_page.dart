import 'package:flutter/material.dart';
import 'package:carseva/features/market_trends/data/market_analysis_ai_service.dart';
import 'package:carseva/core/widgets/ai_analyzing_animation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


import 'package:carseva/core/api/ai_client.dart';

class AIMarketTrendsPage extends StatefulWidget {
  const AIMarketTrendsPage({super.key});

  @override
  State<AIMarketTrendsPage> createState() => _AIMarketTrendsPageState();
}

class _AIMarketTrendsPageState extends State<AIMarketTrendsPage> with SingleTickerProviderStateMixin {
  bool _showNewCars = true;
  bool _isLoading = true;
  String? _errorMessage;
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

    
    _aiService = MarketAnalysisAIService();
    
    _loadMarketData();
  }

  @override
  void dispose() {
    _animController.dispose();

    super.dispose();
  }

  Future<void> _loadMarketData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final data = await _aiService.getMarketTrends(
        segment: _showNewCars ? 'new' : 'used',
      );
      
      setState(() {
        _marketData = data;
        _isLoading = false;
      });
      
      _animController.forward(from: 0);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
        _marketData = null;
      });
    }
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF030712),
              Color(0xFF0F172A),
              Color(0xFF1E293B),
            ],
          ),
        ),
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                children: [
                  _buildCustomAppBar(),
                  Expanded(
                    child: _isLoading
                        ? const AIAnalyzingAnimation(message: 'Analyzing market trends')
                        : _errorMessage != null
                            ? _buildErrorState()
                            : _buildContent(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildGlassContainer(
        sigma: 15,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Market Trends',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              _buildAIStatusIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIStatusIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF4CAF50),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'AI Live',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Color(0xFFEF4444)),
          const SizedBox(height: 16),
          const Text(
            'Failed to load data',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage!,
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadMarketData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassContainer({required Widget child, double sigma = 10}) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1A1D27),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
          width: 1,
        ),
      ),
      child: child,
    );
  }



  Widget _buildContent() {
    if (_marketData == null) {
      return const Center(child: Text('No data available', style: TextStyle(color: Colors.white)));
    }

    final topCars = (_marketData!['topCars'] as List?) ?? [];
    final priceTrend = _marketData!['priceTrend'] as Map<String, dynamic>?;
    final insights = (_marketData!['insights'] as List?) ?? [];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildToggleCard(),
          const SizedBox(height: 24),
          if (priceTrend != null) _buildPriceTrendCard(priceTrend),
          const SizedBox(height: 24),
          if (insights.isNotEmpty) _buildInsightsCard(insights),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              'Top Selling Cars',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...topCars.asMap().entries.map((entry) {
            final index = entry.key;
            final car = entry.value as Map<String, dynamic>;
            return _buildCarCard(car, index + 1, topCars.length);
          }).toList(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildToggleCard() {
    return _buildGlassContainer(
      sigma: 10,
      child: Container(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: [
            Expanded(
              child: _buildToggleButton('New Cars', _showNewCars, () => _toggleSegment(true)),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: _buildToggleButton('Second-Hand', !_showNewCars, () => _toggleSegment(false)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: isActive
              ? const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF3F3D9E)],
                )
              : null,
          color: isActive ? null : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildPriceTrendCard(Map<String, dynamic> priceTrend) {
    final months = (priceTrend['months'] as List?)?.cast<String>() ?? [];
    final values = (priceTrend['values'] as List?)
            ?.map((e) => (e as num).toDouble())
            .toList() ??
        [];

    if (months.isEmpty || values.isEmpty) return const SizedBox.shrink();

    return _buildGlassContainer(
      sigma: 15,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.analytics_outlined, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 16),
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
            const SizedBox(height: 32),
            _buildAnimatedBarChart(months, values),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    values.last >= values.first ? Icons.trending_up : Icons.trending_down,
                    color: values.last >= values.first ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    values.last >= values.first
                        ? '↑ ${((values.last - values.first) / values.first * 100).toStringAsFixed(1)}% Demand Rise'
                        : '↓ ${((values.first - values.last) / values.first * 100).toStringAsFixed(1)}% Market Dip',
                    style: TextStyle(
                      color: values.last >= values.first ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBarChart(List<String> months, List<double> values) {
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    return SizedBox(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(months.length, (index) {
          final value = values[index];
          // Use relative scaling to highlight differences
          final heightPercent = range == 0 ? 0.6 : ((value - minValue) / range * 0.7 + 0.15);

          return Expanded(
            child: AnimatedBuilder(
              animation: _animController,
              builder: (context, child) {
                final animatedHeight = heightPercent * 120 * _animController.value;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      value.toStringAsFixed(0),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 28,
                      height: animatedHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF10B981),
                            const Color(0xFF10B981).withOpacity(0.4),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF10B981).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      months[index],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInsightsCard(List insights) {
    return _buildGlassContainer(
      sigma: 15,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Color(0xFFFBBF24), size: 24),
                SizedBox(width: 12),
                Text(
                  'Expert Market Insights',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...insights.map((insight) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFFBBF24),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          insight.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.7),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(Map<String, dynamic> car, int rank, int totalCars) {
    final maxSales = _showNewCars ? 25000 : 10000;
    final sales = (car['sales'] as num?)?.toInt() ?? 0;
    final salesPercentage = (sales / maxSales).clamp(0.0, 1.0);
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
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildGlassContainer(
          sigma: 10,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF6C63FF).withOpacity(rank <= 3 ? 0.3 : 0.1),
                            const Color(0xFF3F3D9E).withOpacity(rank <= 3 ? 0.2 : 0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF6C63FF).withOpacity(rank <= 3 ? 0.3 : 0.1),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: rank <= 3 ? const Color(0xFF6C63FF) : Colors.white24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            car['name'] as String? ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            car['segment'] as String? ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444)).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 12,
                            color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${priceChange.abs().toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Monthly Sales Volume',
                      style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5)),
                    ),
                    Text(
                      _formatSales(sales),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: salesPercentage,
                    backgroundColor: Colors.white.withOpacity(0.05),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      const Color(0xFF10B981).withOpacity(0.8),
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Average Market Price',
                      style: TextStyle(fontSize: 13, color: Colors.white.withOpacity(0.5)),
                    ),
                    Text(
                      _formatPrice(avgPrice),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
