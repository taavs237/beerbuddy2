import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hive/hive.dart';

import '../models/beer.dart';
import 'beer_image_storage_service.dart';

class BeerSyncService {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final Box<Beer> box;
  final FirebaseStorage storage;

  BeerSyncService({
    required this.firestore,
    required this.auth,
    required this.box,
    FirebaseStorage? storage,
  }) : storage = storage ?? FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      firestore.collection('users').doc(uid).collection('beers');

  Future<void> syncNow() async {
    final uid = auth.currentUser?.uid;
    if (uid == null) return;

    await _pushLocal(uid);
    await _pullRemote(uid);
  }

  Future<void> _pushLocal(String uid) async {
    final pending = box.values.where((b) => b.pendingSync).toList();
    final imageService = BeerImageStorageService(storage: storage);

    for (final beer in pending) {
      // 1) Kui on lokaalne pilt, aga imageUrl puudub -> uploadi Storage'i
      final localPath = beer.imageLocalPath;
      final hasLocal = localPath != null && localPath.isNotEmpty;
      final hasRemoteUrl = beer.imageUrl != null && beer.imageUrl!.isNotEmpty;

      if (hasLocal && !hasRemoteUrl) {
        try {
          final url = await imageService.uploadBeerImage(
            uid: uid,
            beerId: beer.id,
            localPath: localPath!,
          );
          beer.imageUrl = url;
          // NB: ei muuda lastModified siin, sest see on sisu muutuse timestamp juba.
          // Kui tahad, võid lastModified uuendada, aga siis last-write-wins käitumine muutub.
          await beer.save();
        } catch (_) {
          // Kui upload ebaõnnestub (nt offline), siis jätame beer.pendingSync true ja proovime hiljem uuesti
          continue;
        }
      }

      // 2) Push Firestore'i
      await _col(uid).doc(beer.id).set(beer.toMap(), SetOptions(merge: true));

      // 3) Märgi local synced
      beer.pendingSync = false;
      await beer.save();
    }
  }

  Future<void> _pullRemote(String uid) async {
    final snap = await _col(uid).get();

    for (final doc in snap.docs) {
      final data = doc.data();
      final remoteLast = (data['lastModified'] ?? 0) as int;

      final local = box.get(doc.id);

      if (local == null) {
        await box.put(
          doc.id,
          Beer(
            id: doc.id,
            name: (data['name'] ?? '') as String,
            rating: (data['rating'] ?? 3) as int,
            comment: (data['comment'] ?? '-') as String,
            imageLocalPath: null,
            imageUrl: data['imageUrl'] as String?,
            lastModified: remoteLast,
            isDeleted: (data['isDeleted'] ?? false) as bool,
            pendingSync: false,
          ),
        );
      } else {
        // last-write-wins
        if (remoteLast > local.lastModified) {
          local
            ..name = (data['name'] ?? local.name) as String
            ..rating = (data['rating'] ?? local.rating) as int
            ..comment = (data['comment'] ?? local.comment) as String
            ..imageUrl = data['imageUrl'] as String?
            ..isDeleted = (data['isDeleted'] ?? false) as bool
            ..lastModified = remoteLast
            ..pendingSync = false;

          await local.save();
        }
      }
    }
  }
}
