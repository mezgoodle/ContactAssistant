import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  late String name;

  String? phoneNumber;
  String? email;
  String? telegramHandle;
  String? instagramHandle;
  String? location;

  String? notes;

  DateTime? lastContacted;

  @enumerated
  FollowUpFrequency followUpFrequency = FollowUpFrequency.none;

  List<String> tags = [];
}

enum FollowUpFrequency {
  none,
  daily,
  weekly,
  monthly,
  quarterly,
  yearly,
}
