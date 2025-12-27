import 'dart:convert';

import 'package:carseva/core/api/ai_client.dart';
import 'package:carseva/features/car_market/domain/models/availability_prediction.dart';
import 'package:carseva/features/car_market/domain/models/car_model.dart';
import 'package:carseva/features/car_market/domain/repositories/market_repository.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class MarketRepositoryImpl implements MarketRepository {
  final GeminiClient geminiClient;

  MarketRepositoryImpl(this.geminiClient);

  @override
  Future<List<CarModel>> getTrendingCars({
    CarType? type,
    FuelType? fuelType,
    double? minBudget,
    double? maxBudget,
  }) async {
    String prompt = '''Generate a JSON array of 8-12 trending cars in the Indian market. 
For each car, provide:
- name: Car model name (e.g., "Honda City")
- brand: Brand name (e.g., "Honda")
- type: One of ["hatchback", "sedan", "suv", "ev"]
- fuelType: One of ["petrol", "diesel", "electric", "hybrid", "cng"]
- basePrice: Base price in lakhs (number)
- currentPrice: Current discounted price in lakhs (number, optional)
- mileage: Average mileage in km/l (number)
- resaleValue: Resale value percentage after 3 years (number between 60-80)
- launchYear: Year launched (number)
- isNewLaunch: Boolean if launched in last 6 months
- trend: One of ["highDemand", "priceDrop", "newLaunch", "goodValue", "stable"]
- imageUrl: A placeholder URL or description

Apply filters:
${type != null ? '- type: ${type.name}' : ''}
${fuelType != null ? '- fuelType: ${fuelType.name}' : ''}
${minBudget != null ? '- minimum price: ₹${minBudget.toStringAsFixed(1)}L' : ''}
${maxBudget != null ? '- maximum price: ₹${maxBudget.toStringAsFixed(1)}L' : ''}

Return ONLY valid JSON array, no markdown, no explanation. Example format:
[
  {
    "name": "Honda City",
    "brand": "Honda",
    "type": "sedan",
    "fuelType": "petrol",
    "basePrice": 12.5,
    "currentPrice": 11.8,
    "mileage": 17.8,
    "resaleValue": 72,
    "launchYear": 2023,
    "isNewLaunch": false,
    "trend": "highDemand",
    "imageUrl": "honda_city"
  }
]''';

    try {
      final response = await geminiClient.textModel.generateContent([
        Content.text(prompt),
      ]);

      String responseText = response.text ?? '[]';
      // Clean response - remove markdown code blocks if present
      responseText = responseText.replaceAll(RegExp(r'```json\n?'), '');
      responseText = responseText.replaceAll(RegExp(r'```\n?'), '');
      responseText = responseText.trim();

      final List<dynamic> jsonList = jsonDecode(responseText);
      return jsonList.map((json) => _carFromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch trending cars: $e');
    }
  }

  @override
  Future<String> getMarketInsights({
    CarType? type,
    String? city,
  }) async {
    String prompt = '''Provide comprehensive market insights for the Indian car market.
${type != null ? 'Focus on ${type.displayName} segment.' : 'Cover all segments.'}
${city != null ? 'Focus on $city market trends.' : 'Cover pan-India trends.'}

Include:
1. Current market trends (high demand segments, price movements)
2. Popular fuel types and their market share
3. Budget segments showing growth
4. Emerging trends (EV adoption, hybrid popularity)
5. Seasonal factors affecting prices
6. Regional variations if applicable

Keep response concise (300-400 words), structured, and actionable.''';

    final response = await geminiClient.textModel.generateContent([
      Content.text(prompt),
    ]);

    return response.text ?? 'Unable to generate market insights.';
  }

  @override
  Future<AvailabilityPrediction> predictAvailability({
    required String carModel,
    required String area,
    required String city,
    String? pincode,
  }) async {
    String prompt = '''Predict car availability for:
- Car Model: $carModel
- Area: $area
- City: $city
${pincode != null ? '- Pincode: $pincode' : ''}

Return a JSON object with:
- demandLevel: One of ["high", "medium", "low"]
- availabilityLikelihood: Number between 0.0 and 1.0 (probability)
- expectedWaitingPeriod: Number of days (0 if available immediately)
- insights: Brief explanation (2-3 sentences) about availability factors

Return ONLY valid JSON, no markdown. Example:
{
  "demandLevel": "high",
  "availabilityLikelihood": 0.3,
  "expectedWaitingPeriod": 45,
  "insights": "High demand in this area with limited inventory. Expect 4-6 weeks waiting period due to popular variant preference."
}''';

    try {
      final response = await geminiClient.textModel.generateContent([
        Content.text(prompt),
      ]);

      String responseText = response.text ?? '{}';
      responseText = responseText.replaceAll(RegExp(r'```json\n?'), '');
      responseText = responseText.replaceAll(RegExp(r'```\n?'), '');
      responseText = responseText.trim();

      final Map<String, dynamic> json = jsonDecode(responseText);

      return AvailabilityPrediction(
        carModelId: carModel.toLowerCase().replaceAll(' ', '_'),
        carName: carModel,
        area: area,
        city: city,
        pincode: pincode,
        demandLevel: _parseDemandLevel(json['demandLevel']),
        availabilityLikelihood: (json['availabilityLikelihood'] as num).toDouble(),
        expectedWaitingPeriod: json['expectedWaitingPeriod'] as int,
        insights: json['insights'] as String?,
      );
    } catch (e) {
      throw Exception('Failed to predict availability: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPricePrediction({
    required String carModel,
    required String city,
  }) async {
    String prompt = '''Provide price prediction for $carModel in $city.

Return JSON with:
- currentPrice: Current average price in lakhs (number)
- predictedPrice: Predicted price in 3 months (number)
- priceTrend: One of ["increasing", "decreasing", "stable"]
- factors: Array of 3-4 key factors affecting price (strings)
- recommendation: Brief buying recommendation (string, 1-2 sentences)

Return ONLY valid JSON, no markdown. Example:
{
  "currentPrice": 12.5,
  "predictedPrice": 12.8,
  "priceTrend": "increasing",
  "factors": ["High demand", "New variant launch", "Festival season"],
  "recommendation": "Prices expected to rise. Consider purchasing soon for best value."
}''';

    try {
      final response = await geminiClient.textModel.generateContent([
        Content.text(prompt),
      ]);

      String responseText = response.text ?? '{}';
      responseText = responseText.replaceAll(RegExp(r'```json\n?'), '');
      responseText = responseText.replaceAll(RegExp(r'```\n?'), '');
      responseText = responseText.trim();

      return jsonDecode(responseText) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to get price prediction: $e');
    }
  }

  CarModel _carFromJson(Map<String, dynamic> json) {
    return CarModel(
      id: (json['name'] as String).toLowerCase().replaceAll(' ', '_'),
      name: json['name'] as String,
      brand: json['brand'] as String,
      type: _parseCarType(json['type'] as String),
      fuelType: _parseFuelType(json['fuelType'] as String),
      basePrice: (json['basePrice'] as num).toDouble() * 100000, // Convert lakhs to rupees
      currentPrice: json['currentPrice'] != null 
          ? (json['currentPrice'] as num).toDouble() * 100000 
          : null,
      imageUrl: json['imageUrl'] as String? ?? 'car_placeholder',
      mileage: (json['mileage'] as num).toDouble(),
      resaleValue: (json['resaleValue'] as num).toDouble(),
      launchYear: json['launchYear'] as int,
      isNewLaunch: json['isNewLaunch'] as bool? ?? false,
      trend: _parseTrend(json['trend'] as String),
    );
  }

  CarType _parseCarType(String type) {
    switch (type.toLowerCase()) {
      case 'hatchback':
        return CarType.hatchback;
      case 'sedan':
        return CarType.sedan;
      case 'suv':
        return CarType.suv;
      case 'ev':
      case 'electric':
        return CarType.ev;
      default:
        return CarType.sedan;
    }
  }

  FuelType _parseFuelType(String fuel) {
    switch (fuel.toLowerCase()) {
      case 'petrol':
        return FuelType.petrol;
      case 'diesel':
        return FuelType.diesel;
      case 'electric':
        return FuelType.electric;
      case 'hybrid':
        return FuelType.hybrid;
      case 'cng':
        return FuelType.cng;
      default:
        return FuelType.petrol;
    }
  }

  MarketTrend _parseTrend(String trend) {
    switch (trend.toLowerCase()) {
      case 'highdemand':
        return MarketTrend.highDemand;
      case 'pricedrop':
        return MarketTrend.priceDrop;
      case 'newlaunch':
        return MarketTrend.newLaunch;
      case 'goodvalue':
        return MarketTrend.goodValue;
      case 'stable':
        return MarketTrend.stable;
      default:
        return MarketTrend.stable;
    }
  }

  DemandLevel _parseDemandLevel(String level) {
    switch (level.toLowerCase()) {
      case 'high':
        return DemandLevel.high;
      case 'medium':
        return DemandLevel.medium;
      case 'low':
        return DemandLevel.low;
      default:
        return DemandLevel.medium;
    }
  }
}

