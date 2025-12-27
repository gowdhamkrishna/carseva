import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../domain/models/mechanic_model.dart';

class MechanicAIService {
  late final GenerativeModel _model;

  MechanicAIService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
  }

  /// Generate 2-3 realistic mechanics near user's location using AI
  Future<List<Mechanic>> generateNearbyMechanics(double latitude, double longitude) async {
    try {
      final prompt = '''
You are a local business directory. Generate 2-3 realistic car mechanic/service centers near GPS coordinates: $latitude, $longitude.

IMPORTANT: 
- Research the actual area/city at these coordinates
- Generate REAL-SOUNDING addresses with actual street names for that specific area
- Generate coordinates that are EXACTLY within 1-3 km of the given location
- Use realistic Indian business naming conventions

For each mechanic, provide:
- name: realistic business name (e.g., "City Name Auto Care", "Area Name Motors")
- address: SPECIFIC street address with area name and city (e.g., "123 Main Road, Area Name, City - 600001")
- phoneNumber: Indian format (+91 XXXXX XXXXX)
- latitude: MUST be within 0.01-0.03 degrees of $latitude
- longitude: MUST be within 0.01-0.03 degrees of $longitude
- services: 3-4 services like ["Oil Change", "Brake Service", "Engine Repair", "AC Repair"]
- rating: between 3.8 and 4.9
- reviewCount: between 30 and 180
- isOpen: true or false (most should be true)
- openingHours: realistic (e.g., "9 AM - 7 PM", "8 AM - 8 PM", "24/7")

Return ONLY valid JSON array, no markdown, no explanation:
[
  {
    "name": "...",
    "address": "...",
    "phoneNumber": "+91 ...",
    "latitude": $latitude + small offset,
    "longitude": $longitude + small offset,
    "services": ["...", "...", "..."],
    "rating": 4.x,
    "reviewCount": xx,
    "isOpen": true,
    "openingHours": "..."
  }
]
''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final text = response.text ?? '';

      // Clean response - remove markdown code blocks if present
      String cleanedText = text.trim();
      if (cleanedText.startsWith('```json')) {
        cleanedText = cleanedText.substring(7);
      } else if (cleanedText.startsWith('```')) {
        cleanedText = cleanedText.substring(3);
      }
      if (cleanedText.endsWith('```')) {
        cleanedText = cleanedText.substring(0, cleanedText.length - 3);
      }
      cleanedText = cleanedText.trim();

      // Parse JSON
      final List<dynamic> jsonList = json.decode(cleanedText);
      
      // Convert to Mechanic objects
      List<Mechanic> mechanics = [];
      for (int i = 0; i < jsonList.length && i < 3; i++) {
        final data = jsonList[i];
        mechanics.add(Mechanic(
          id: (i + 1).toString(),
          name: data['name'] ?? 'Auto Service Center',
          address: data['address'] ?? 'Local Area',
          phoneNumber: data['phoneNumber'] ?? '+91 98765 43210',
          latitude: (data['latitude'] ?? latitude).toDouble(),
          longitude: (data['longitude'] ?? longitude).toDouble(),
          services: List<String>.from(data['services'] ?? ['General Repair']),
          rating: (data['rating'] ?? 4.0).toDouble(),
          reviewCount: data['reviewCount'] ?? 50,
          isOpen: data['isOpen'] ?? true,
          openingHours: data['openingHours'] ?? '9 AM - 6 PM',
        ));
      }

      return mechanics;
    } catch (e) {
      print('AI mechanic generation error: $e');
      // Fallback to mock data
      return MechanicData.getMockMechanics(
        userLat: latitude,
        userLon: longitude,
      ).take(3).toList();
    }
  }
}
