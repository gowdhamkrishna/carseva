import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Local JSON file-based storage service replacing Firebase Firestore.
/// Data is stored as JSON files under the app's documents directory.
class LocalStorageService {
  static LocalStorageService? _instance;
  late Directory _baseDir;
  bool _initialized = false;

  LocalStorageService._();

  static LocalStorageService get instance {
    _instance ??= LocalStorageService._();
    return _instance!;
  }

  Future<void> init() async {
    if (_initialized) return;
    final appDir = await getApplicationDocumentsDirectory();
    _baseDir = Directory('${appDir.path}/carseva_data');
    if (!await _baseDir.exists()) {
      await _baseDir.create(recursive: true);
    }
    _initialized = true;
  }

  /// Get the directory for a collection, creating it if needed.
  Future<Directory> _collectionDir(String collection) async {
    final dir = Directory('${_baseDir.path}/$collection');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Save a JSON document to a collection.
  Future<void> saveJson(String collection, String docId, Map<String, dynamic> data) async {
    final dir = await _collectionDir(collection);
    final file = File('${dir.path}/$docId.json');
    await file.writeAsString(jsonEncode(data));
  }

  /// Get a JSON document from a collection.
  Future<Map<String, dynamic>?> getJson(String collection, String docId) async {
    final dir = await _collectionDir(collection);
    final file = File('${dir.path}/$docId.json');
    if (!await file.exists()) return null;
    final content = await file.readAsString();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  /// Query all documents in a collection.
  Future<List<Map<String, dynamic>>> queryCollection(String collection, {int? limit}) async {
    final dir = await _collectionDir(collection);
    final files = await dir.list().where((e) => e.path.endsWith('.json')).toList();

    // Sort by modification time (newest first)
    final fileStats = <File, FileStat>{};
    for (final entity in files) {
      final file = File(entity.path);
      fileStats[file] = await file.stat();
    }

    final sortedFiles = fileStats.keys.toList()
      ..sort((a, b) => fileStats[b]!.modified.compareTo(fileStats[a]!.modified));

    final limitedFiles = limit != null ? sortedFiles.take(limit).toList() : sortedFiles;

    final results = <Map<String, dynamic>>[];
    for (final file in limitedFiles) {
      try {
        final content = await file.readAsString();
        results.add(jsonDecode(content) as Map<String, dynamic>);
      } catch (_) {
        // Skip malformed files
      }
    }
    return results;
  }

  /// Delete a JSON document.
  Future<void> deleteJson(String collection, String docId) async {
    final dir = await _collectionDir(collection);
    final file = File('${dir.path}/$docId.json');
    if (await file.exists()) {
      await file.delete();
    }
  }
}
