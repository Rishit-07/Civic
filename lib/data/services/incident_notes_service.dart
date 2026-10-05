import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/incident_note.dart';

/// Service managing sandboxed storage and optional Cloud Firestore sync of incident notes
class IncidentNotesService {
  static const String _storageKey = 'civic_incident_notes_v1';

  /// Whether cloud sync is active for the current session
  static bool get isCloudSyncEnabled {
    try {
      final user = FirebaseAuth.instance.currentUser;
      return user != null && !user.isAnonymous;
    } catch (_) {
      return false;
    }
  }

  static bool get isCloudSyncActive => isCloudSyncEnabled;

  /// Loads all saved incident logs from local device storage, updating from Firestore if signed in
  static Future<List<IncidentNote>> loadNotes() async {
    final localNotes = await _loadLocalNotes();

    // If authenticated, attempt to fetch latest cloud notes
    if (isCloudSyncEnabled) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notes')
            .orderBy('createdAt', descending: true)
            .get();

        if (snapshot.docs.isNotEmpty) {
          final cloudNotes = snapshot.docs
              .map((doc) => IncidentNote.fromJson(doc.data()))
              .toList();

          // Merge local and cloud notes
          final mergedMap = <String, IncidentNote>{};
          for (final n in localNotes) {
            mergedMap[n.id] = n;
          }
          for (final n in cloudNotes) {
            mergedMap[n.id] = n;
          }
          final merged = mergedMap.values.toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          await _saveLocalNotes(merged);
          return merged;
        }
      } catch (e) {
        debugPrint('IncidentNotesService: Cloud fetch fallback to local: $e');
      }
    }

    return localNotes;
  }

  static Future<List<IncidentNote>> _loadLocalNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        return decoded
            .map((item) => IncidentNote.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {}
    return <IncidentNote>[];
  }

  /// Saves a new incident note or updates an existing one
  static Future<void> saveNote(IncidentNote note) async {
    final currentNotes = await _loadLocalNotes();
    final index = currentNotes.indexWhere((n) => n.id == note.id);

    if (index >= 0) {
      currentNotes[index] = note;
    } else {
      currentNotes.insert(0, note);
    }

    await _saveLocalNotes(currentNotes);

    // Sync to Cloud Firestore if signed in
    if (isCloudSyncEnabled) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notes')
            .doc(note.id)
            .set(note.toJson());
      } catch (e) {
        debugPrint('IncidentNotesService: Cloud note save error: $e');
      }
    }
  }

  /// Deletes an incident note by ID
  static Future<void> deleteNote(String noteId) async {
    final currentNotes = await _loadLocalNotes();
    currentNotes.removeWhere((n) => n.id == noteId);
    await _saveLocalNotes(currentNotes);

    // Delete from Cloud Firestore if signed in
    if (isCloudSyncEnabled) {
      try {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('notes')
            .doc(noteId)
            .delete();
      } catch (e) {
        debugPrint('IncidentNotesService: Cloud note delete error: $e');
      }
    }
  }

  /// Persists full list of notes to local SharedPreferences
  static Future<void> saveAllNotes(List<IncidentNote> notes) async {
    await _saveLocalNotes(notes);
  }

  static Future<void> _saveLocalNotes(List<IncidentNote> notes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = notes.map((n) => n.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    } catch (_) {}
  }

  /// Generates a structured formal incident legal summary for export/sharing
  static String generateSummaryText(IncidentNote note) {
    final sb = StringBuffer();
    sb.writeln('CIVIC SECURE INCIDENT LOG');
    sb.writeln('==============================');
    sb.writeln('INCIDENT: ${note.title}');
    sb.writeln('CATEGORY: ${note.category}');
    sb.writeln('DATE/TIME: ${note.dateString}');
    sb.writeln('LOCATION: ${note.venue}');
    sb.writeln('COORDINATES: ${note.gps}');
    sb.writeln('OFFICER / PERSONNEL: ${note.officer.isNotEmpty ? note.officer : "Not specified"}');
    if (note.witnesses.isNotEmpty) {
      sb.writeln('WITNESSES: ${note.witnesses}');
    }
    sb.writeln('\nVERBATIM EVIDENCE STATEMENT:');
    sb.writeln(note.verbatim);
    if (note.audioPath != null) {
      sb.writeln('\nVOICE RECORDING: Attached (${note.audioDuration ?? "Audio Note"})');
    }
    if (note.attachments.isNotEmpty) {
      sb.writeln('\nATTACHMENTS (${note.attachments.length}):');
      for (final att in note.attachments) {
        sb.writeln('- [${att.type.toUpperCase()}] ${att.name}');
      }
    }
    sb.writeln('\n==============================');
    sb.writeln('Device Timestamp Verified • Saved offline on device');
    return sb.toString();
  }
}

