import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Example: Predictive Maintenance Calculator
class PredictiveMaintenanceHelper {
  /// Calculate next service date based on vehicle data
  static DateTime? calculateNextService(UserProfileBloc bloc) {
    final state = bloc.state;
    if (state is! UserProfileLoaded) return null;

    final vehicle = state.vehicle;
    if (vehicle == null) return null;

    final odometerKm = vehicle.usage.odometerKm;
    final nextServiceDueKm = vehicle.service.nextServiceDueKm;
    final dailyAverage = vehicle.usage.dailyAverageKm;

    // Calculate based on odometer
    final kmUntilService = nextServiceDueKm - odometerKm;
    if (kmUntilService <= 0) return DateTime.now();

    // Estimate days until service
    final daysUntilService = (kmUntilService / dailyAverage).ceil();

    return DateTime.now().add(Duration(days: daysUntilService));
  }

  /// Check if insurance is expiring soon (within 30 days)
  static bool isInsuranceExpiringSoon(UserProfileBloc bloc) {
    final state = bloc.state;
    if (state is! UserProfileLoaded) return false;

    final vehicle = state.vehicle;
    if (vehicle == null) return false;

    final expiryDate = vehicle.insurance.policyExpiry;
    final daysUntilExpiry = expiryDate.difference(DateTime.now()).inDays;

    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  /// Get service status
  static String getServiceStatus(UserProfileBloc bloc) {
    final nextService = calculateNextService(bloc);
    if (nextService == null) return 'Unknown';

    final daysUntil = nextService.difference(DateTime.now()).inDays;

    if (daysUntil < 0) return 'Overdue';
    if (daysUntil <= 7) return 'Due Soon';
    if (daysUntil <= 30) return 'Upcoming';
    return 'On Track';
  }

  /// Get maintenance alerts
  static List<MaintenanceAlert> getMaintenanceAlerts(UserProfileBloc bloc) {
    final alerts = <MaintenanceAlert>[];
    final state = bloc.state;

    if (state is! UserProfileLoaded) return alerts;
    final vehicle = state.vehicle;
    if (vehicle == null) return alerts;

    // Check service
    final nextService = calculateNextService(bloc);
    if (nextService != null) {
      final daysUntil = nextService.difference(DateTime.now()).inDays;
      if (daysUntil <= 7) {
        alerts.add(MaintenanceAlert(
          type: AlertType.service,
          title: 'Service Due Soon',
          message: 'Your next service is due in $daysUntil days',
          priority: daysUntil < 0 ? AlertPriority.high : AlertPriority.medium,
          dueDate: nextService,
        ));
      }
    }

    // Check insurance
    if (isInsuranceExpiringSoon(bloc)) {
      final expiryDate = vehicle.insurance.policyExpiry;
      final daysUntil = expiryDate.difference(DateTime.now()).inDays;
      alerts.add(MaintenanceAlert(
        type: AlertType.insurance,
        title: 'Insurance Expiring',
        message: 'Your insurance expires in $daysUntil days',
        priority: daysUntil <= 7 ? AlertPriority.high : AlertPriority.medium,
        dueDate: expiryDate,
      ));
    }

    // Check odometer-based maintenance
    final odometerKm = vehicle.usage.odometerKm;
    final nextServiceDueKm = vehicle.service.nextServiceDueKm;
    if (odometerKm >= nextServiceDueKm - 500) {
      alerts.add(MaintenanceAlert(
        type: AlertType.odometer,
        title: 'Odometer Milestone',
        message: 'Approaching ${nextServiceDueKm}km service milestone',
        priority: AlertPriority.low,
      ));
    }

    return alerts;
  }
}

enum AlertType { service, insurance, odometer }

enum AlertPriority { low, medium, high }

class MaintenanceAlert {
  final AlertType type;
  final String title;
  final String message;
  final AlertPriority priority;
  final DateTime? dueDate;

  MaintenanceAlert({
    required this.type,
    required this.title,
    required this.message,
    required this.priority,
    this.dueDate,
  });

  Color get color {
    switch (priority) {
      case AlertPriority.high:
        return const Color(0xFFFF6584);
      case AlertPriority.medium:
        return const Color(0xFFFF9800);
      case AlertPriority.low:
        return const Color(0xFF6C63FF);
    }
  }

  IconData get icon {
    switch (type) {
      case AlertType.service:
        return Icons.build_circle;
      case AlertType.insurance:
        return Icons.shield;
      case AlertType.odometer:
        return Icons.speed;
    }
  }
}

/// Widget to display maintenance alerts
class MaintenanceAlertsWidget extends StatelessWidget {
  const MaintenanceAlertsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    final alerts = PredictiveMaintenanceHelper.getMaintenanceAlerts(bloc);

    if (alerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Maintenance Alerts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...alerts.map((alert) => _buildAlertCard(alert)),
      ],
    );
  }

  Widget _buildAlertCard(MaintenanceAlert alert) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            alert.color.withOpacity(0.2),
            alert.color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: alert.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: alert.color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(alert.icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.message,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
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
}
