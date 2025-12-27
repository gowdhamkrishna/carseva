# User Vehicle Profile Integration Guide

## Setup in main.dart

### 1. Add UserProfileBloc to App

```dart
import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_event.dart';
import 'package:carseva/carinfo/domain/usecases/get_current_car.dart';
import 'package:carseva/carinfo/domain/usecases/save_current.dart';
import 'package:firebase_auth/firebase_auth.dart';

// In your main app widget
MultiBlocProvider(
  providers: [
    // Existing providers
    BlocProvider(create: (_) => AuthBloc(...)),
    
    // Add UserProfileBloc
    BlocProvider(
      create: (context) => UserProfileBloc(
        getCurrentCar: GetCurrentCar(repository),
        saveCurrentCar: SaveCurrentCar(repository),
        firebaseAuth: FirebaseAuth.instance,
      ),
    ),
  ],
  child: YourApp(),
)
```

### 2. Initialize on Login

```dart
// In your auth success handler
BlocListener<AuthBloc, AuthBlocState>(
  listener: (context, state) {
    if (state is AuthSuccessState) {
      // Initialize user profile
      context.read<UserProfileBloc>().add(
        InitializeUserProfileEvent(state.user.uid),
      );
    }
  },
)
```

### 3. Clear on Logout

```dart
// In your logout handler
void logout() {
  context.read<UserProfileBloc>().add(ClearProfileEvent());
  context.read<AuthBloc>().add(LogoutEvent());
}
```

---

## Usage Examples

### Access Vehicle Data Anywhere

```dart
// Method 1: Using BlocBuilder
BlocBuilder<UserProfileBloc, UserProfileState>(
  builder: (context, state) {
    if (state is UserProfileLoaded) {
      final vehicle = state.vehicle;
      return Text('${vehicle.vehicle.brand} ${vehicle.vehicle.model}');
    }
    return Text('No vehicle');
  },
)

// Method 2: Using helper widget
VehicleDataBuilder(
  builder: (context, vehicle) {
    return Text('${vehicle.vehicle.brand} ${vehicle.vehicle.model}');
  },
  noVehicleWidget: Text('Please add your vehicle'),
)

// Method 3: Direct access (non-reactive)
final bloc = context.read<UserProfileBloc>();
final vehicle = bloc.currentProfile?.vehicle;
```

### Display Vehicle Summary

```dart
// Use pre-built widget
VehicleSummaryCard()
```

### Predictive Maintenance

```dart
import 'package:carseva/core/user_profile/utils/predictive_maintenance.dart';

// Get next service date
final bloc = context.read<UserProfileBloc>();
final nextService = PredictiveMaintenanceHelper.calculateNextService(bloc);

// Check insurance expiry
final isExpiring = PredictiveMaintenanceHelper.isInsuranceExpiringSoon(bloc);

// Get all alerts
final alerts = PredictiveMaintenanceHelper.getMaintenanceAlerts(bloc);

// Display alerts widget
MaintenanceAlertsWidget()
```

### Update Vehicle

```dart
// After user updates vehicle info
context.read<UserProfileBloc>().add(
  UpdateVehicleEvent(
    userId: currentUserId,
    vehicle: updatedVehicleEntity,
  ),
);
```

### Refresh Vehicle Data

```dart
// Pull latest from Firestore
context.read<UserProfileBloc>().add(
  RefreshVehicleEvent(currentUserId),
);
```

---

## Example: Home Page Integration

```dart
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Show vehicle summary
          VehicleSummaryCard(),
          
          // Show maintenance alerts
          MaintenanceAlertsWidget(),
          
          // Custom vehicle-based content
          VehicleDataBuilder(
            builder: (context, vehicle) {
              return Column(
                children: [
                  Text('Next Service: ${vehicle.service.nextServiceDueKm} km'),
                  Text('Insurance: ${vehicle.insurance.provider}'),
                  Text('Odometer: ${vehicle.usage.odometerKm} km'),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
```

---

## Example: Predictive Maintenance Page

```dart
class PredictiveMaintenancePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserProfileBloc>();
    
    return Scaffold(
      appBar: AppBar(title: Text('Predictive Maintenance')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Service status
            _buildServiceStatus(bloc),
            
            // All alerts
            MaintenanceAlertsWidget(),
            
            // Detailed vehicle info
            VehicleSummaryCard(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildServiceStatus(UserProfileBloc bloc) {
    final status = PredictiveMaintenanceHelper.getServiceStatus(bloc);
    final nextService = PredictiveMaintenanceHelper.calculateNextService(bloc);
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Service Status: $status'),
            if (nextService != null)
              Text('Next Service: ${nextService.toString()}'),
          ],
        ),
      ),
    );
  }
}
```

---

## State Flow

```
Login → InitializeUserProfileEvent → UserProfileLoaded
  ↓
User updates vehicle → UpdateVehicleEvent → VehicleUpdated → UserProfileLoaded
  ↓
Logout → ClearProfileEvent → UserProfileInitial
```

---

## Benefits

1. **Global Access**: Vehicle data available anywhere via BLoC
2. **Auto-Sync**: Automatically loads/clears with auth state
3. **Type-Safe**: Full type safety with existing models
4. **Predictive**: Built-in maintenance calculations
5. **Reactive**: UI updates automatically when data changes
6. **Persistent**: Stored in Firestore, survives restarts
