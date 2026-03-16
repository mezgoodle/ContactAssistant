import 'dart:convert';
import 'package:firebase_ai/firebase_ai.dart';

/// Service that uses the Firebase AI (Gemini) API to analyse raw contact notes
/// and return a structured Markdown profile based on Keith Ferrazzi's
/// "Never Eat Alone" methodology.
///
/// Prerequisites:
///  - Firebase project connected (google-services.json / GoogleService-Info.plist).
///  - `Firebase.initializeApp()` called before using this service (see main.dart).
///  - Gemini API enabled in the Firebase console under AI Logic.
class AiNotesService {
  static const String _systemInstruction =
      "You are an expert networking assistant trained in Keith Ferrazzi's "
      "'Never Eat Alone' methodology. Analyze the raw notes provided by the "
      "user and extract key relationship-building details into each category. "
      "If information for a field is missing or cannot be inferred, leave it "
      "as an empty string or, for list fields, an empty list.";

  late final GenerativeModel _model;

  AiNotesService() {
    final schema = Schema.object(
      properties: {
        'family_and_personal': Schema.string(
          description: 'Spouse, kids, hometown, personal life details.',
          nullable: true,
        ),
        'passions_and_hobbies': Schema.array(
          items: Schema.string(),
          description:
              "What lights their 'Blue Flame'? Hobbies, sports, passions.",
          nullable: true,
        ),
        'professional_goals': Schema.string(
          description: 'Current projects, career ambitions, challenges.',
          nullable: true,
        ),
        'preferences': Schema.string(
          description: 'Favorite food, drinks, sports teams, quirks.',
          nullable: true,
        ),
        'actionable_help': Schema.string(
          description:
              'How I can uniquely help them or provide value right now.',
          nullable: true,
        ),
      },
    );

    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.0-flash',
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        responseSchema: schema,
      ),
    );
  }

  /// Sends [rawNotes] to Gemini and returns a formatted Markdown string
  /// with the 5 Ferrazzi relationship-building pillars.
  Future<String> enhanceNotes(String rawNotes) async {
    final response = await _model.generateContent([Content.text(rawNotes)]);

    final jsonText = response.text;
    if (jsonText == null || jsonText.trim().isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    final Map<String, dynamic> data =
        jsonDecode(jsonText) as Map<String, dynamic>;

    return _formatMarkdown(data);
  }

  String _formatMarkdown(Map<String, dynamic> data) {
    final buffer = StringBuffer();

    final family = (data['family_and_personal'] as String? ?? '').trim();
    buffer.writeln('## 👨‍👩‍👧 Family & Personal');
    buffer.writeln(family.isNotEmpty ? family : '_No information available._');
    buffer.writeln();

    final hobbies = (data['passions_and_hobbies'] as List<dynamic>? ?? [])
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
    buffer.writeln('## 🔥 Passions & Hobbies');
    if (hobbies.isNotEmpty) {
      for (final item in hobbies) {
        buffer.writeln('- $item');
      }
    } else {
      buffer.writeln('_No information available._');
    }
    buffer.writeln();

    final goals = (data['professional_goals'] as String? ?? '').trim();
    buffer.writeln('## 💼 Professional Goals');
    buffer.writeln(goals.isNotEmpty ? goals : '_No information available._');
    buffer.writeln();

    final prefs = (data['preferences'] as String? ?? '').trim();
    buffer.writeln('## ☕ Preferences');
    buffer.writeln(prefs.isNotEmpty ? prefs : '_No information available._');
    buffer.writeln();

    final help = (data['actionable_help'] as String? ?? '').trim();
    buffer.writeln('## 🎯 Actionable Help');
    buffer.writeln(help.isNotEmpty ? help : '_No information available._');

    return buffer.toString().trim();
  }
}
