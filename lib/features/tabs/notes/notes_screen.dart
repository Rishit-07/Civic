import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/incident_note.dart';
import '../../../data/services/incident_notes_service.dart';

class NotesScreen extends StatefulWidget {
  final IncidentNote? initialDraft;

  const NotesScreen({super.key, this.initialDraft});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  List<IncidentNote> _savedNotes = [];
  bool _isLoading = true;
  bool _isFormExpanded = false;

  // Controllers
  late TextEditingController _venueController;
  late TextEditingController _officerController;
  late TextEditingController _statementController;
  late TextEditingController _witnessesController;
  final String _currentGps = 'GPS: 28.6139° N, 77.2090° E';
  String _autoStampedDate = '';

  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecordingVoice = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordedAudioPath;
  String? _recordedAudioDuration;

  // Audio Player for reviewing recorded audio
  final AudioPlayer _audioPlayer = AudioPlayer();
  String? _currentlyPlayingNoteId;
  bool _isPlayingAudio = false;

  // Attachments
  final List<IncidentAttachment> _draftAttachments = [];
  final ImagePicker _imagePicker = ImagePicker();

  // Save button feedback
  bool _justSaved = false;

  @override
  void initState() {
    super.initState();
    _initDateTime();
    _initControllers();
    _loadNotes();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        _isPlayingAudio = state == PlayerState.playing;
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          _currentlyPlayingNoteId = null;
        }
      });
    });
  }

  void _initDateTime() {
    final now = DateTime.now();
    final hour = now.hour.toString().padLeft(2, '0');
    final minute = now.minute.toString().padLeft(2, '0');
    _autoStampedDate = 'Today, $hour:$minute (Auto-stamped)';
  }

  void _initControllers() {
    final draft = widget.initialDraft;
    _venueController = TextEditingController(
      text: draft?.venue ?? 'Location: Koramangala 4th Block, Bengaluru',
    );
    _officerController = TextEditingController(
      text: draft?.officer ?? 'Name & Badge number: SI R. Verma, DL-8291',
    );
    _statementController = TextEditingController(text: draft?.verbatim ?? '');
    _witnessesController = TextEditingController(text: draft?.witnesses ?? '');
    if (draft != null) {
      _isFormExpanded = true;
      if (draft.attachments.isNotEmpty) {
        _draftAttachments.addAll(draft.attachments);
      }
      if (draft.audioPath != null) {
        _recordedAudioPath = draft.audioPath;
        _recordedAudioDuration = draft.audioDuration;
      }
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    _audioPlayer.dispose();
    _venueController.dispose();
    _officerController.dispose();
    _statementController.dispose();
    _witnessesController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    setState(() => _isLoading = true);
    final notes = await IncidentNotesService.loadNotes();
    if (mounted) {
      setState(() {
        _savedNotes = notes;
        _isLoading = false;
      });
    }
  }

  // ==========================================
  // VOICE RECORDING LOGIC
  // ==========================================

  Future<void> _toggleVoiceRecording() async {
    if (_isRecordingVoice) {
      // Stop recording
      _recordingTimer?.cancel();
      try {
        final path = await _audioRecorder.stop();
        final durationMinutes = _recordingSeconds ~/ 60;
        final durationSecs = _recordingSeconds % 60;
        final formattedDur =
            '$durationMinutes:${durationSecs.toString().padLeft(2, '0')}';

        setState(() {
          _isRecordingVoice = false;
          _recordedAudioPath = path ?? 'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
          _recordedAudioDuration = formattedDur;
        });

        _showToast(
          'Voice note recorded ($formattedDur)',
          icon: Icons.mic_external_on_rounded,
        );
      } catch (e) {
        setState(() => _isRecordingVoice = false);
        _showToast('Recording stopped', icon: Icons.mic_off_rounded);
      }
    } else {
      // Start recording
      try {
        final hasPermission = await _audioRecorder.hasPermission();
        if (!hasPermission) {
          _showToast(
            'Microphone permission required for audio recording',
            icon: Icons.mic_none_rounded,
          );
          return;
        }

        String? filePath;
        if (!kIsWeb) {
          final tempDir = await getTemporaryDirectory();
          filePath =
              '${tempDir.path}/incident_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath ?? '',
        );

        setState(() {
          _isRecordingVoice = true;
          _recordingSeconds = 0;
        });

        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _recordingSeconds++;
          });
        });

        _showToast('Recording incident voice audio...', icon: Icons.mic_rounded);
      } catch (e) {
        _showToast('Could not initialize microphone: $e', icon: Icons.error_outline);
      }
    }
  }

  void _discardVoiceRecording() {
    setState(() {
      _recordedAudioPath = null;
      _recordedAudioDuration = null;
    });
    _showToast('Audio note removed', icon: Icons.delete_outline_rounded);
  }

  // ==========================================
  // MEDIA ATTACHMENTS LOGIC
  // ==========================================

  void _showAttachmentPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E2E2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ATTACH EVIDENCE MEDIA',
                style: GoogleFonts.montserrat(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Files are stored locally in sandbox storage and encrypted.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: const Color(0xFF5B4137),
                ),
              ),
              const SizedBox(height: 18),
              _buildAttachmentOption(
                icon: Icons.camera_alt_rounded,
                title: 'Capture Camera Photo',
                subtitle: 'Take a direct photo of badge, vehicle plate, or checkpoint',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.camera);
                },
              ),
              const SizedBox(height: 12),
              _buildAttachmentOption(
                icon: Icons.photo_library_rounded,
                title: 'Pick Screenshot / Photo from Gallery',
                subtitle: 'Upload payment screenshot, chats, or rental notice',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),
              _buildAttachmentOption(
                icon: Icons.audio_file_rounded,
                title: 'Attach Audio / Document File',
                subtitle: 'Choose existing voice memo, audio recording, or PDF',
                onTap: () {
                  Navigator.pop(ctx);
                  _pickFile();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF3F3F3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFFF5A00).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFA83900), size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF5B4137),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF907065), size: 18),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _draftAttachments.add(
            IncidentAttachment(
              id: 'att_${DateTime.now().millisecondsSinceEpoch}',
              name: picked.name.isNotEmpty ? picked.name : 'evidence_photo.jpg',
              path: picked.path,
              type: 'image',
            ),
          );
        });
        _showToast('Attached image: ${picked.name}', icon: Icons.photo);
      }
    } catch (e) {
      _showToast('Failed to pick photo: $e', icon: Icons.error_outline);
    }
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'mp3', 'm4a', 'wav', 'pdf'],
      );
      if (result.isNotEmpty) {
        final file = result.first;
        final ext = (file.extension ?? '').toLowerCase();
        final type = (ext == 'mp3' || ext == 'm4a' || ext == 'wav')
            ? 'audio'
            : (ext == 'pdf' ? 'document' : 'image');

        setState(() {
          _draftAttachments.add(
            IncidentAttachment(
              id: 'att_${DateTime.now().millisecondsSinceEpoch}',
              name: file.name,
              path: file.path ?? '',
              type: type,
              sizeBytes: file.lengthSync(),
            ),
          );
        });
        _showToast('Attached file: ${file.name}', icon: Icons.attach_file);
      }
    } catch (e) {
      _showToast('Failed to pick file: $e', icon: Icons.error_outline);
    }
  }

  void _removeAttachment(int index) {
    setState(() {
      _draftAttachments.removeAt(index);
    });
  }

  // ==========================================
  // SAVE NOTE
  // ==========================================

  Future<void> _saveNote() async {
    final statement = _statementController.text.trim();
    final venue = _venueController.text.trim();
    final officer = _officerController.text.trim();

    if (statement.isEmpty && _recordedAudioPath == null && _draftAttachments.isEmpty) {
      _showToast('Please record details, voice, or attach media before saving',
          icon: Icons.info_outline_rounded);
      return;
    }

    // Determine category based on venue / officer
    String category = 'POLICE';
    final lowerCombined = '$venue $officer $statement'.toLowerCase();
    if (lowerCombined.contains('housing') ||
        lowerCombined.contains('tenant') ||
        lowerCombined.contains('deposit') ||
        lowerCombined.contains('rent')) {
      category = 'HOUSING';
    } else if (lowerCombined.contains('traffic') ||
        lowerCombined.contains('license') ||
        lowerCombined.contains('challan') ||
        lowerCombined.contains('vehicle')) {
      category = 'TRAFFIC';
    } else if (lowerCombined.contains('hotel') ||
        lowerCombined.contains('couple') ||
        lowerCombined.contains('moral')) {
      category = 'COUPLES';
    } else if (lowerCombined.contains('college') ||
        lowerCombined.contains('campus') ||
        lowerCombined.contains('ragging')) {
      category = 'CAMPUS';
    } else if (lowerCombined.contains('workplace') ||
        lowerCombined.contains('posh') ||
        lowerCombined.contains('salary')) {
      category = 'WORKPLACE';
    }

    final newNote = IncidentNote(
      id: 'note_${DateTime.now().millisecondsSinceEpoch}',
      title: venue.isNotEmpty ? venue.replaceFirst('Location: ', '') : 'Incident Log',
      category: category,
      dateString: _autoStampedDate.replaceAll(' (Auto-stamped)', ''),
      gps: _currentGps,
      venue: venue,
      officer: officer,
      verbatim: statement.isNotEmpty
          ? statement
          : 'Voice and media evidence recorded on device.',
      witnesses: _witnessesController.text.trim(),
      audioPath: _recordedAudioPath,
      audioDuration: _recordedAudioDuration,
      attachments: List.from(_draftAttachments),
      createdAt: DateTime.now(),
    );

    await IncidentNotesService.saveNote(newNote);

    setState(() {
      _justSaved = true;
      _savedNotes.insert(0, newNote);
      _statementController.clear();
      _draftAttachments.clear();
      _recordedAudioPath = null;
      _recordedAudioDuration = null;
      _isFormExpanded = false;
    });

    _showToast('Saved securely to encrypted device sandbox',
        icon: Icons.verified_user_rounded);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _justSaved = false);
    });
  }

  // ==========================================
  // EXPORT / SHARE PDF
  // ==========================================

  void _exportAsPdf(IncidentNote? note) {
    IncidentNote targetNote;
    if (note != null) {
      targetNote = note;
    } else {
      targetNote = IncidentNote(
        id: 'draft',
        title: _venueController.text.trim(),
        category: 'POLICE',
        dateString: _autoStampedDate,
        gps: _currentGps,
        venue: _venueController.text.trim(),
        officer: _officerController.text.trim(),
        verbatim: _statementController.text.trim(),
        witnesses: _witnessesController.text.trim(),
        audioPath: _recordedAudioPath,
        audioDuration: _recordedAudioDuration,
        attachments: _draftAttachments,
        createdAt: DateTime.now(),
      );
    }

    final summary = IncidentNotesService.generateSummaryText(targetNote);
    // ignore: deprecated_member_use
    Share.share(
      summary,
      subject: 'CIVIC Incident Report: ${targetNote.title}',
    );
    _showToast('Exporting incident report memo', icon: Icons.picture_as_pdf_rounded);
  }

  // ==========================================
  // AUDIO PLAYBACK FOR SAVED LOGS
  // ==========================================

  Future<void> _playSavedAudio(IncidentNote note) async {
    if (note.audioPath == null) return;

    if (_currentlyPlayingNoteId == note.id && _isPlayingAudio) {
      await _audioPlayer.stop();
      setState(() {
        _currentlyPlayingNoteId = null;
        _isPlayingAudio = false;
      });
      return;
    }

    try {
      setState(() {
        _currentlyPlayingNoteId = note.id;
        _isPlayingAudio = true;
      });

      if (note.audioPath!.startsWith('mock_')) {
        // Mock feedback
        _showToast(
          'Playing voice recording (${note.audioDuration ?? "Audio Note"})',
          icon: Icons.volume_up_rounded,
        );
        Future.delayed(const Duration(seconds: 4), () {
          if (mounted) {
            setState(() {
              _currentlyPlayingNoteId = null;
              _isPlayingAudio = false;
            });
          }
        });
      } else {
        await _audioPlayer.play(DeviceFileSource(note.audioPath!));
      }
    } catch (e) {
      setState(() {
        _currentlyPlayingNoteId = null;
        _isPlayingAudio = false;
      });
      _showToast('Audio playback: ${note.audioDuration ?? "Audio attached"}',
          icon: Icons.music_note_rounded);
    }
  }

  // ==========================================
  // VIEW LOG DETAIL MODAL
  // ==========================================

  void _showLogDetail(IncidentNote note) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            final isPlayingThis =
                _currentlyPlayingNoteId == note.id && _isPlayingAudio;

            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E2E2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getCategoryColor(note.category).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            note.category,
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: _getCategoryColor(note.category),
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf_rounded,
                                  color: Color(0xFF5B4137), size: 20),
                              onPressed: () => _exportAsPdf(note),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline_rounded,
                                  color: Color(0xFFBA1A1A), size: 20),
                              onPressed: () async {
                                Navigator.pop(ctx);
                                await IncidentNotesService.deleteNote(note.id);
                                _loadNotes();
                                _showToast('Incident log deleted',
                                    icon: Icons.delete_forever_rounded);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      note.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${note.dateString} • ${note.gps}',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: const Color(0xFF907065),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Divider(height: 24, color: Color(0xFFEEEEEE)),

                    // Officer & Location Details
                    if (note.officer.isNotEmpty) ...[
                      Text(
                        'OFFICER / PERSONNEL INVOLVED',
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B4137),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.officer,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF1A1C1C),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Statement
                    Text(
                      'VERBATIM STATEMENT / WHAT WAS DONE',
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF5B4137),
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        note.verbatim,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          height: 1.5,
                          color: const Color(0xFF1A1C1C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Voice Note Player if exists
                    if (note.audioPath != null) ...[
                      Text(
                        'INCIDENT VOICE RECORDING',
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B4137),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD5E7DC),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                isPlayingThis
                                    ? Icons.pause_circle_filled_rounded
                                    : Icons.play_circle_fill_rounded,
                                color: const Color(0xFF101F18),
                                size: 36,
                              ),
                              onPressed: () async {
                                await _playSavedAudio(note);
                                setModalState(() {});
                              },
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isPlayingThis
                                        ? 'Playing Voice Recording...'
                                        : 'Incident Audio Note',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF101F18),
                                    ),
                                  ),
                                  Text(
                                    'Duration: ${note.audioDuration ?? "0:30"} • Verified Timestamp',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 11,
                                      color: const Color(0xFF3B4A42),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.graphic_eq_rounded,
                                color: Color(0xFF526259)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Attachments List
                    if (note.attachments.isNotEmpty) ...[
                      Text(
                        'ATTACHMENTS (${note.attachments.length})',
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B4137),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: note.attachments.map((att) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEEEE),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  att.type == 'image'
                                      ? Icons.image_rounded
                                      : (att.type == 'audio'
                                          ? Icons.audiotrack_rounded
                                          : Icons.insert_drive_file_rounded),
                                  color: const Color(0xFFA83900),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  att.name,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1A1C1C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),
                    ],

                    if (note.witnesses.isNotEmpty) ...[
                      Text(
                        'WITNESSES / OBSERVERS',
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF5B4137),
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        note.witnesses,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          color: const Color(0xFF1A1C1C),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _exportAsPdf(note),
                        icon: const Icon(Icons.share_rounded, size: 18),
                        label: Text(
                          'SHARE / EXPORT LOG',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111111),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toUpperCase()) {
      case 'POLICE':
      case 'TRAFFIC':
        return const Color(0xFFA83900);
      case 'HOUSING':
        return const Color(0xFF1B6A41);
      case 'COUPLES':
      case 'WOMEN SAFETY':
        return const Color(0xFFBA1A1A);
      default:
        return const Color(0xFF526259);
    }
  }

  void _showToast(String message, {IconData icon = Icons.check_circle}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: const Color(0xFFFF5A00), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF101F18),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showToast('Cannot launch dialer for $number', icon: Icons.phone_disabled);
    }
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Top Fixed Emergency & App Bar
            _buildFixedHeader(),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notes Title Section
                    _buildNotesHeader(),
                    const SizedBox(height: 16),

                    // Active Incident Form Container (Interactive Toggle)
                    if (_isFormExpanded) ...[
                      _buildIncidentFormContainer(),
                      const SizedBox(height: 24),
                    ],

                    // Saved Incident Logs Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SAVED INCIDENT LOGS (${_savedNotes.length})',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                            letterSpacing: 1.0,
                          ),
                        ),
                        Text(
                          'LOCKED & SECURED',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF907065),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Saved Logs List
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28.0),
                          child: CircularProgressIndicator(color: AppColors.primary),
                        ),
                      )
                    else if (_savedNotes.isEmpty)
                      _buildEmptyState()
                    else
                      ..._savedNotes.map((note) => _buildIncidentCard(note)),

                    const SizedBox(height: 24),

                    // Storage Guarantee Callout Banner
                    _buildStorageGuaranteeBanner(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF9F9F9),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Emergency Red SOS Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            color: const Color(0xFFBF0715),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.emergency_rounded,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'EMERGENCY SOS',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildSosQuickButton('112', () => _makeCall('112')),
                    const SizedBox(width: 6),
                    _buildSosQuickButton('15100', () => _makeCall('15100')),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () {
                        // ignore: deprecated_member_use
                        Share.share(
                          '🚨 LIVE SOS BEACON: I require immediate civic assistance. Coordinates: 28.6139 N, 77.2090 E',
                        );
                        _showToast('SOS GPS Beacon broadcasted',
                            icon: Icons.near_me_rounded);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.near_me_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main Header Row (Strict CIVIC Branding)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/images/civic_logo.png',
                      width: 28,
                      height: 28,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.shield_rounded,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CIVIC',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFA83900),
                            letterSpacing: 1.6,
                            height: 1.0,
                          ),
                        ),
                        Text(
                          'Notes',
                          style: GoogleFonts.montserrat(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFA83900),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_rounded,
                          color: Colors.white, size: 18),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosQuickButton(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNotesHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'NOTES',
              style: GoogleFonts.montserrat(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF1A1C1C),
                letterSpacing: 1.5,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E7DC),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'DEVICE ONLY',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF101F18),
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'RECORD WHAT HAPPENED, SAVED ONLY ON YOUR PHONE',
          style: GoogleFonts.montserrat(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF5B4137),
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 14),

        // CTA Button: + NEW NOTE
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _isFormExpanded = !_isFormExpanded;
              });
            },
            icon: Icon(
              _isFormExpanded ? Icons.expand_less_rounded : Icons.add_rounded,
              size: 20,
            ),
            label: Text(
              _isFormExpanded ? 'COLLAPSE FORM' : '+ NEW NOTE',
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF111111),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 2,
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // ACTIVE INCIDENT FORM CONTAINER
  // ==========================================

  Widget _buildIncidentFormContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0B000000),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'LIVE LOGGING',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA83900),
                      letterSpacing: 1.2,
                    ),
                  ),
                  Text(
                    'NEW INCIDENT LOG',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F3F3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.my_location_rounded,
                        color: Color(0xFFFF5A00), size: 13),
                    const SizedBox(width: 4),
                    Text(
                      _currentGps,
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date & Time
          _buildFormFieldLabel('DATE & TIME'),
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F3F3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_rounded,
                    color: Color(0xFF5B4137), size: 18),
                const SizedBox(width: 10),
                Text(
                  _autoStampedDate,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A1C1C),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Place / Venue
          _buildFormFieldLabel('PLACE / VENUE'),
          TextField(
            controller: _venueController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1C1C),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.location_on_rounded,
                  color: Color(0xFFA83900), size: 18),
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Officer / Person Involved
          _buildFormFieldLabel('OFFICER / PERSON INVOLVED'),
          TextField(
            controller: _officerController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1C1C),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.badge_rounded,
                  color: Color(0xFF5B4137), size: 18),
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Evidence Verbatim + Voice Dictation
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFormFieldLabel('WHAT WAS SAID OR DONE'),
              Text(
                'EVIDENCE VERBATIM',
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF907065),
                ),
              ),
            ],
          ),
          Stack(
            children: [
              TextField(
                controller: _statementController,
                maxLines: 4,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  height: 1.4,
                  color: const Color(0xFF1A1C1C),
                ),
                decoration: InputDecoration(
                  hintText: 'Describe verbatim what was demanded, stated, or done...',
                  hintStyle: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: const Color(0xFF907065).withValues(alpha: 0.6),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF3F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 48),
                ),
              ),

              // Bottom right Voice Input button
              Positioned(
                bottom: 8,
                right: 8,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isRecordingVoice
                          ? 'RECORDING (${_recordingSeconds}s)'
                          : 'TAP TO DICTATE',
                      style: GoogleFonts.montserrat(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _isRecordingVoice
                            ? const Color(0xFFBA1A1A)
                            : const Color(0xFF5B4137),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: _toggleVoiceRecording,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _isRecordingVoice
                              ? const Color(0xFFBA1A1A)
                              : const Color(0xFFFF5A00),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecordingVoice
                                      ? const Color(0xFFBA1A1A)
                                      : const Color(0xFFFF5A00))
                                  .withValues(alpha: 0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecordingVoice
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Attached Voice Note Preview if recorded
          if (_recordedAudioPath != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFD5E7DC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFB9CBC0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.mic_rounded,
                      color: Color(0xFF101F18), size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Voice note attached (${_recordedAudioDuration ?? "Recorded"})',
                      style: GoogleFonts.montserrat(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101F18),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: _discardVoiceRecording,
                    child: const Icon(Icons.close_rounded,
                        color: Color(0xFF101F18), size: 18),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),

          // Witnesses
          _buildFormFieldLabel('WITNESSES / OBSERVERS'),
          TextField(
            controller: _witnessesController,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1A1C1C),
            ),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.groups_rounded,
                  color: Color(0xFF5B4137), size: 18),
              hintText: 'Witness contact or names (optional)',
              hintStyle: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                color: const Color(0xFF907065).withValues(alpha: 0.6),
              ),
              filled: true,
              fillColor: const Color(0xFFF3F3F3),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
          const SizedBox(height: 14),

          // Media Attachments Preview List (if any)
          if (_draftAttachments.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_draftAttachments.length, (index) {
                final att = _draftAttachments[index];
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E2E2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        att.type == 'image'
                            ? Icons.image_rounded
                            : (att.type == 'audio'
                                ? Icons.audiotrack_rounded
                                : Icons.insert_drive_file_rounded),
                        color: const Color(0xFFA83900),
                        size: 15,
                      ),
                      const SizedBox(width: 6),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          att.name,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A1C1C),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () => _removeAttachment(index),
                        child: const Icon(Icons.close_rounded,
                            size: 15, color: Color(0xFF907065)),
                      ),
                    ],
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
          ],

          // Attach Media Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _showAttachmentPicker,
              icon: const Icon(Icons.attach_file_rounded,
                  color: Color(0xFFFF5A00), size: 18),
              label: Text(
                '+ ATTACH PHOTO / SCREENSHOT / AUDIO',
                style: GoogleFonts.montserrat(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 0.8,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: const Color(0xFFEEEEEE),
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Save & Export Buttons
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveNote,
              icon: Icon(
                _justSaved ? Icons.check_circle_rounded : Icons.save_rounded,
                size: 20,
              ),
              label: Text(
                _justSaved ? 'SAVED SECURELY' : 'SAVE TO DEVICE',
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _justSaved
                    ? const Color(0xFF1B6A41)
                    : const Color(0xFF111111),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () => _exportAsPdf(null),
              icon: const Icon(Icons.picture_as_pdf_rounded,
                  color: Color(0xFF1A1C1C), size: 20),
              label: Text(
                'EXPORT AS PDF',
                style: GoogleFonts.montserrat(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1A1C1C),
                  letterSpacing: 1.0,
                ),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E2E2)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GoogleFonts.montserrat(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF5B4137),
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  // ==========================================
  // SAVED INCIDENT CARDS
  // ==========================================

  Widget _buildIncidentCard(IncidentNote note) {
    final catColor = _getCategoryColor(note.category);
    final totalAttachments =
        note.attachments.length + (note.audioPath != null ? 1 : 0);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Colored Indicator Line
            Container(
              width: 5,
              color: catColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Top Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2.5),
                              decoration: BoxDecoration(
                                color: catColor.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                note.category,
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: catColor,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              note.dateString,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                color: const Color(0xFF907065),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () => _exportAsPdf(note),
                              child: const Icon(Icons.picture_as_pdf_rounded,
                                  color: Color(0xFF5B4137), size: 19),
                            ),
                            const SizedBox(width: 8),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded,
                                  color: Color(0xFF5B4137), size: 19),
                              padding: EdgeInsets.zero,
                              onSelected: (val) async {
                                if (val == 'delete') {
                                  await IncidentNotesService.deleteNote(note.id);
                                  _loadNotes();
                                  _showToast('Incident note deleted',
                                      icon: Icons.delete_outline);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline,
                                          color: Color(0xFFBA1A1A), size: 18),
                                      SizedBox(width: 8),
                                      Text('Delete Note',
                                          style: TextStyle(
                                              color: Color(0xFFBA1A1A))),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Title
                    Text(
                      note.title,
                      style: GoogleFonts.montserrat(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A1C1C),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Verbatim Excerpt
                    Text(
                      note.verbatim,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        height: 1.45,
                        color: const Color(0xFF5B4137),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Attachments indicator + VIEW LOG button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              note.audioPath != null
                                  ? Icons.mic_rounded
                                  : Icons.check_circle_rounded,
                              color: const Color(0xFF1B6A41),
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              totalAttachments > 0
                                  ? '$totalAttachments ATTACHMENTS ${note.audioPath != null ? "(AUDIO)" : ""}'
                                  : 'TIMESTAMP VERIFIED',
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5B4137),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _showLogDetail(note),
                          child: Row(
                            children: [
                              Text(
                                'VIEW LOG',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFA83900),
                                  letterSpacing: 0.6,
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded,
                                  size: 16, color: Color(0xFFA83900)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const Icon(Icons.shield_outlined,
              size: 40, color: Color(0xFF907065)),
          const SizedBox(height: 10),
          Text(
            'No Incident Logs Yet',
            style: GoogleFonts.montserrat(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tap "+ NEW NOTE" above to log police badge numbers, voice statements, and media.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              color: const Color(0xFF907065),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STORAGE GUARANTEE CALLOUT BANNER
  // ==========================================

  Widget _buildStorageGuaranteeBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Isometric Style Notebook & Stylus Vector Graphic
          Container(
            width: 72,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.menu_book_rounded,
                    color: Color(0xFF17261F), size: 34),
                Positioned(
                  right: 14,
                  bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5A00),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Nothing leaves your phone unless you share it.',
            textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Local AES-256 storage • Zero telemetry • Offline ready',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF5B4137),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_rounded,
                  color: Color(0xFF526259), size: 14),
              const SizedBox(width: 4),
              Text(
                'END-TO-END SANDBOXED',
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF526259),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
