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
      "Return a JSON object with keys: 'family_and_personal' (string), "
      "'passions_and_hobbies' (array of strings), 'professional_goals' (string), "
      "'preferences' (string), 'actionable_help' (string). "
      "If information for a field is missing or cannot be inferred, leave it "
      "as an empty string or, for list fields, an empty list.";

  late final GenerativeModel _model;

  AiNotesService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
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
    final profile = FerrazziProfile.fromJson(data);

    return _formatMarkdown(profile);
  }

  String _formatMarkdown(FerrazziProfile profile) {
    final buffer = StringBuffer();

    final family = profile.family.trim();
    buffer.writeln('## 👨‍👩‍👧 Family & Personal');
    buffer.writeln(family.isNotEmpty ? family : '_No information available._');
    buffer.writeln();

    final hobbies = profile.passions
        .map((e) => e.trim())
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

    final goals = profile.goals.trim();
    buffer.writeln('## 💼 Professional Goals');
    buffer.writeln(goals.isNotEmpty ? goals : '_No information available._');
    buffer.writeln();

    final prefs = profile.preferences.trim();
    buffer.writeln('## ☕ Preferences');
    buffer.writeln(prefs.isNotEmpty ? prefs : '_No information available._');
    buffer.writeln();

    final help = profile.actionableHelp.trim();
    buffer.writeln('## 🎯 Actionable Help');
    buffer.writeln(help.isNotEmpty ? help : '_No information available._');

    return buffer.toString().trim();
  }
}

class FerrazziProfile {
  final String family;
  final List<String> passions;
  final String goals;
  final String preferences;
  final String actionableHelp;

  FerrazziProfile({
    required this.family,
    required this.passions,
    required this.goals,
    required this.preferences,
    required this.actionableHelp,
  });

  factory FerrazziProfile.fromJson(Map<String, dynamic> json) {
    return FerrazziProfile(
      family: json['family_and_personal'] ?? '',
      passions: (json['passions_and_hobbies'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      goals: json['professional_goals'] ?? '',
      preferences: json['preferences'] ?? '',
      actionableHelp: json['actionable_help'] ?? '',
    );
  }
}
