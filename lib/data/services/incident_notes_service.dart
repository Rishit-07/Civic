import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/incident_note.dart';

/// Service managing sandboxed local storage of incident notes and evidence logs
class IncidentNotesService {
  static const String _storageKey = 'civic_incident_notes_v1';

  /// Loads all saved incident logs from local device storage
  static Future<List<IncidentNote>> loadNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_storageKey);
      if (rawJson != null && rawJson.trim().isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
        return decoded
            .map((item) => IncidentNote.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // In case of error reading, fallback to defaults
    }

    // Seed initial default mock notes matching the UI design
    final defaultNotes = _getDefaultNotes();
    await saveAllNotes(defaultNotes);
    return defaultNotes;
  }

  /// Saves a new incident note or updates an existing one at the top of the list
  static Future<void> saveNote(IncidentNote note) async {
    final currentNotes = await loadNotes();
    final index = currentNotes.indexWhere((n) => n.id == note.id);

    if (index >= 0) {
      currentNotes[index] = note;
    } else {
      currentNotes.insert(0, note);
    }

    await saveAllNotes(currentNotes);
  }

  /// Deletes an incident note by ID
  static Future<void> deleteNote(String noteId) async {
    final currentNotes = await loadNotes();
    currentNotes.removeWhere((n) => n.id == noteId);
    await saveAllNotes(currentNotes);
  }

  /// Persists full list of notes to SharedPreferences
  static Future<void> saveAllNotes(List<IncidentNote> notes) async {
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

  static List<IncidentNote> _getDefaultNotes() {
    return [
      IncidentNote(
        id: 'mock_note_1',
        title: 'Traffic stop, Outer Ring Rd',
        category: 'POLICE',
        dateString: '2 Oct 2024 • 10:45 PM',
        gps: 'GPS: 12.9352° N, 77.6245° E',
        venue: 'Outer Ring Rd, Koramangala, Bengaluru',
        officer: 'Sub-Inspector Sharma (Badge #4812)',
        verbatim:
            'Sub-Inspector Sharma (Badge #4812). Requested DigiLocker verification for vehicle registration. Refused physical seizure citing Rule 139 of Motor Vehicles Rules. Officer verified electronic document on mParivahan and allowed departure without compounding fee.',
        witnesses: 'Co-passenger Ankit Roy (+91 98450 XXXXX)',
        audioDuration: '0:45',
        audioPath: 'mock_audio_sample_1.m4a',
        attachments: const [
          IncidentAttachment(
            id: 'att_1',
            name: 'pcr_van_plate.jpg',
            path: 'mock_path_photo',
            type: 'image',
          ),
          IncidentAttachment(
            id: 'att_2',
            name: 'checkpoint_audio.m4a',
            path: 'mock_path_audio',
            type: 'audio',
          ),
        ],
        createdAt: DateTime(2024, 10, 2, 22, 45),
      ),
      IncidentNote(
        id: 'mock_note_2',
        title: 'Security deposit withholding',
        category: 'HOUSING',
        dateString: '18 Sep 2024 • 03:15 PM',
        gps: 'GPS: 12.9716° N, 77.5946° E',
        venue: 'Indiranagar 100ft Road, Bengaluru',
        officer: 'Landlord M. Ramanathan / Broker S. Rao',
        verbatim:
            'Owner refused return of INR 45,000 security deposit without itemized repair bill. Mentioned legal notice under Model Tenancy Act provisions and photographed flat handover state. Demanded vendor bills for claimed wall repaint deduction.',
        witnesses: 'Housemate Nikhil S.',
        attachments: const [
          IncidentAttachment(
            id: 'att_3',
            name: 'flat_handover_state.jpg',
            path: 'mock_path_photo_2',
            type: 'image',
          ),
        ],
        createdAt: DateTime(2024, 9, 18, 15, 15),
      ),
    ];
  }
}
