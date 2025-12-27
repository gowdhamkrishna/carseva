import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

import 'package:carseva/features/splashscreen/presentation/pages/splash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // ✅ INIT FIREBASE
  await Firebase.initializeApp();

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

        // 🔐 AUTH
        BlocProvider(
          create: (_) => AuthBloc(
            loginUseCase: LoginUseCase(AuthRepositoryImpl()),
            registerUseCase: RegisterUseCase(AuthRepositoryImpl()),
            googleLoginUseCase: GoogleLoginUseCase(AuthRepositoryImpl()),
          )..add(CheckAuthStatusEvent()),
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
