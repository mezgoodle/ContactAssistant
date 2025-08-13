import 'package:flutter/material.dart';
import 'package:contact_assistant/screens/contact_list_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Contact Assistant",
      home: ContactListScreen(),
    );
  }
}
