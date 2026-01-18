import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/beer_local_repository.dart';
import '../../../data/beer_sync_service.dart';
import '../../../models/beer.dart';

class BeerEditScreen extends StatefulWidget {
  final String? beerId;

  const BeerEditScreen({super.key, this.beerId});

  @override
  State<BeerEditScreen> createState() => _BeerEditScreenState();
}

class _BeerEditScreenState extends State<BeerEditScreen> {
  final ImagePicker _picker = ImagePicker();
  final repo = BeerLocalRepository();

  late final BeerSyncService _sync;

  Beer? _beer;

  String? _photoPath;
  final _name = TextEditingController();
  final _comment = TextEditingController();
  int _rating = 3;

  @override
  void initState() {
    super.initState();

    _sync = BeerSyncService(
      firestore: FirebaseFirestore.instance,
      auth: FirebaseAuth.instance,
      box: Hive.box<Beer>('beers'),
      storage: FirebaseStorage.instance,
    );

    if (widget.beerId != null) {
      _beer = repo.getById(widget.beerId!);
      final b = _beer;
      if (b != null) {
        _name.text = b.name;
        _comment.text = b.comment;
        _rating = b.rating;
        _photoPath = (b.imageLocalPath != null && b.imageLocalPath!.isNotEmpty)
            ? b.imageLocalPath
            : b.imageUrl;
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _comment.dispose();
    super.dispose();
  }

  Future<void> _choosePhotoSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Open camera'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.close),
                title: const Text('Cancel'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final XFile? file = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1800,
    );
    if (file == null) return;

    setState(() => _photoPath = file.path);
  }

  bool _looksLikeUrl(String? s) {
    if (s == null) return false;
    return s.startsWith('http://') || s.startsWith('https://');
  }

  Widget _preview() {
    final t = Theme.of(context);
    final path = _photoPath;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: t.colorScheme.surface.withOpacity(0.9),
          border: Border.all(color: t.dividerColor),
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: (path == null || path.isEmpty)
              ? Center(
            child: Text(
              'No photo yet',
              style: t.textTheme.bodySmall,
            ),
          )
              : _buildImage(path),
        ),
      ),
    );
  }

  Widget _buildImage(String path) {
    if (kIsWeb) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.broken_image)),
      );
    }

    if (_looksLikeUrl(path)) {
      return Image.network(
        path,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) =>
        const Center(child: Icon(Icons.broken_image)),
      );
    }

    return Image.file(
      File(path),
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) =>
      const Center(child: Icon(Icons.broken_image)),
    );
  }

  Future<void> _save() async {
    final name = _name.text.trim().isEmpty ? 'Unnamed beer' : _name.text.trim();
    final comment = _comment.text.trim().isEmpty ? '-' : _comment.text.trim();

    var rating = _rating;
    if (rating < 1) rating = 1;
    if (rating > 5) rating = 5;

    final chosen = _photoPath;
    final imageLocalPath =
    (chosen != null && chosen.isNotEmpty && !_looksLikeUrl(chosen))
        ? chosen
        : _beer?.imageLocalPath;

    if (_beer == null) {
      await repo.add(
        name: name,
        rating: rating,
        comment: comment,
        imageLocalPath: imageLocalPath,
      );
    } else {
      await repo.update(
        _beer!,
        name: name,
        rating: rating,
        comment: comment,
        imageLocalPath: imageLocalPath,
      );
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not logged in → cannot sync to Firebase')),
        );
      }
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      await _sync.syncNow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Synced to Firebase')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _deleteBeer() async {
    final b = _beer;
    if (b == null) return;

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete beer?'),
        content: const Text('This will remove it from your list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, true),
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await repo.softDelete(b);

    try {
      await _sync.syncNow();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deleted (synced)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Delete synced later: $e')),
        );
      }
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _beer != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Beer details' : 'Add beer'),
        actions: [
          if (isEditing)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete),
              onPressed: _deleteBeer,
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).colorScheme.surface.withOpacity(0.86),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _preview(),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _choosePhotoSource,
                    icon: const Icon(Icons.add_a_photo),
                    label:
                    Text(_photoPath == null ? 'Add photo' : 'Change photo'),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Beer name'),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        const Text('Rating'),
                        const Spacer(),
                        DropdownButton<int>(
                          value: _rating,
                          items: [1, 2, 3, 4, 5]
                              .map((v) => DropdownMenuItem(
                            value: v,
                            child: Text('$v'),
                          ))
                              .toList(),
                          onChanged: (v) => setState(() => _rating = v ?? 3),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _comment,
                  decoration: const InputDecoration(labelText: 'Comment'),
                  maxLines: 3,
                ),
                const SizedBox(height: 90),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
            ),
          ),
        ),
      ),
    );
  }
}
