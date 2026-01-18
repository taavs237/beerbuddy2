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

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'rating': rating,
    'comment': comment,
    'imageUrl': imageUrl,
    'lastModified': lastModified,
    'isDeleted': isDeleted,
  };

  static Beer fromMap(Map<String, dynamic> data) {
    return Beer(
      id: (data['id'] ?? '') as String,
      name: (data['name'] ?? '') as String,
      rating: (data['rating'] ?? 3) as int,
      comment: (data['comment'] ?? '-') as String,
      imageLocalPath: null,
      imageUrl: data['imageUrl'] as String?,
      lastModified: (data['lastModified'] ?? 0) as int,
      isDeleted: (data['isDeleted'] ?? false) as bool,
      pendingSync: false,
    );
  }


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
