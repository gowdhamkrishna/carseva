
import 'package:flutter_test/flutter_test.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:carseva/features/market_trends/data/market_analysis_ai_service.dart';

// Mock Implementation of GenerativeAIClient
class MockGenerativeAIClient implements GenerativeAIClient {
  final Future<GenerateContentResponse> Function(Iterable<Content> prompt)? onGenerateContent;

  MockGenerativeAIClient({this.onGenerateContent});

  @override
  Future<GenerateContentResponse> generateContent(Iterable<Content> prompt) async {
    if (onGenerateContent != null) {
      return onGenerateContent!(prompt);
    }
    throw UnimplementedError();
  }
}

void main() {
  group('MarketAnalysisAIService', () {
    test('getMarketTrends throws exception on API failure', () async {
      final mockClient = MockGenerativeAIClient(
        onGenerateContent: (prompt) async {
          throw Exception('API Error');
        },
      );
      final service = MarketAnalysisAIService(mockClient);

      expect(
        () => service.getMarketTrends(segment: 'new'),
        throwsA(isA<Exception>()),
      );
    });

    test('getMarketTrends throws exception on invalid JSON', () async {
      final response = GenerateContentResponse(
        [Candidate(
          Content.text('Invalid JSON'),
          null,
          null,
          null,
          null,
        )],
        null,
      );

      final mockClient = MockGenerativeAIClient(
        onGenerateContent: (prompt) async => response,
      );
      final service = MarketAnalysisAIService(mockClient);

      expect(
        () => service.getMarketTrends(segment: 'new'),
        throwsA(isA<Exception>()),
      );
    });

    test('getMarketTrends returns valid data on success', () async {
      final validJson = '''
      {
        "topCars": [],
        "priceTrend": {
          "months": [],
          "values": []
        },
        "insights": []
      }
      ''';
      
      final response = GenerateContentResponse(
        [Candidate(
          Content.text('```json\n$validJson\n```'),
          null,
          null,
          null,
          null,
        )],
        null,
      );

      final mockClient = MockGenerativeAIClient(
        onGenerateContent: (prompt) async => response,
      );
      final service = MarketAnalysisAIService(mockClient);

      final result = await service.getMarketTrends(segment: 'new');

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('topCars'), true);
    });
  });
}
