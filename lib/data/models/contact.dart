enum FollowUpFrequency { none, daily, weekly, monthly, quarterly, yearly }

class Contact {
  String id;
  String name;
  String? phoneNumber;
  String? email;
  String? telegramHandle;
  String? instagramHandle;
  String? location;
  String? notes;
  DateTime? lastContacted;
  FollowUpFrequency followUpFrequency;
  List<String> tags;

  Contact({
    required this.id,
    required this.name,
    this.phoneNumber,
    this.email,
    this.telegramHandle,
    this.instagramHandle,
    this.location,
    this.notes,
    this.lastContacted,
    this.followUpFrequency = FollowUpFrequency.none,
    List<String>? tags,
  }) : tags = tags ?? [];

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'telegramHandle': telegramHandle,
      'instagramHandle': instagramHandle,
      'location': location,
      'notes': notes,
      'lastContacted': lastContacted?.toIso8601String(),
      'followUpFrequency': followUpFrequency.name,
      'tags': tags,
    };
  }

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: (json['_id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String?,
      email: json['email'] as String?,
      telegramHandle: json['telegramHandle'] as String?,
      instagramHandle: json['instagramHandle'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      lastContacted: json['lastContacted'] != null
          ? DateTime.tryParse(json['lastContacted'] as String)
          : null,
      followUpFrequency: FollowUpFrequency.values.firstWhere(
        (e) => e.name == json['followUpFrequency'],
        orElse: () => FollowUpFrequency.none,
      ),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Contact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? telegramHandle,
    String? instagramHandle,
    String? location,
    String? notes,
    DateTime? lastContacted,
    FollowUpFrequency? followUpFrequency,
    List<String>? tags,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      telegramHandle: telegramHandle ?? this.telegramHandle,
      instagramHandle: instagramHandle ?? this.instagramHandle,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      lastContacted: lastContacted ?? this.lastContacted,
      followUpFrequency: followUpFrequency ?? this.followUpFrequency,
      tags: tags ?? List.from(this.tags),
    );
  }
}
