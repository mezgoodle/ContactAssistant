import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'contact.dart';
import 'database_helper.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const ContactListScreen(),
    );
  }
}

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  late Future<List<Contact>> _contactsFuture;

  @override
  void initState() {
    super.initState();
    _refreshContacts();
  }

  void _refreshContacts() {
    setState(() {
      _contactsFuture = DatabaseHelper.instance.getContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: FutureBuilder<List<Contact>>(
        future: _contactsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No contacts found.'));
          } else {
            final contacts = snapshot.data!;
            return ListView.builder(
              itemCount: contacts.length,
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return ListTile(
                  title: Text(contact.name),
                  subtitle: Text(contact.phone),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContactFormScreen(contact: contact),
                      ),
                    );
                    _refreshContacts();
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const ContactFormScreen(),
            ),
          );
          _refreshContacts();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ContactFormScreen extends StatefulWidget {
  final Contact? contact;

  const ContactFormScreen({super.key, this.contact});

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _notesController;
  late DateTime _lastContacted;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneController = TextEditingController(text: widget.contact?.phone);
    _notesController = TextEditingController(text: widget.contact?.notes);
    _lastContacted = widget.contact?.lastContacted ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_formKey.currentState!.validate()) {
      final newContact = Contact(
        id: widget.contact?.id,
        name: _nameController.text,
        phone: _phoneController.text,
        notes: _notesController.text,
        lastContacted: _lastContacted,
      );

      if (widget.contact == null) {
        await DatabaseHelper.instance.insert(newContact);
      } else {
        await DatabaseHelper.instance.update(newContact);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
        actions: [
          if (widget.contact != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                await DatabaseHelper.instance.delete(widget.contact!.id!);
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number.';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Text('Last Contacted: ${DateFormat.yMd().format(_lastContacted)}'),
                  const Spacer(),
                  TextButton(
                    child: const Text('Change'),
                    onPressed: () async {
                      final pickedDate = await showDatePicker(
                        context: context,
                        initialDate: _lastContacted,
                        firstDate: DateTime(2000),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null && pickedDate != _lastContacted) {
                        setState(() {
                          _lastContacted = pickedDate;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveContact,
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
