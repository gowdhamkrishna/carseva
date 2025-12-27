# Car Info UI Model - Documentation

## Overview
Complete presentation layer for managing user car details with BLoC pattern, including a comprehensive UI model for form handling and validation.

## Architecture

### Files Created
```
carinfo/presentation/
├── bloc/
│   ├── car_info_bloc.dart      # Main BLoC managing state
│   ├── car_info_event.dart     # Events (Load, Save, Clear)
│   └── car_info_state.dart     # States (Initial, Loading, Loaded, etc.)
├── models/
│   └── car_ui_model.dart       # UI model with validation
└── examples/
    └── car_info_example.dart   # Example usage widget
```

## CarUIModel Features

### 1. Mutable Fields for Forms
All car information fields are mutable for easy form binding:
- **Vehicle Info**: brand, model, variant, year, fuelType, transmission
- **Registration**: registrationNumber, state, city
- **Ownership**: purchaseDate, purchasePrice, ownershipType, isFinanced
- **Usage**: odometerKm, dailyAverageKm, usageType
- **Service**: lastServiceDate, nextServiceDueKm, serviceCenter
- **Insurance**: insuranceProvider, policyExpiry, policyType

### 2. Entity Conversion
```dart
// From domain entity to UI model
final uiModel = CarUIModel.fromEntity(carEntity);

// From UI model to domain entity
final entity = uiModel.toEntity();
```

### 3. Validation
```dart
// Check if all required fields are valid
if (carModel.isValid()) {
  // Save the car
}

// Get detailed validation errors
final errors = carModel.getValidationErrors();
// Returns: Map<String, String> with field names and error messages
```

### 4. State Management
```dart
// Create a copy with modified fields
final updated = carModel.copyWith(
  brand: 'Toyota',
  model: 'Camry',
);
```

## BLoC Usage

### Setup
```dart
// In your widget tree (usually in main.dart or a provider setup)
BlocProvider(
  create: (context) => CarInfoBloc(
    getCurrentCar: GetCurrentCar(repository),
    saveCurrentCar: SaveCurrentCar(repository),
  ),
  child: YourApp(),
)
```

### Load Car Info
```dart
context.read<CarInfoBloc>().add(LoadCarInfoEvent(userId));
```

### Save Car Info
```dart
final carEntity = carModel.toEntity();
context.read<CarInfoBloc>().add(
  SaveCarInfoEvent(
    userId: userId,
    car: carEntity,
  ),
);
```

### Listen to State Changes
```dart
BlocConsumer<CarInfoBloc, CarInfoState>(
  listener: (context, state) {
    if (state is CarInfoSavedState) {
      // Show success message
    } else if (state is CarInfoErrorState) {
      // Show error message
    }
  },
  builder: (context, state) {
    if (state is CarInfoLoadingState) {
      return CircularProgressIndicator();
    }
    // Build your form
  },
)
```

## Example Usage

See [car_info_example.dart](file:///home/gowdham/carseva/carseva/lib/carinfo/presentation/examples/car_info_example.dart) for a complete working example with:
- Form handling
- Validation
- BLoC integration
- State management
- Error handling

## States

| State | Description |
|-------|-------------|
| `CarInfoInitialState` | Initial state, no data loaded |
| `CarInfoLoadingState` | Loading or saving in progress |
| `CarInfoLoadedState` | Car data successfully loaded |
| `CarInfoEmptyState` | No car data found for user |
| `CarInfoSavedState` | Car data successfully saved |
| `CarInfoErrorState` | Error occurred with message |

## Events

| Event | Parameters | Description |
|-------|-----------|-------------|
| `LoadCarInfoEvent` | `userId` | Load car info for user |
| `SaveCarInfoEvent` | `userId`, `car` | Save car info for user |
| `ClearCarInfoEvent` | None | Clear current state |

## Integration Steps

1. **Add BLoC Provider** in your app's widget tree
2. **Create CarUIModel** instance in your form widget
3. **Bind form fields** to CarUIModel properties
4. **Validate** using `isValid()` or `getValidationErrors()`
5. **Convert to entity** using `toEntity()`
6. **Dispatch SaveCarInfoEvent** to save data
7. **Listen to state changes** to show feedback

## Validation Rules

All fields are validated for:
- Non-empty strings for text fields
- Valid year (> 1900)
- Proper data types

Use `getValidationErrors()` to get specific error messages for each field.
