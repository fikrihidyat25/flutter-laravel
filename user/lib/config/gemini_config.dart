class GeminiConfig {
  static const String apiKey = 'AIzaSyCpiCrPAd2kWFK4UjiGa3e8J-6MKRZo1Ss';
  
  static const String model = 'gemini-1.5-flash';
  static const String fallbackModel = 'gemini-1.5-pro';
  
  static const double temperature = 0.7;
  static const int topK = 40;
  static const double topP = 0.95;
  static const int maxOutputTokens = 1024;
}
