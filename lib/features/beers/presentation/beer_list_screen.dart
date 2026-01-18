import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../data/beer_local_repository.dart';
import '../../../models/beer.dart';
import 'beer_edit_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class BeerListScreen extends StatefulWidget {
  const BeerListScreen({super.key});

  @override
  State<BeerListScreen> createState() => _BeerListScreenState();
}

class _BeerListScreenState extends State<BeerListScreen> {
  final repo = BeerLocalRepository();

  Future<void> _openAdd() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BeerEditScreen()),
    );
  }

  Future<void> _openEdit(Beer beer) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BeerEditScreen(beerId: beer.id)),
    );
  }

  Future<void> _confirmDelete(Beer beer) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete beer?'),
        content: Text('Delete "${beer.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (ok == true) {
      await repo.softDelete(beer);
    }
  }

  Widget _leading(Beer beer) {
    final path = beer.imageLocalPath;
    if (path == null || path.isEmpty) return const Icon(Icons.local_bar);

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: kIsWeb
          ? Image.network(
        path,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      )
          : Image.file(
        File(path),
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = repo.listenableBox(); // Box<Beer>

    return Scaffold(
      appBar: AppBar(
        title: const Text('BeerBuddy'),
        actions: [
          IconButton(
            onPressed: () => FirebaseAuth.instance.signOut(),
            icon: const Icon(Icons.logout),
            tooltip: 'Log out',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: ValueListenableBuilder<Box<Beer>>(
        valueListenable: box.listenable(),
        builder: (context, b, _) {
          final items = repo.getAllNotDeleted();

          if (items.isEmpty) {
            return const Center(
              child: Text('Pole veel ühtegi õlut. Vajuta +'),
            );
          }

          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final beer = items[index];

              return ListTile(
                leading: _leading(beer),
                title: Text(beer.name),
                subtitle: Text('${beer.rating}/5 • ${beer.comment}'),
                onTap: () => _openEdit(beer),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete),
                      tooltip: 'Delete',
                      onPressed: () => _confirmDelete(beer),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit',
                      onPressed: () => _openEdit(beer),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
