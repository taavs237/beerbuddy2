import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class BeerImageStorageService {
  final FirebaseStorage storage;

  BeerImageStorageService({required this.storage});

  /// Storage path: users/<uid>/beers/<beerId>/<filename>
  String buildPath({
    required String uid,
    required String beerId,
    required String filename,
  }) =>
      'users/$uid/beers/$beerId/$filename';

  Future<String> uploadBeerImage({
    required String uid,
    required String beerId,
    required String localPath,
  }) async {
    final fileName = _inferFileName(localPath);
    final path = buildPath(uid: uid, beerId: beerId, filename: fileName);

    final ref = storage.ref().child(path);

    // Web: localPath võib olla blob URL, seda File(path) ei tööta.
    // MVP jaoks eeldame mobile (Android/iOS). Kui sul on web tugi, ütle ja teeme web uploadi eraldi.
    if (kIsWeb) {
      throw UnsupportedError(
        'Web image upload not implemented. Use XFile.bytes for web.',
      );
    }

    final file = File(localPath);
    await ref.putFile(file);

    return await ref.getDownloadURL();
  }

  String _inferFileName(String localPath) {
    final parts = localPath.split(RegExp(r'[\/\\]'));
    final raw = parts.isNotEmpty ? parts.last : 'beer.jpg';
    if (raw.trim().isEmpty) return 'beer.jpg';
    return raw;
  }
}
