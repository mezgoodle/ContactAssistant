import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:contact_assistant/logic/providers/contact_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getUrgencyColor(DateTime? lastContacted) {
    if (lastContacted == null) return Colors.grey.shade300;
    final difference = DateTime.now().difference(lastContacted).inDays;
    if (difference < 14) {
      return Colors.green.shade100;
    } else if (difference < 30) {
      return Colors.yellow.shade100;
    } else {
      return Colors.red.shade100;
    }
  }

  IconData _getUrgencyIcon(DateTime? lastContacted) {
    if (lastContacted == null) return Icons.question_mark;
    final difference = DateTime.now().difference(lastContacted).inDays;
    if (difference < 14) {
      return Icons.check_circle;
    } else if (difference < 30) {
      return Icons.warning;
    } else {
      return Icons.error;
    }
  }

  Color _getUrgencyIconColor(DateTime? lastContacted) {
    if (lastContacted == null) return Colors.grey;
    final difference = DateTime.now().difference(lastContacted).inDays;
    if (difference < 14) {
      return Colors.green;
    } else if (difference < 30) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Personal CRM'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              context.push('/settings');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: contactsAsync.when(
              data: (contacts) {
                // Filter
                final filteredContacts = contacts.where((contact) {
                  final nameMatch =
                      contact.name.toLowerCase().contains(_searchQuery);
                  final tagsMatch = contact.tags
                      .any((tag) => tag.toLowerCase().contains(_searchQuery));
                  return nameMatch || tagsMatch;
                }).toList();

                // Sort: Ascending by lastContacted (nulls first or last? "Longest time" means oldest date first. Null means never contacted, so maybe most urgent?)
                // Let's say Null = Never contacted = High Urgency (Top).
                // Then Oldest dates.
                // Then Newest dates.
                filteredContacts.sort((a, b) {
                  if (a.lastContacted == null && b.lastContacted == null)
                    return 0;
                  if (a.lastContacted == null)
                    return -1; // a is null (urgent), b is date
                  if (b.lastContacted == null)
                    return 1; // b is null (urgent), a is date
                  return a.lastContacted!
                      .compareTo(b.lastContacted!); // Ascending: Oldest first
                });

                if (filteredContacts.isEmpty) {
                  return const Center(child: Text('No contacts found.'));
                }

                return ListView.builder(
                  itemCount: filteredContacts.length,
                  itemBuilder: (context, index) {
                    final contact = filteredContacts[index];
                    return Card(
                      color: _getUrgencyColor(contact.lastContacted),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.white,
                          child: Text(contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?'),
                        ),
                        title: Text(contact.name,
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(
                          contact.lastContacted == null
                              ? 'Never contacted'
                              : 'Last: ${DateFormat.yMMMd().format(contact.lastContacted!)}',
                        ),
                        trailing: Icon(
                          _getUrgencyIcon(contact.lastContacted),
                          color: _getUrgencyIconColor(contact.lastContacted),
                        ),
                        onTap: () {
                          context.push('/contact/${contact.id}',
                              extra: contact);
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/add_contact');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
