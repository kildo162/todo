import 'dart:convert';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'note_model.dart';

class NoteController extends GetxController {
  static const _storageKey = 'notes_storage_v1';

  final notes = <Note>[].obs;
  final searchText = ''.obs;
  final filterTag = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  List<Note> get visibleNotes {
    final query = searchText.value.trim().toLowerCase();
    final tag = filterTag.value.trim().toLowerCase();

    return notes.where((note) {
      final matchesQuery = query.isEmpty
          ? true
          : (note.title.toLowerCase().contains(query) ||
                (note.content ?? '').toLowerCase().contains(query));
      final matchesTag = tag.isEmpty
          ? true
          : note.tags.any((t) => t.toLowerCase() == tag);
      return matchesQuery && matchesTag;
    }).toList()..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> addNote(
    String title, {
    String? content,
    List<String>? tags,
  }) async {
    final newNote = Note(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: content,
      tags: tags ?? const [],
    );
    notes.insert(0, newNote);
    await _save();
  }

  Future<void> updateNote(
    String id, {
    String? title,
    String? content,
    List<String>? tags,
  }) async {
    final idx = notes.indexWhere((n) => n.id == id);
    if (idx == -1) return;
    final current = notes[idx];
    final updated = current.copyWith(
      title: title ?? current.title,
      content: content ?? current.content,
      tags: tags ?? current.tags,
      updatedAt: DateTime.now(),
    );
    notes[idx] = updated;
    await _save();
  }

  Future<void> deleteNote(String id) async {
    notes.removeWhere((n) => n.id == id);
    await _save();
  }

  void setSearch(String value) {
    searchText.value = value;
  }

  void setFilterTag(String tag) {
    filterTag.value = tag;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      notes.assignAll(
        decoded.map((e) => Note.fromJson(e as Map<String, dynamic>)),
      );
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = jsonEncode(notes.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, data);
  }
}
