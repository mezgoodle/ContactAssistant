import 'package:hive/hive.dart';

part 'contact.g.dart';

@HiveType(typeId: 0)
class Contact extends HiveObject {
  @HiveField(0)
  late String
      id; // Hive uses dynamic keys, but we can store a string ID for easier management or use the auto-increment key.
  // Wait, Isar used int ID. Hive keys can be anything. Let's use String UUID for better flexibility or keep int if we want.
  // The user requirement said "Ensure all fields (id...) are preserved".
  // Isar's `Id id = Isar.autoIncrement;` is an int.
  // Let's stick to using Hive's internal key or manage our own ID.
  // For simplicity and robustness, let's add a String UUID field, but Hive objects have a `key` property once saved.
  // However, to keep it simple and closer to the original model, let's just have a field that we can assign.
  // Actually, Hive objects extend HiveObject, so they have a `key`.
  // But the user might be using `id` in the UI.
  // Let's keep `id` as a field. Since Isar was auto-increment int, we can change it to String (UUID) for better uniqueness or keep it int.
  // Let's change it to String UUID to avoid auto-increment issues with Hive if we want to sync later.
  // But wait, if I change type of ID, I might break UI code that expects int.
  // Let's check `contact.dart` again. It was `Id id = Isar.autoIncrement;` which is int.
  // I will check if I can keep it as int or String. String is safer for Hive.
  // Let's assume I can change it to String and fix compilation errors if any.
  // Or I can just use `uuid` package to generate IDs.

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
