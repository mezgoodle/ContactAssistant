import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:contact_assistant/core/services/ai_notes_service.dart';

class IcebreakerScreen extends StatefulWidget {
  const IcebreakerScreen({super.key});

  @override
  State<IcebreakerScreen> createState() => _IcebreakerScreenState();
}

class _IcebreakerScreenState extends State<IcebreakerScreen> {
  final TextEditingController _contextController = TextEditingController();
  List<String> _questions = [
    "What is currently taking up most of your attention and energy?",
    "If you could change one thing about your industry, what would it be?",
    "What do you enjoy doing most in your free time?"
  ];
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _contextController.dispose();
    super.dispose();
  }

  Future<void> _generateStarters() async {
    final contextText = _contextController.text.trim();
    if (contextText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a meeting context')),
      );
      return;
    }
    if (contextText.length > 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please keep context under 500 characters')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final qs = await AiNotesService().generateIcebreakers(contextText);
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

  IconData _getIconForQuestion() {
    return Icons.lightbulb_outline;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Acquaintance Guide'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _contextController,
                  decoration: const InputDecoration(
                    labelText: 'Where are you meeting them?',
                    hintText: "e.g., Tech Conference, Friend's Party, Airplane",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: null,
                  maxLength: 500,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateStarters,
                  icon: const Text('✨'),
                  label: const Text('Generate Starters'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _isLoading
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
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16.0),
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    _getIconForQuestion(),
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    size: 28,
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      question,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium,
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
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton.icon(
            onPressed: () {
              context.push('/add_contact');
            },
            icon: const Icon(Icons.add),
            label: const Text('Add as New Contact'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}
