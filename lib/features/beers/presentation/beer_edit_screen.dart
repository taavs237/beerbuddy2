import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../data/beer_local_repository.dart';
import '../../../models/beer.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class BeerEditScreen extends StatefulWidget {
  final String? beerId;

  const BeerEditScreen({super.key, this.beerId});

  @override
  State<BeerEditScreen> createState() => _BeerEditScreenState();
}


class _BeerEditScreenState extends State<BeerEditScreen> {
  final ImagePicker _picker = ImagePicker();
  final repo = BeerLocalRepository();

  Beer? _beer;

  String? _photoPath;
  final _name = TextEditingController();
  final _comment = TextEditingController();
  int _rating = 3;

  @override
  void initState() {
    super.initState();

    if (widget.beerId != null) {
      _beer = repo.getById(widget.beerId!);
      final b = _beer;
      if (b != null) {
        _name.text = b.name;
        _comment.text = b.comment;
        _rating = b.rating;
        _photoPath = b.imageLocalPath;
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
      imageQuality: 80,
      maxWidth: 1600,
    );
    if (file == null) return;

    setState(() => _photoPath = file.path);
  }

  Widget _preview() {
    if (_photoPath == null) {
      return Container(
        height: 160,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text('No photo yet'),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: kIsWeb
          ? Image.network(
        _photoPath!, // webis see on tavaliselt blob URL
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
      )
          : Image.file(
        File(_photoPath!),
        height: 160,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.broken_image)),
      ),
    );

  }

  Future<void> _save() async {
    final name = _name.text.trim().isEmpty ? 'Unnamed beer' : _name.text.trim();
    final comment = _comment.text.trim().isEmpty ? '-' : _comment.text.trim();

    if (_rating < 1) _rating = 1;
    if (_rating > 5) _rating = 5;

    if (_beer == null) {
      await repo.add(
        name: name,
        rating: _rating,
        comment: comment,
        imageLocalPath: _photoPath,
      );
    } else {
      await repo.update(
        _beer!,
        name: name,
        rating: _rating,
        comment: comment,
        imageLocalPath: _photoPath,
      );
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _beer != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit beer' : 'Add beer')),
      body: Padding(
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
                label: Text(_photoPath == null ? 'Add photo' : 'Change photo'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Beer name'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Rating'),
                const SizedBox(width: 12),
                DropdownButton<int>(
                  value: _rating,
                  items: [1, 2, 3, 4, 5]
                      .map((v) => DropdownMenuItem(value: v, child: Text('$v')))
                      .toList(),
                  onChanged: (v) => setState(() => _rating = v ?? 3),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _comment,
              decoration: const InputDecoration(labelText: 'Comment'),
              maxLines: 2,
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
