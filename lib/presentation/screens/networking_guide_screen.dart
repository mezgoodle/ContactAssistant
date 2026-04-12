import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/logic/providers/contact_provider.dart';
import 'package:contact_assistant/core/services/ai_notes_service.dart';

class NetworkingGuideScreen extends ConsumerStatefulWidget {
  final Contact contact;
  final FerrazziProfile profile;

  const NetworkingGuideScreen({
    super.key,
    required this.contact,
    required this.profile,
  });

  @override
  ConsumerState<NetworkingGuideScreen> createState() =>
      _NetworkingGuideScreenState();
}

class _NetworkingGuideScreenState extends ConsumerState<NetworkingGuideScreen> {
  List<String>? _questions;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final qs =
          await AiNotesService().generateNetworkingQuestions(widget.profile);
      if (mounted) {
        setState(() {
          _questions = qs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question copied to clipboard')),
    );
  }

  void _logConversation() async {
    await ref.read(contactsProvider.notifier).markAsContacted(widget.contact);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Conversation logged for today!')),
      );
    }
  }

  IconData _getIconForIndex(int index) {
    switch (index) {
      case 0:
        return Icons.waving_hand; // Icebreaker
      case 1:
        return Icons.psychology; // Deepening
      case 2:
        return Icons.rocket_launch; // Professional/Goals
      default:
        return Icons.chat_bubble_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Networking Guide for ${widget.contact.name}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Failed to load questions:\n$_error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _questions?.length ?? 0,
                  itemBuilder: (context, index) {
                    final question = _questions![index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _getIconForIndex(index),
                              color: Theme.of(context).colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                question,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(question),
                              tooltip: 'Copy',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _logConversation,
        icon: const Icon(Icons.check),
        label: const Text('Log Conversation'),
      ),
    );
  }
}
