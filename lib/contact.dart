class Contact {
  int? id;
  String name;
  String phone;
  DateTime lastContacted;
  String notes;

  Contact({
    this.id,
    required this.name,
    required this.phone,
    required this.lastContacted,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'lastContacted': lastContacted.toIso8601String(),
      'notes': notes,
    };
  }

  factory Contact.fromMap(Map<String, dynamic> map) {
    return Contact(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      lastContacted: DateTime.parse(map['lastContacted']),
      notes: map['notes'],
    );
  }
}
