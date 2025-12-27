import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/models/car_model.dart';
import '../bloc/market_bloc.dart';
import '../bloc/market_event.dart';
import '../bloc/market_state.dart';
import '../widgets/car_card.dart';
import '../widgets/market_filters.dart';

class MarketTrendsPage extends StatefulWidget {
  const MarketTrendsPage({super.key});

  @override
  State<MarketTrendsPage> createState() => _MarketTrendsPageState();
}

class _MarketTrendsPageState extends State<MarketTrendsPage> {
  CarType? _selectedType;
  FuelType? _selectedFuel;
  double? _minBudget;
  double? _maxBudget;

  @override
  void initState() {
    super.initState();
    context.read<MarketBloc>().add(const LoadTrendingCarsEvent());
  }

  void _applyFilters() {
    context.read<MarketBloc>().add(
          LoadTrendingCarsEvent(
            type: _selectedType,
            fuelType: _selectedFuel,
            minBudget: _minBudget,
            maxBudget: _maxBudget,
          ),
        );
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
              Color(0xFF0A0E27),
              Color(0xFF1A1F3A),
              Color(0xFF0F1535),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              MarketFilters(
                selectedType: _selectedType,
                selectedFuel: _selectedFuel,
                minBudget: _minBudget,
                maxBudget: _maxBudget,
                onTypeChanged: (type) {
                  setState(() => _selectedType = type);
                  _applyFilters();
                },
                onFuelChanged: (fuel) {
                  setState(() => _selectedFuel = fuel);
                  _applyFilters();
                },
                onBudgetChanged: (min, max) {
                  setState(() {
                    _minBudget = min;
                    _maxBudget = max;
                  });
                  _applyFilters();
                },
              ),
              Expanded(
                child: BlocBuilder<MarketBloc, MarketState>(
                  builder: (context, state) {
                    if (state is MarketLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      );
                    }

                    if (state is MarketError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 64,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              state.message,
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _applyFilters,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state is TrendingCarsLoaded) {
                      if (state.cars.isEmpty) {
                        return const Center(
                          child: Text(
                            'No cars found matching your filters',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.cars.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: CarCard(car: state.cars[index]),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.trending_up, color: Color(0xFF6C63FF), size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Market Trends',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.insights, color: Color(0xFF6C63FF)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MarketInsightsPage(),
                ),
              );
            },
            tooltip: 'Market Insights',
          ),
        ],
      ),
    );
  }
}

// Placeholder for MarketInsightsPage - we'll create it separately
class MarketInsightsPage extends StatelessWidget {
  const MarketInsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Insights'),
      ),
      body: const Center(
        child: Text('Market Insights Page'),
      ),
    );
  }
}

