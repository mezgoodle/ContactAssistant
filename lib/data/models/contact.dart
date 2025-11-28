import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  String id = '';

  @HiveField(1)
  late String name;

  @HiveField(2)
  String? phoneNumber;

  @HiveField(3)
  String? email;

  @HiveField(4)
  String? telegramHandle;

  @HiveField(5)
  String? instagramHandle;

  @HiveField(6)
  String? location;

  @HiveField(7)
  String? notes;

  @HiveField(8)
  DateTime? lastContacted;

  @HiveField(9)
  FollowUpFrequency followUpFrequency = FollowUpFrequency.none;

  @HiveField(10)
  List<String> tags = [];
}

@HiveType(typeId: 1)
enum FollowUpFrequency {
  @HiveField(0)
  none,
  @HiveField(1)
  daily,
  @HiveField(2)
  weekly,
  @HiveField(3)
  monthly,
  @HiveField(4)
  quarterly,
  @HiveField(5)
  yearly,
}
