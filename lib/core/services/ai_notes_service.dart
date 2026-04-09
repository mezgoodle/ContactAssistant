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
      "as an empty string or, for list fields, an empty list.";

  static const String _networkingInstruction =
      "You are Keith Ferrazzi. Based on the provided contact profile, generate 3 "
      "high-impact, open-ended 'Icebreaker' or 'Deepening' questions. These questions "
      "should show genuine interest in the person's 'Blue Flame' (passions), family, "
      "and professional goals. Avoid small talk; aim for questions that lead to an "
      "emotional connection or offer a chance to be helpful. Respond in Ukrainian. "
      "Return a JSON object with a key 'questions' containing a list of strings.";

  late final GenerativeModel _model;
  late final GenerativeModel _networkingModel;

  AiNotesService() {
    _model = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(_systemInstruction),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
    );
    _networkingModel = FirebaseAI.googleAI().generativeModel(
      model: 'gemini-2.5-flash',
      systemInstruction: Content.system(_networkingInstruction),
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
    buffer.writeln('👨‍👩‍👧 Family & Personal');
    buffer.writeln(family.isNotEmpty ? family : 'No information available.');
    buffer.writeln();

    final hobbies = profile.passions
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    buffer.writeln('🔥 Passions & Hobbies');
    if (hobbies.isNotEmpty) {
      for (final item in hobbies) {
        buffer.writeln('- $item');
      }
    } else {
      buffer.writeln('No information available.');
    }
    buffer.writeln();

    final goals = profile.goals.trim();
    buffer.writeln('💼 Professional Goals');
    buffer.writeln(goals.isNotEmpty ? goals : 'No information available.');
    buffer.writeln();

    final prefs = profile.preferences.trim();
    buffer.writeln('☕ Preferences');
    buffer.writeln(prefs.isNotEmpty ? prefs : 'No information available.');
    buffer.writeln();

    final help = profile.actionableHelp.trim();
    buffer.writeln('🎯 Actionable Help');
    buffer.writeln(help.isNotEmpty ? help : 'No information available.');

    return buffer.toString().trim();
  }

  /// Generates 3 networking questions based on the Ferrazzi methodology.
  Future<List<String>> generateNetworkingQuestions(FerrazziProfile profile) async {
    final response = await _networkingModel.generateContent([
      Content.text(jsonEncode(profile.toJson())),
    ]);

    final jsonText = response.text;
    if (jsonText == null || jsonText.trim().isEmpty) {
      throw Exception('Gemini returned an empty response.');
    }

    final Map<String, dynamic> data = jsonDecode(jsonText) as Map<String, dynamic>;
    final List<dynamic> questions = data['questions'] ?? [];
    return questions.map((e) => e.toString()).toList();
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

  Map<String, dynamic> toJson() {
    return {
      'family_and_personal': family,
      'passions_and_hobbies': passions,
      'professional_goals': goals,
      'preferences': preferences,
      'actionable_help': actionableHelp,
    };
  }

  factory FerrazziProfile.fromMarkdown(String markdown) {
    String extractSection(String title) {
      final startIndex = markdown.indexOf(title);
      if (startIndex == -1) return '';
      final contentStart = markdown.indexOf('\n', startIndex);
      if (contentStart == -1) return '';
      int endIndex = markdown.length;
      final sections = [
        '👨‍👩‍👧 Family & Personal',
        '🔥 Passions & Hobbies',
        '💼 Professional Goals',
        '☕ Preferences',
        '🎯 Actionable Help'
      ];
      for (final section in sections) {
        if (section == title) continue;
        final index = markdown.indexOf(section, contentStart + 1);
        if (index != -1 && index < endIndex) {
          endIndex = index;
        }
      }
      return markdown.substring(contentStart + 1, endIndex).trim();
    }

    final family = extractSection('👨‍👩‍👧 Family & Personal');
    final hobbiesText = extractSection('🔥 Passions & Hobbies');
    final goals = extractSection('💼 Professional Goals');
    final prefs = extractSection('☕ Preferences');
    final help = extractSection('🎯 Actionable Help');

    final passions = hobbiesText
        .split('\n')
        .map((e) => e.replaceAll(RegExp(r'^- '), '').trim())
        .where((e) => e.isNotEmpty && e != 'No information available.')
        .toList();

    return FerrazziProfile(
      family: family == 'No information available.' ? '' : family,
      passions: passions,
      goals: goals == 'No information available.' ? '' : goals,
      preferences: prefs == 'No information available.' ? '' : prefs,
      actionableHelp: help == 'No information available.' ? '' : help,
    );
  }
}
