import 'package:hive/hive.dart';

part 'beer.g.dart';

@HiveType(typeId: 0)
class Beer extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int rating; // 1..5

  @HiveField(3)
  String comment;

  @HiveField(4)
  String? imageLocalPath;

  @HiveField(5)
  String? imageUrl;

  @HiveField(6)
  int lastModified;

  @HiveField(7)
  bool isDeleted;

  @HiveField(8)
  bool pendingSync;

  Beer({
    required this.id,
    required this.name,
    required this.rating,
    required this.comment,
    this.imageLocalPath,
    this.imageUrl,
    required this.lastModified,
    this.isDeleted = false,
    this.pendingSync = false,
  });
}
