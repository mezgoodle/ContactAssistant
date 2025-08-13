import 'package:flutter/material.dart';

class ContactListScreen extends StatefulWidget {
  const ContactListScreen({super.key});

  @override
  State<ContactListScreen> createState() => _ContactListScreenState();
}

class _ContactListScreenState extends State<ContactListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
      ),
      body: getContactList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          debugPrint('Floating Action Button Pressed');
        },
        tooltip: 'Add note',
        child: const Icon(Icons.add, color: Colors.white, size: 30.0),
      ),
    );
  }

  ListView getContactList() {
    return ListView.builder(
      itemCount: 20,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.yellow,
              child: Icon(Icons.keyboard_arrow_left),
            ),
            title: const Text('Dummy Title'),
            subtitle: const Text('Dummy Subtitle'),
            trailing: const Icon(Icons.delete, color: Colors.grey),
            onTap: () {
              debugPrint('Tapped on contact ${index + 1}');
            },
          ),
        );
      },
    );
  }
}
