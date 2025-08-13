import 'package:flutter/material.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({super.key});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  static var _priorities = ["high", "medium", "low"];

  TextEditingController _titleController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 10.0, right: 10.0),
        child: ListView(
          children: [
            ListTile(
              title: DropdownButton(
                  items: _priorities.map((String dropDownStringItem) {
                    return DropdownMenuItem<String>(
                      value: dropDownStringItem,
                      child: Text(dropDownStringItem),
                    );
                  }).toList(),
                  value: 'low',
                  onChanged: (value) {
                    setState(() {
                      debugPrint('Selected priority: $value');
                    });
                  }),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: _titleController,
                onChanged: (value) {
                  debugPrint('Title changed: $value');
                },
                decoration: InputDecoration(
                  labelText: 'Contact Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: _descriptionController,
                onChanged: (value) {
                  debugPrint('Title changed: $value');
                },
                decoration: InputDecoration(
                  labelText: 'Contact Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        debugPrint('Save button pressed');
                      },
                      child: const Text(
                        'Delete',
                        textScaleFactor: 1.5,
                      ),
                    ),
                  ),
                  Container(
                    width: 10,
                  ),
                  Expanded(
                      child: ElevatedButton(
                    onPressed: () {
                      debugPrint('Delet button pressed');
                    },
                    child: const Text(
                      'Save',
                      textScaleFactor: 1.5,
                    ),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
