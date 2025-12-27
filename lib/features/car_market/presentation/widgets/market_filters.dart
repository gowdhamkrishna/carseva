import 'package:flutter/material.dart';
import '../../domain/models/car_model.dart';

class MarketFilters extends StatefulWidget {
  final CarType? selectedType;
  final FuelType? selectedFuel;
  final double? minBudget;
  final double? maxBudget;
  final Function(CarType?) onTypeChanged;
  final Function(FuelType?) onFuelChanged;
  final Function(double?, double?) onBudgetChanged;

  const MarketFilters({
    super.key,
    this.selectedType,
    this.selectedFuel,
    this.minBudget,
    this.maxBudget,
    required this.onTypeChanged,
    required this.onFuelChanged,
    required this.onBudgetChanged,
  });

  @override
  State<MarketFilters> createState() => _MarketFiltersState();
}

class _MarketFiltersState extends State<MarketFilters> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTypeFilter(),
                const SizedBox(width: 8),
                _buildFuelFilter(),
                const SizedBox(width: 8),
                _buildBudgetFilter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeFilter() {
    return PopupMenuButton<CarType?>(
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.selectedType != null
              ? const Color(0xFF6C63FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.selectedType != null
                ? const Color(0xFF6C63FF)
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.category, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.selectedType?.displayName ?? 'Type',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Types'),
        ),
        ...CarType.values.map((type) => PopupMenuItem(
              value: type,
              child: Text(type.displayName),
            )),
      ],
      onSelected: widget.onTypeChanged,
    );
  }

  Widget _buildFuelFilter() {
    return PopupMenuButton<FuelType?>(
      offset: const Offset(0, 40),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: widget.selectedFuel != null
              ? const Color(0xFF6C63FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: widget.selectedFuel != null
                ? const Color(0xFF6C63FF)
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.local_gas_station, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              widget.selectedFuel?.displayName ?? 'Fuel',
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Fuels'),
        ),
        ...FuelType.values.map((fuel) => PopupMenuItem(
              value: fuel,
              child: Text(fuel.displayName),
            )),
      ],
      onSelected: widget.onFuelChanged,
    );
  }

  Widget _buildBudgetFilter() {
    return InkWell(
      onTap: () => _showBudgetDialog(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: (widget.minBudget != null || widget.maxBudget != null)
              ? const Color(0xFF6C63FF).withOpacity(0.2)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: (widget.minBudget != null || widget.maxBudget != null)
                ? const Color(0xFF6C63FF)
                : Colors.white.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.attach_money, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              _getBudgetText(),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: Colors.white, size: 20),
          ],
        ),
      ),
    );
  }

  String _getBudgetText() {
    if (widget.minBudget == null && widget.maxBudget == null) {
      return 'Budget';
    }
    String min = widget.minBudget != null
        ? '₹${(widget.minBudget! / 100000).toStringAsFixed(1)}L'
        : 'Any';
    String max = widget.maxBudget != null
        ? '₹${(widget.maxBudget! / 100000).toStringAsFixed(1)}L'
        : 'Any';
    return '$min - $max';
  }

  void _showBudgetDialog() {
    final minController = TextEditingController(
      text: widget.minBudget != null
          ? (widget.minBudget! / 100000).toStringAsFixed(1)
          : '',
    );
    final maxController = TextEditingController(
      text: widget.maxBudget != null
          ? (widget.maxBudget! / 100000).toStringAsFixed(1)
          : '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1F3A),
        title: const Text(
          'Budget Range (in Lakhs)',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Min Price',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C63FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: maxController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Max Price',
                labelStyle: TextStyle(color: Colors.white70),
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C63FF)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              widget.onBudgetChanged(null, null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          ElevatedButton(
            onPressed: () {
              final min = minController.text.isNotEmpty
                  ? double.tryParse(minController.text) ?? 0
                  : null;
              final max = maxController.text.isNotEmpty
                  ? double.tryParse(maxController.text) ?? 0
                  : null;
              widget.onBudgetChanged(
                min != null ? min * 100000 : null,
                max != null ? max * 100000 : null,
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}


