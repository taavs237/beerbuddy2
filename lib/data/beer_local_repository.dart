import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../models/beer.dart';

class BeerLocalRepository {
  static const _boxName = 'beers';
  final _uuid = const Uuid();

  Box<Beer> get _box => Hive.box<Beer>(_boxName);

  /// Kasutatakse UI-s ValueListenableBuilder jaoks
  Box<Beer> listenableBox() => Hive.box<Beer>(_boxName);

  /// Kõik mitte-kustutatud õlled (sorteeritud viimase muudatuse järgi)
  List<Beer> getAllNotDeleted() {
    final items = _box.values.where((b) => !b.isDeleted).toList();
    items.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return items;
  }

  /// Otsing nime või kommentaari järgi (offline, Hive pealt)
  List<Beer> searchNotDeleted(String query) {
    final q = query.trim().toLowerCase();

    final items = _box.values.where((b) {
      if (b.isDeleted) return false;
      if (q.isEmpty) return true;

      final name = b.name.toLowerCase();
      final comment = b.comment.toLowerCase();
      return name.contains(q) || comment.contains(q);
    }).toList();

    items.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    return items;
  }

  Beer? getById(String id) => _box.get(id);

  /// Lisa uus õlu (offline-first)
  Future<Beer> add({
    required String name,
    required int rating,
    required String comment,
    String? imageLocalPath,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final beer = Beer(
      id: _uuid.v4(),
      name: name.trim(),
      rating: rating,
      comment: comment.trim(),
      imageLocalPath: imageLocalPath,
      imageUrl: null,
      lastModified: now,
      isDeleted: false,
      pendingSync: true,
    );

    await _box.put(beer.id, beer);
    return beer;
  }

  /// Uuenda olemasolevat õlut
  Future<void> update(
      Beer beer, {
        required String name,
        required int rating,
        required String comment,
        String? imageLocalPath,
      }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    beer
      ..name = name.trim()
      ..rating = rating
      ..comment = comment.trim()
      ..imageLocalPath = imageLocalPath
      ..lastModified = now
      ..pendingSync = true;

    await beer.save();
  }

  /// Soft delete (vajalik sync + offline jaoks)
  Future<void> softDelete(Beer beer) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    beer
      ..isDeleted = true
      ..lastModified = now
      ..pendingSync = true;

    await beer.save();
  }
}
