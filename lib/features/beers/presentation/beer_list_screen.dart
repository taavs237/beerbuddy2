import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show File;

import '../../../data/beer_local_repository.dart';
import '../../../models/beer.dart';
import 'beer_edit_screen.dart';

class BeerListScreen extends StatefulWidget {
  const BeerListScreen({super.key});

  @override
  State<BeerListScreen> createState() => _BeerListScreenState();
}

class _BeerListScreenState extends State<BeerListScreen> {
  final BeerLocalRepository repo = BeerLocalRepository();

  List<Beer> _items = [];

  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _load() {
    final q = _query.trim();
    final list = q.isEmpty ? repo.getAllNotDeleted() : repo.searchNotDeleted(q);

    setState(() {
      _items = List<Beer>.from(list);
    });
  }

  ImageProvider? _avatarImage(Beer b) {
    final url = (b.imageUrl ?? '').trim();
    if (url.isNotEmpty) {
      return NetworkImage(url);
    }

    final path = (b.imageLocalPath ?? '').trim();
    if (path.isNotEmpty && !kIsWeb) {
      return FileImage(File(path));
    }

    return null;
  }

  Future<void> _openAdd() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BeerEditScreen()),
    );
    _load();
  }

  Future<void> _openEdit(String id) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => BeerEditScreen(beerId: id)),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beers'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAdd,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Search beers...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                  tooltip: 'Clear',
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _query = '');
                    _load();
                  },
                ),
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) {
                setState(() => _query = v);
                _load();
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: _items.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  _query.isEmpty
                      ? 'No beers yet.\nTap + to add one.'
                      : 'No results for "$_query".',
                  style: t.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final b = _items[i];
                final img = _avatarImage(b);

                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundImage: img,
                      child: img == null
                          ? Text(
                        b.name.isNotEmpty
                            ? b.name[0].toUpperCase()
                            : '?',
                      )
                          : null,
                    ),
                    title: Text(
                      b.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      'Rating: ${b.rating}/5',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: IconButton(
                      tooltip: 'Edit',
                      icon: const Icon(Icons.edit),
                      onPressed: () => _openEdit(b.id),
                    ),
                    onTap: () => _openEdit(b.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
