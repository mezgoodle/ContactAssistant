// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contact.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ContactAdapter extends TypeAdapter<Contact> {
  @override
  final int typeId = 0;

  @override
  Contact read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Contact()
      ..id = fields[0] as String
      ..name = fields[1] as String
      ..phoneNumber = fields[2] as String?
      ..email = fields[3] as String?
      ..telegramHandle = fields[4] as String?
      ..instagramHandle = fields[5] as String?
      ..location = fields[6] as String?
      ..notes = fields[7] as String?
      ..lastContacted = fields[8] as DateTime?
      ..followUpFrequency = fields[9] as FollowUpFrequency
      ..tags = (fields[10] as List).cast<String>();
  }

  @override
  void write(BinaryWriter writer, Contact obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.telegramHandle)
      ..writeByte(5)
      ..write(obj.instagramHandle)
      ..writeByte(6)
      ..write(obj.location)
      ..writeByte(7)
      ..write(obj.notes)
      ..writeByte(8)
      ..write(obj.lastContacted)
      ..writeByte(9)
      ..write(obj.followUpFrequency)
      ..writeByte(10)
      ..write(obj.tags);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FollowUpFrequencyAdapter extends TypeAdapter<FollowUpFrequency> {
  @override
  final int typeId = 1;

  @override
  FollowUpFrequency read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FollowUpFrequency.none;
      case 1:
        return FollowUpFrequency.daily;
      case 2:
        return FollowUpFrequency.weekly;
      case 3:
        return FollowUpFrequency.monthly;
      case 4:
        return FollowUpFrequency.quarterly;
      case 5:
        return FollowUpFrequency.yearly;
      default:
        return FollowUpFrequency.none;
    }
  }

  @override
  void write(BinaryWriter writer, FollowUpFrequency obj) {
    switch (obj) {
      case FollowUpFrequency.none:
        writer.writeByte(0);
        break;
      case FollowUpFrequency.daily:
        writer.writeByte(1);
        break;
      case FollowUpFrequency.weekly:
        writer.writeByte(2);
        break;
      case FollowUpFrequency.monthly:
        writer.writeByte(3);
        break;
      case FollowUpFrequency.quarterly:
        writer.writeByte(4);
        break;
      case FollowUpFrequency.yearly:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FollowUpFrequencyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
