import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/logic/providers/contact_provider.dart';
import 'package:contact_assistant/core/services/ai_notes_service.dart';

class ContactDetailScreen extends ConsumerWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  Future<void> _launchUrl(String urlString) async {
    final Uri? url = Uri.tryParse(urlString);
    if (url == null) {
      debugPrint('Invalid URL: $urlString');
      return;
    }
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(contactsProvider);

    final currentContact =
        contactsAsync.value?.where((c) => c.id == contact.id).firstOrNull ??
            contact;

    return Scaffold(
      appBar: AppBar(
        title: Text(currentContact.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/edit_contact', extra: currentContact);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Contact?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                await ref
                    .read(contactsProvider.notifier)
                    .deleteContact(currentContact.id);
                if (context.mounted) context.pop();
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    child: Icon(Icons.person, size: 40),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentContact.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentContact.lastContacted == null
                        ? 'Never contacted'
                        : 'Last contacted: ${DateFormat.yMMMd().format(currentContact.lastContacted!)}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            await ref
                                .read(contactsProvider.notifier)
                                .markAsContacted(currentContact);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Failed to log contact')),
                            );
                          }
                        },
                        icon: const Icon(Icons.check),
                        label: const Text('Contacted'),
                      ),
                      FilledButton.icon(
                        onPressed: () {
                          if (currentContact.notes == null ||
                              currentContact.notes!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Please add AI enhanced notes first!')),
                            );
                            return;
                          }
                          try {
                            final profile = FerrazziProfile.fromMarkdown(
                                currentContact.notes!);
                            context.push('/networking_guide', extra: {
                              'contact': currentContact,
                              'profile': profile,
                            });
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Failed to parse profile. Are notes AI enhanced?')),
                            );
                          }
                        },
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('AI Guide'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          if (currentContact.phoneNumber != null)
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(currentContact.phoneNumber!),
              onTap: () => _launchUrl(
                  'tel:${Uri.encodeComponent(currentContact.phoneNumber!)}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          if (currentContact.email != null)
            ListTile(
              leading: const Icon(Icons.email),
              title: Text(currentContact.email!),
              onTap: () => _launchUrl('mailto:${currentContact.email}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          if (currentContact.telegramHandle != null)
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.telegram),
              title: Text('@${currentContact.telegramHandle}'),
              onTap: () =>
                  _launchUrl('https://t.me/${currentContact.telegramHandle}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          if (currentContact.instagramHandle != null)
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.instagram),
              title: Text('@${currentContact.instagramHandle}'),
              onTap: () => _launchUrl(
                  'https://instagram.com/${currentContact.instagramHandle}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            ),
          if (currentContact.location != null)
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(currentContact.location!),
            ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child:
                Text('Notes', style: Theme.of(context).textTheme.titleMedium),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(currentContact.notes ?? 'No notes added.'),
            ),
          ),

          const SizedBox(height: 16),

          if (currentContact.tags.isNotEmpty)
            Wrap(
              spacing: 8.0,
              children: currentContact.tags
                  .map((tag) => Chip(label: Text(tag)))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
