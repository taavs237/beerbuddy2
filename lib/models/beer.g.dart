// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'beer.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BeerAdapter extends TypeAdapter<Beer> {
  @override
  final int typeId = 0;

  @override
  Beer read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Beer(
      id: fields[0] as String,
      name: fields[1] as String,
      rating: fields[2] as int,
      comment: fields[3] as String,
      imageLocalPath: fields[4] as String?,
      imageUrl: fields[5] as String?,
      lastModified: fields[6] as int,
      isDeleted: fields[7] as bool,
      pendingSync: fields[8] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Beer obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.rating)
      ..writeByte(3)
      ..write(obj.comment)
      ..writeByte(4)
      ..write(obj.imageLocalPath)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.lastModified)
      ..writeByte(7)
      ..write(obj.isDeleted)
      ..writeByte(8)
      ..write(obj.pendingSync);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BeerAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
