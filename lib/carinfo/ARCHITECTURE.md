# Car Info Module - Architecture

## Layer Architecture

```mermaid
graph TB
    subgraph "Presentation Layer"
        UI[UI Widgets]
        UIModel[CarUIModel]
        Bloc[CarInfoBloc]
        Events[Events]
        States[States]
    end
    
    subgraph "Domain Layer"
        Entity[UserCarEntity]
        UseCases[Use Cases]
        Repo[UserCarRepository]
    end
    
    subgraph "Data Layer"
        RepoImpl[Repository Implementation]
        DataSource[Remote Data Source]
        Models[Data Models]
        Firestore[(Firestore)]
    end
    
    UI --> UIModel
    UI --> Bloc
    Bloc --> Events
    Bloc --> States
    Bloc --> UseCases
    UIModel --> Entity
    UseCases --> Repo
    Repo --> RepoImpl
    RepoImpl --> DataSource
    DataSource --> Models
    DataSource --> Firestore
    Models --> Entity
```

## Data Flow

### Saving Car Info
```mermaid
sequenceDiagram
    participant UI
    participant UIModel as CarUIModel
    participant Bloc as CarInfoBloc
    participant UseCase as SaveCurrentCar
    participant Repo as Repository
    participant DS as DataSource
    participant FB as Firestore
    
    UI->>UIModel: Update fields
    UI->>UIModel: Validate
    UIModel->>UIModel: isValid()
    UIModel->>Bloc: SaveCarInfoEvent
    Bloc->>UIModel: toEntity()
    UIModel-->>Bloc: UserCarEntity
    Bloc->>UseCase: call(userId, entity)
    UseCase->>Repo: saveCurrentCar()
    Repo->>DS: saveCar(userId, model)
    DS->>FB: set(document)
    FB-->>DS: Success
    DS-->>Repo: Success
    Repo-->>UseCase: Success
    UseCase-->>Bloc: Success
    Bloc->>UI: CarInfoSavedState
```

### Loading Car Info
```mermaid
sequenceDiagram
    participant UI
    participant Bloc as CarInfoBloc
    participant UseCase as GetCurrentCar
    participant Repo as Repository
    participant DS as DataSource
    participant FB as Firestore
    
    UI->>Bloc: LoadCarInfoEvent
    Bloc->>UseCase: call(userId)
    UseCase->>Repo: getCurrentCar()
    Repo->>DS: getCar(userId)
    DS->>FB: get(document)
    FB-->>DS: Document data
    DS->>DS: fromFirestore()
    DS-->>Repo: UserCarModel
    Repo-->>UseCase: UserCarEntity
    UseCase-->>Bloc: UserCarEntity
    Bloc->>UI: CarInfoLoadedState
    UI->>UI: CarUIModel.fromEntity()
```

## File Structure

```
carinfo/
├── data/
│   ├── datasource/
│   │   └── data_source.dart          # Firestore operations
│   └── models/
│       └── user_model.dart            # Data models with serialization
├── domain/
│   ├── entities/
│   │   └── car_entity.dart            # Domain entity
│   ├── repositories/
│   │   ├── repo_car_firebase.dart     # Repository interface
│   │   └── implem.dart                # Repository implementation
│   ├── usecases/
│   │   ├── get_current_car.dart       # Get use case
│   │   └── save_current.dart          # Save use case
│   └── [entity files]                 # Individual entity classes
└── presentation/
    ├── bloc/
    │   ├── car_info_bloc.dart         # BLoC implementation
    │   ├── car_info_event.dart        # Event definitions
    │   └── car_info_state.dart        # State definitions
    ├── models/
    │   └── car_ui_model.dart          # UI model with validation
    ├── examples/
    │   └── car_info_example.dart      # Example widget
    └── README.md                       # Documentation
```
