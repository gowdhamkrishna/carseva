import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiTest {
  static Future<void> test() async {
    const apiKey = 'AIzaSyBfK9dLZ1b7fyXaK5oCfntwsiAlI6lGGEw';

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );

    final response = await model.generateContent([
      Content.text('Reply with just the word OK'),
    ]);

    print('GEMINI RESPONSE: ${response.text}');
  }
}

void main() {
  GeminiTest.test();
}
