import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:contact_assistant/data/models/contact.dart';

class ContactListItem extends StatelessWidget {
  final Contact contact;

  const ContactListItem({super.key, required this.contact});

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

  Color _getUrgencyStripeColor(DateTime? lastContacted) {
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (isDarkMode) {
      return Card(
        clipBehavior: Clip.antiAlias,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                color: _getUrgencyStripeColor(contact.lastContacted),
              ),
              Expanded(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.shade800,
                    foregroundColor: Colors.white,
                    child: Text(contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : '?'),
                  ),
                  title: Text(
                    contact.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                    context.push('/contact/${contact.id}', extra: contact);
                  },
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Light Mode (Original Design)
      return Card(
        color: _getUrgencyColor(contact.lastContacted),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?'),
          ),
          title: Text(contact.name,
              style: const TextStyle(fontWeight: FontWeight.bold)),
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
            context.push('/contact/${contact.id}', extra: contact);
          },
        ),
      );
    }
  }
}
