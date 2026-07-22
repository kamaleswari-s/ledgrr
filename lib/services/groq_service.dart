import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_keys.dart';

class GroqService {
  static const _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'llama-3.3-70b-versatile';

  /// Generates one honest, plain-English sentence about the user's
  /// current financial state, using their real numbers. Throws on
  /// any failure — callers should catch and fall back to a
  /// rule-based sentence.
  Future<String> generateDailySentence({
    required String userName,
    required double trueBalance,
    required double monthlyIncome,
    required double monthlyExpense,
    required Map<String, double> topCategories,
  }) async {
    final topCatsStr = topCategories.isEmpty
        ? 'no spending logged yet'
        : (topCategories.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value)))
            .take(3)
            .map((e) => '${e.key}: ₹${e.value.toStringAsFixed(0)}')
            .join(', ');

    final systemPrompt =
        'You are LEDGRR, a financial clarity app for Indian students. '
        'Write exactly ONE short sentence (under 25 words) that tells '
        'the user the truth about their money today. Be honest, direct, '
        'and calm — never guilt-tripping, never falsely cheerful. Use '
        'their real numbers only if it helps the sentence land. Speak '
        'only in plain conversational English. Never use Hindi, Tamil, '
        'or any other language. Never say Namaste or any other greeting '
        'in any language. Do not open with a greeting at all — start '
        'directly with the observation. No quotation marks, no emoji. '
        'Return only the sentence, nothing else.';

    final userPrompt = '''
User: $userName
True Balance: ₹${trueBalance.toStringAsFixed(0)}
This month income: ₹${monthlyIncome.toStringAsFixed(0)}
This month expenses: ₹${monthlyExpense.toStringAsFixed(0)}
Top spending categories this month: $topCatsStr
''';

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer ${ApiKeys.groqApiKey}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': userPrompt},
        ],
        'max_tokens': 60,
        'temperature': 0.7,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Groq API error: ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final sentence =
        data['choices'][0]['message']['content'] as String;
    return sentence.trim();
  }
}