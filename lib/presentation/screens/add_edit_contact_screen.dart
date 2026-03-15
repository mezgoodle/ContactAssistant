import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:contact_assistant/data/models/contact.dart';
import 'package:contact_assistant/logic/providers/contact_provider.dart';

class AddEditContactScreen extends ConsumerStatefulWidget {
  final Contact? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  ConsumerState<AddEditContactScreen> createState() =>
      _AddEditContactScreenState();
}

class _AddEditContactScreenState extends ConsumerState<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _telegramController;
  late TextEditingController _instagramController;
  late TextEditingController _locationController;
  late TextEditingController _notesController;
  late TextEditingController _tagsController;
  DateTime? _lastContacted;
  FollowUpFrequency _frequency = FollowUpFrequency.none;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name);
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber);
    _emailController = TextEditingController(text: widget.contact?.email);
    _telegramController =
        TextEditingController(text: widget.contact?.telegramHandle);
    _instagramController =
        TextEditingController(text: widget.contact?.instagramHandle);
    _locationController = TextEditingController(text: widget.contact?.location);
    _notesController = TextEditingController(text: widget.contact?.notes);
    _tagsController = TextEditingController(
      text: (widget.contact?.tags ?? []).join(', '),
    );
    _lastContacted = widget.contact?.lastContacted;
    _frequency = widget.contact?.followUpFrequency ?? FollowUpFrequency.none;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _telegramController.dispose();
    _instagramController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastContacted ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _lastContacted) {
      setState(() {
        _lastContacted = picked;
      });
    }
  }

  void _saveContact() {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim();
      final email = _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim();
      final telegram = _telegramController.text.trim().isEmpty
          ? null
          : _telegramController.text.trim();
      final instagram = _instagramController.text.trim().isEmpty
          ? null
          : _instagramController.text.trim();
      final location = _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim();
      final notes = _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim();
      final tags = _tagsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final contact = Contact(
        id: widget.contact?.id ?? '',
        name: name,
        phoneNumber: phone,
        email: email,
        telegramHandle: telegram,
        instagramHandle: instagram,
        location: location,
        notes: notes,
        lastContacted: _lastContacted,
        followUpFrequency: _frequency,
        tags: tags,
      );

      if (widget.contact != null) {
        ref.read(contactsProvider.notifier).updateContact(contact);
      } else {
        ref.read(contactsProvider.notifier).addContact(contact);
      }

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact == null ? 'Add Contact' : 'Edit Contact'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveContact,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                  labelText: 'Name *', prefixIcon: Icon(Icons.person)),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                  labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                  labelText: 'Email', prefixIcon: Icon(Icons.email)),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _telegramController,
                    decoration: const InputDecoration(
                        labelText: 'Telegram Handle',
                        prefixIcon: Icon(Icons.send)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                        labelText: 'Instagram Handle',
                        prefixIcon: Icon(Icons.camera_alt)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                  labelText: 'Location', prefixIcon: Icon(Icons.location_on)),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FollowUpFrequency>(
              value: _frequency,
              decoration: const InputDecoration(
                  labelText: 'Follow-up Frequency',
                  prefixIcon: Icon(Icons.repeat)),
              items: FollowUpFrequency.values.map((f) {
                return DropdownMenuItem(
                  value: f,
                  child: Text(f.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _frequency = val);
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: () => _selectDate(context),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Last Contacted Date',
                  prefixIcon: Icon(Icons.calendar_today),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  _lastContacted == null
                      ? 'Not set'
                      : DateFormat.yMMMd().format(_lastContacted!),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tagsController,
              decoration: const InputDecoration(
                  labelText: 'Tags (comma separated)',
                  prefixIcon: Icon(Icons.label)),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                  labelText: 'Notes',
                  prefixIcon: Icon(Icons.note),
                  alignLabelWithHint: true),
              maxLines: 5,
            ),
          ],
        ),
      ),
    );
  }
}
