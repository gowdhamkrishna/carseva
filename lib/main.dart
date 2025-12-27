import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'package:carseva/core/api/ai_client.dart';
import 'package:carseva/core/bloc/theme_bloc.dart';
import 'package:carseva/config/theme/Theme.dart';

import 'package:carseva/features/auth/data/repositories/auth_implement.dart';
import 'package:carseva/features/auth/domain/usecases/google_login.dart';
import 'package:carseva/features/auth/domain/usecases/login_usecase.dart';
import 'package:carseva/features/auth/domain/usecases/register.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:carseva/features/auth/presentation/bloc/auth_event.dart';

import 'package:carseva/features/voice_search/data/repositories/iimple.dart';
import 'package:carseva/features/voice_search/domain/prompts/system_prompt.dart';
import 'package:carseva/features/voice_search/domain/usecase/generate_text.dart';
import 'package:carseva/features/voice_search/presentation/bloc/gemini_bloc_bloc.dart';

import 'package:carseva/features/car_market/data/repositories/market_repository_impl.dart';
import 'package:carseva/features/car_market/domain/usecases/get_trending_cars.dart';
import 'package:carseva/features/car_market/domain/usecases/get_market_insights.dart';
import 'package:carseva/features/car_market/domain/usecases/predict_availability.dart';
import 'package:carseva/features/car_market/domain/usecases/get_price_prediction.dart';
import 'package:carseva/features/car_market/presentation/bloc/market_bloc.dart';

import 'package:carseva/carinfo/data/datasource/data_source.dart';
import 'package:carseva/carinfo/domain/repositories/implem.dart';
import 'package:carseva/carinfo/domain/usecases/get_current_car.dart';
import 'package:carseva/carinfo/domain/usecases/save_current.dart';
import 'package:carseva/core/user_profile/bloc/user_profile_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:carseva/features/diagnostics/data/datasources/diagnostic_ai_service.dart';
import 'package:carseva/features/diagnostics/data/repositories/diagnostic_repository_impl.dart';
import 'package:carseva/features/diagnostics/domain/usecases/analyze_symptoms.dart';
import 'package:carseva/features/diagnostics/domain/usecases/get_diagnostic_history.dart';

import 'package:carseva/features/predictive_maintenance/data/datasources/maintenance_ai_service.dart';
import 'package:carseva/features/predictive_maintenance/data/repositories/maintenance_repository_impl.dart';
import 'package:carseva/features/predictive_maintenance/domain/usecases/predict_maintenance.dart';
import 'package:carseva/features/predictive_maintenance/domain/usecases/calculate_health_score.dart';
import 'package:carseva/features/predictive_maintenance/domain/usecases/get_service_history.dart';

import 'package:carseva/features/diagnostics/presentation/bloc/diagnostic_bloc.dart';
import 'package:carseva/features/predictive_maintenance/presentation/bloc/maintenance_bloc.dart';

import 'package:carseva/features/splashscreen/presentation/pages/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // ✅ INIT FIREBASE with DefaultFirebaseOptions
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ AI DEPENDENCY CHAIN with system prompt
  final geminiClient = GeminiClient(systemInstruction: SystemPrompt.text);
  final aiRepository = AiRepositoryImpl(geminiClient);
  final generateText = GenerateText(aiRepository);

  // ✅ MARKET DEPENDENCY CHAIN
  final marketGeminiClient = GeminiClient(); // No system prompt for market API
  final marketRepository = MarketRepositoryImpl(marketGeminiClient);
  final getTrendingCars = GetTrendingCars(marketRepository);
  final getMarketInsights = GetMarketInsights(marketRepository);
  final predictAvailability = PredictAvailability(marketRepository);
  final getPricePrediction = GetPricePrediction(marketRepository);

  // ✅ CAR INFO DEPENDENCY CHAIN
  final carInfoDataSource = UserCarRemoteDataSource(FirebaseFirestore.instance);
  final carInfoRepository = UserCarRepositoryImpl(carInfoDataSource);
  final getCurrentCar = GetCurrentCar(carInfoRepository);
  final saveCurrentCar = SaveCurrentCar(carInfoRepository);

  // ✅ DIAGNOSTIC DEPENDENCY CHAIN
  final diagnosticGeminiClient = GeminiClient();
  final diagnosticAIService = DiagnosticAIService(diagnosticGeminiClient.textModel);
  final diagnosticRepository = DiagnosticRepositoryImpl(
    aiService: diagnosticAIService,
    firestore: FirebaseFirestore.instance,
  );
  final analyzeSymptoms = AnalyzeSymptoms(diagnosticRepository);
  final getDiagnosticHistory = GetDiagnosticHistory(diagnosticRepository);

  // ✅ MAINTENANCE DEPENDENCY CHAIN
  final maintenanceGeminiClient = GeminiClient();
  final maintenanceAIService = MaintenanceAIService(maintenanceGeminiClient.textModel);
  final maintenanceRepository = MaintenanceRepositoryImpl(
    aiService: maintenanceAIService,
    firestore: FirebaseFirestore.instance,
  );
  final predictMaintenance = PredictMaintenance(maintenanceRepository);
  final calculateHealthScore = CalculateHealthScore(maintenanceRepository);
  final getServiceHistory = GetServiceHistory(maintenanceRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        // 🎨 THEME
        BlocProvider(
          create: (_) => ThemeBloc(),
        ),

        // 🤖 AI
        BlocProvider(
          create: (_) => AiBloc(generateText),
        ),

        // 📊 MARKET
        BlocProvider(
          create: (_) => MarketBloc(
            getTrendingCars: getTrendingCars,
            getMarketInsights: getMarketInsights,
            predictAvailability: predictAvailability,
            getPricePrediction: getPricePrediction,
          ),
        ),

        // 🔍 DIAGNOSTICS
        BlocProvider(
          create: (_) => DiagnosticBloc(
            analyzeSymptoms: analyzeSymptoms,
            getDiagnosticHistory: getDiagnosticHistory,
          ),
        ),

        // 🔮 MAINTENANCE
        BlocProvider(
          create: (_) => MaintenanceBloc(
            calculateHealthScore: calculateHealthScore,
            predictMaintenance: predictMaintenance,
            getServiceHistory: getServiceHistory,
          ),
        ),

        // 🔐 AUTH
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(AuthRepositoryImpl()),
            registerUseCase: RegisterUseCase(AuthRepositoryImpl()),
            googleLoginUseCase: GoogleLoginUseCase(AuthRepositoryImpl()),
          )..add(CheckAuthStatusEvent()),
        ),

        // 👤 USER PROFILE
        BlocProvider(
          create: (_) => UserProfileBloc(
            getCurrentCar: getCurrentCar,
            saveCurrentCar: saveCurrentCar,
            firebaseAuth: FirebaseAuth.instance,
          ),
        ),
      ],
      child: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;

        // update theme safely after build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<ThemeBloc>().add(
                SystemTheme(brightness == Brightness.dark),
              );
        });

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: state.isDark
              ? AppData[AppThemeData.darkTheme]
              : AppData[AppThemeData.LightTheme],
          home: const Splash(),
        );
      },
    );
  }
}
