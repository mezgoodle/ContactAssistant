import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contact_assistant/core/services/ai_notes_service.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/logic/providers/contact_provider.dart';

class ChatAnalyzerScreen extends ConsumerStatefulWidget {
  final Contact contact;

  const ChatAnalyzerScreen({super.key, required this.contact});

  @override
  ConsumerState<ChatAnalyzerScreen> createState() =>
      _ChatAnalyzerScreenState();
}

enum _ScreenState { input, loading, result }

class _ChatAnalyzerScreenState extends ConsumerState<ChatAnalyzerScreen>
    with SingleTickerProviderStateMixin {
  final _chatController = TextEditingController();
  _ScreenState _state = _ScreenState.input;
  FerrazziProfile? _profile;
  String? _errorMessage;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _chatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _analyzeChat() async {
    final chatLog = _chatController.text.trim();
    if (chatLog.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste a chat log first.')),
      );
      return;
    }

    setState(() {
      _state = _ScreenState.loading;
      _errorMessage = null;
    });

    try {
      final profile = await AiNotesService().analyzeConversation(chatLog);
      if (mounted) {
        setState(() {
          _profile = profile;
          _state = _ScreenState.result;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _state = _ScreenState.input;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e')),
        );
      }
    }
  }

  Future<void> _updateContactProfile() async {
    if (_profile == null) return;

    final aiService = AiNotesService();
    final newNotes = aiService.formatMarkdown(_profile!);

    // Merge: if existing notes exist, append new analysis below
    final existingNotes = widget.contact.notes ?? '';
    final mergedNotes = existingNotes.isEmpty
        ? newNotes
        : '$existingNotes\n\n--- Chat Analysis ---\n$newNotes';

    final updatedContact = widget.contact.copyWith(notes: mergedNotes);
    await ref.read(contactsProvider.notifier).updateContact(updatedContact);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Contact profile updated!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop(updatedContact);
    }
  }

  void _resetToInput() {
    setState(() {
      _state = _ScreenState.input;
      _profile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Import & Analyze Chat'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_state == _ScreenState.result)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Analyze Again',
              onPressed: _resetToInput,
            ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        switchInCurve: Curves.easeInOut,
        switchOutCurve: Curves.easeInOut,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: _buildCurrentState(colorScheme),
      ),
    );
  }

  Widget _buildCurrentState(ColorScheme colorScheme) {
    switch (_state) {
      case _ScreenState.input:
        return _buildInputState(colorScheme);
      case _ScreenState.loading:
        return _buildLoadingState(colorScheme);
      case _ScreenState.result:
        return _buildResultState(colorScheme);
    }
  }

  // ── Input State ──────────────────────────────────────────────────────

  Widget _buildInputState(ColorScheme colorScheme) {
    return Padding(
      key: const ValueKey('input'),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header card
          Card(
            color: colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: colorScheme.onPrimaryContainer, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Magic Chat Import',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: colorScheme.onPrimaryContainer,
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Paste a conversation log and AI will extract key insights, profile details, and action items.',
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onPrimaryContainer
                                        .withValues(alpha: 0.8),
                                  ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (_errorMessage != null) ...[
            Card(
              color: colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: colorScheme.onErrorContainer),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Chat log text field
          Expanded(
            child: TextFormField(
              controller: _chatController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Paste your chat log here...',
                hintStyle: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.4)),
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surfaceContainerLowest,
                alignLabelWithHint: true,
              ),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
            ),
          ),
          const SizedBox(height: 16),

          // Analyze button
          FilledButton.icon(
            onPressed: _analyzeChat,
            icon: const Text('✨', style: TextStyle(fontSize: 18)),
            label: const Text('Analyze Chat'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ── Loading State ────────────────────────────────────────────────────

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.15),
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.tertiary,
                  ],
                ),
              ),
              child: Icon(Icons.auto_awesome,
                  size: 40, color: colorScheme.onPrimary),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Analyzing conversation...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Extracting insights and action items',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }

  // ── Result State ─────────────────────────────────────────────────────

  Widget _buildResultState(ColorScheme colorScheme) {
    if (_profile == null) return const SizedBox.shrink();

    final profile = _profile!;
    final actionItems = profile.actionableHelp.trim();
    final family = profile.family.trim();
    final goals = profile.goals.trim();
    final preferences = profile.preferences.trim();
    final hobbies = profile.passions
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    return ListView(
      key: const ValueKey('result'),
      padding: const EdgeInsets.all(16.0),
      children: [
        // ── Action Items (prominent) ───────────────────────────────
        if (actionItems.isNotEmpty) ...[
          Card(
            color: colorScheme.tertiaryContainer,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(
                color: colorScheme.tertiary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rocket_launch,
                          color: colorScheme.onTertiaryContainer, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Next Steps / Action Items',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: colorScheme.onTertiaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    actionItems,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          height: 1.5,
                        ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // ── Profile Sections ───────────────────────────────────────
        _buildProfileSection(
          context,
          icon: Icons.family_restroom,
          title: 'Family & Personal',
          content: family.isNotEmpty ? family : null,
          colorScheme: colorScheme,
        ),
        _buildProfileSection(
          context,
          icon: Icons.local_fire_department,
          title: 'Passions & Hobbies',
          listContent: hobbies.isNotEmpty ? hobbies : null,
          colorScheme: colorScheme,
        ),
        _buildProfileSection(
          context,
          icon: Icons.work_outline,
          title: 'Professional Goals',
          content: goals.isNotEmpty ? goals : null,
          colorScheme: colorScheme,
        ),
        _buildProfileSection(
          context,
          icon: Icons.coffee,
          title: 'Preferences',
          content: preferences.isNotEmpty ? preferences : null,
          colorScheme: colorScheme,
        ),

        const SizedBox(height: 24),

        // ── Save Button ────────────────────────────────────────────
        FilledButton.icon(
          onPressed: _updateContactProfile,
          icon: const Icon(Icons.save_alt),
          label: const Text('Update Contact Profile'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: _resetToInput,
          icon: const Icon(Icons.refresh),
          label: const Text('Analyze Again'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildProfileSection(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? content,
    List<String>? listContent,
    required ColorScheme colorScheme,
  }) {
    final hasContent =
        (content != null && content.isNotEmpty) ||
        (listContent != null && listContent.isNotEmpty);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 20, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (!hasContent)
                Text(
                  'No information extracted.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontStyle: FontStyle.italic,
                      ),
                )
              else if (listContent != null)
                ...listContent.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('• ',
                            style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold)),
                        Expanded(
                          child: Text(
                            item,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Text(
                  content!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(height: 1.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
