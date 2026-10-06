import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../data/models/content_models.dart';
import '../../data/models/incident_note.dart';
import '../../data/repositories/content_repository.dart';
import '../../data/services/civic_guidance_service.dart';
import '../../data/services/location/civic_location_service.dart';
import '../../data/services/incident_notes_service.dart';

/// Complete, pixel-perfect Rights Detail screen based directly on the
/// Stitch "Stopped by Police" design system, featuring interactive role selection,
/// mandatory DOs & critical DON'Ts with legal obligations, offline GPS beacon,
/// incident note recording modal with voice dictation & media upload, and statutory citations accordion.
class SituationCardScreen extends StatefulWidget {
  final String cardId;
  final UserRole userRole;

  const SituationCardScreen({
    super.key,
    required this.cardId,
    this.userRole = UserRole.affected,
  });

  @override
  State<SituationCardScreen> createState() => _SituationCardScreenState();
}

class _SituationCardScreenState extends State<SituationCardScreen> {
  final ContentRepository _repository = ContentRepository.instance;
  CardModel? _card;
  bool _isLoading = true;
  late UserRole _currentRole;
  bool _isSpeaking = false;
  bool _isLegalBasisExpanded = false;
  final TextEditingController _noteController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _currentRole = widget.userRole;
    _initTts();
    _loadCard();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("en-IN");
      await _flutterTts.setSpeechRate(0.48);
      await _flutterTts.setPitch(1.0);
    } catch (_) {}

    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setCancelHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
    _flutterTts.setErrorHandler((_) {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadCard() async {
    try {
      final card = await _repository.loadCard(widget.cardId);
      if (mounted) {
        setState(() {
          _card = card;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String get _title {
    if (_card != null && _card!.title.isNotEmpty) {
      final cleaned = _card!.title
          .replaceAll(RegExp(r'\[.*?\]'), '')
          .replaceAll(RegExp(r'\(DEFAULT\)', caseSensitive: false), '')
          .trim();
      if (cleaned.isNotEmpty) {
        return cleaned;
      }
    }
    return 'Stopped by Police';
  }

  String get _categoryLabel {
    if (_card != null && _card!.category.isNotEmpty) {
      return _card!.category.toUpperCase();
    }
    return 'POLICE / TRAFFIC & STREET STOPS';
  }

  StatutoryLegalBasisData get _statutoryData {
    final scenario = _card?.scenario ?? widget.cardId;
    return CivicGuidanceService.getStatutoryLegalBasis(
      scenarioId: scenario,
      fallbackTitle: _card?.title,
    );
  }


  Future<void> _callEmergency(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showToast('Calling $number...', icon: Icons.phone);
      }
    } catch (_) {
      _showToast('Calling $number...', icon: Icons.phone);
    }
  }

  Future<void> _shareGpsLocation() async {
    _showToast('Fetching live Google Maps coordinates...', icon: Icons.share_location);
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildPoliceStopMessage(location: location);
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: 'My Police Stop Location (Live Google Maps)',
    );
    _showToast('Location shared with live Google Maps link', icon: Icons.share_location);
  }

  Future<void> _toggleTts() async {
    if (_isSpeaking) {
      await _flutterTts.stop();
      if (mounted) {
        setState(() => _isSpeaking = false);
        _showToast('Audio paused', icon: Icons.pause_circle_rounded);
      }
    } else {
      final scenario = _card?.scenario ?? widget.cardId;
      final dos = CivicGuidanceService.getMandatoryDos(
        scenario: scenario,
        role: _currentRole,
      );
      final donts = CivicGuidanceService.getCriticalDonts(
        scenario: scenario,
        role: _currentRole,
      );

      final sb = StringBuffer();
      sb.writeln('Civic Protocol for $_title.');
      sb.writeln('Your present role is: ${_currentRole.displayName}.');
      sb.writeln('Mandatory DOs:');
      for (int i = 0; i < dos.length; i++) {
        sb.writeln('Number ${i + 1}: ${dos[i].title}. ${dos[i].subtitle}.');
      }
      sb.writeln("Critical DON'Ts:");
      for (int i = 0; i < donts.length; i++) {
        sb.writeln('Warning ${i + 1}: ${donts[i].title}. ${donts[i].subtitle}.');
      }
      sb.writeln('Statutory Legal Basis: ${_statutoryData.primaryAct}. ${_statutoryData.keyStatutorySafeguard}.');

      final textToSpeak = sb.toString();
      setState(() => _isSpeaking = true);
      _showToast("Reading aloud Mandatory DO's & DON'Ts", icon: Icons.volume_up);

      try {
        await _flutterTts.speak(textToSpeak);
      } catch (e) {
        if (mounted) {
          setState(() => _isSpeaking = false);
          _showToast('Speech error: $e', icon: Icons.error_outline);
        }
      }
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

  void _showNoteModal() {
    final AudioRecorder recorder = AudioRecorder();
    final ImagePicker picker = ImagePicker();
    bool isRecording = false;
    int recordSeconds = 0;
    Timer? timer;
    String? audioPath;
    String? audioDuration;
    final List<IncidentAttachment> modalAttachments = [];
    final TextEditingController officerCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                child: SingleChildScrollView(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5A00),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Record Incident Note',
                                style: GoogleFonts.montserrat(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A1C1C),
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: Color(0xFF5B4137), size: 20),
                            onPressed: () {
                              timer?.cancel();
                              recorder.dispose();
                              officerCtrl.dispose();
                              Navigator.pop(ctx);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Document officer names, badge numbers, voice evidence, or photos for legal safety.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF5B4137),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Officer / Badge input
                      TextField(
                        controller: officerCtrl,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF1A1C1C),
                        ),
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.badge_rounded,
                              color: Color(0xFF5B4137), size: 18),
                          hintText: 'Officer Name & Badge (e.g. SI Sharma, DL-4812)',
                          hintStyle: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            color: const Color(0xFF907065).withValues(alpha: 0.6),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFF3F3F3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Verbatim Statement + Voice Dictation Stack
                      Stack(
                        children: [
                          TextField(
                            controller: _noteController,
                            maxLines: 4,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              color: const Color(0xFF1A1C1C),
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'Describe what was demanded, stated, or done at this checkpoint...',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: const Color(0xFF907065).withValues(alpha: 0.6),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF3F3F3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(14, 14, 14, 44),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  isRecording
                                      ? 'RECORDING (${recordSeconds}s)'
                                      : 'TAP TO DICTATE',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: isRecording
                                        ? const Color(0xFFBA1A1A)
                                        : const Color(0xFF5B4137),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () async {
                                    if (isRecording) {
                                      timer?.cancel();
                                      final path = await recorder.stop();
                                      final mins = recordSeconds ~/ 60;
                                      final secs = recordSeconds % 60;
                                      setModalState(() {
                                        isRecording = false;
                                        audioPath = path ??
                                            'voice_note_${DateTime.now().millisecondsSinceEpoch}.m4a';
                                        audioDuration =
                                            '$mins:${secs.toString().padLeft(2, '0')}';
                                      });
                                    } else {
                                      final hasPerm =
                                          await recorder.hasPermission();
                                      if (!hasPerm) {
                                        _showToast(
                                            'Microphone permission required',
                                            icon: Icons.mic_off);
                                        return;
                                      }
                                      String? filePath;
                                      if (!kIsWeb) {
                                        final tempDir =
                                            await getTemporaryDirectory();
                                        filePath =
                                            '${tempDir.path}/incident_${DateTime.now().millisecondsSinceEpoch}.m4a';
                                      }
                                      await recorder.start(
                                        const RecordConfig(
                                            encoder: AudioEncoder.aacLc),
                                        path: filePath ?? '',
                                      );
                                      setModalState(() {
                                        isRecording = true;
                                        recordSeconds = 0;
                                      });
                                      timer?.cancel();
                                      timer = Timer.periodic(
                                          const Duration(seconds: 1), (t) {
                                        setModalState(() {
                                          recordSeconds++;
                                        });
                                      });
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: isRecording
                                          ? const Color(0xFFBA1A1A)
                                          : const Color(0xFFFF5A00),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isRecording
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Voice Note Preview Chip
                      if (audioPath != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5E7DC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.mic_rounded,
                                  color: Color(0xFF101F18), size: 16),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Voice recording attached (${audioDuration ?? "Audio Note"})',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF101F18),
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  setModalState(() {
                                    audioPath = null;
                                    audioDuration = null;
                                  });
                                },
                                child: const Icon(Icons.close_rounded,
                                    color: Color(0xFF101F18), size: 16),
                              ),
                            ],
                          ),
                        ),
                      ],

                      // Media Attachments List
                      if (modalAttachments.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(modalAttachments.length,
                              (index) {
                            final att = modalAttachments[index];
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEEEEE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    att.type == 'image'
                                        ? Icons.image_rounded
                                        : Icons.insert_drive_file_rounded,
                                    color: const Color(0xFFA83900),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 120),
                                    child: Text(
                                      att.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.montserrat(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  InkWell(
                                    onTap: () {
                                      setModalState(() {
                                        modalAttachments.removeAt(index);
                                      });
                                    },
                                    child: const Icon(Icons.close_rounded,
                                        size: 14, color: Color(0xFF907065)),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Attach Media Button
                      SizedBox(
                        width: double.infinity,
                        height: 42,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            showModalBottomSheet(
                              context: modalCtx,
                              backgroundColor: Colors.transparent,
                              builder: (subCtx) => Container(
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20)),
                                ),
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.camera_alt,
                                          color: Color(0xFFA83900)),
                                      title: const Text('Capture Camera Photo'),
                                      onTap: () async {
                                        Navigator.pop(subCtx);
                                        final img = await picker.pickImage(
                                            source: ImageSource.camera);
                                        if (img != null) {
                                          setModalState(() {
                                            modalAttachments.add(
                                              IncidentAttachment(
                                                id: 'att_${DateTime.now().millisecondsSinceEpoch}',
                                                name: img.name.isNotEmpty
                                                    ? img.name
                                                    : 'photo.jpg',
                                                path: img.path,
                                                type: 'image',
                                              ),
                                            );
                                          });
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.photo_library,
                                          color: Color(0xFFA83900)),
                                      title:
                                          const Text('Pick Photo from Gallery'),
                                      onTap: () async {
                                        Navigator.pop(subCtx);
                                        final img = await picker.pickImage(
                                            source: ImageSource.gallery);
                                        if (img != null) {
                                          setModalState(() {
                                            modalAttachments.add(
                                              IncidentAttachment(
                                                id: 'att_${DateTime.now().millisecondsSinceEpoch}',
                                                name: img.name.isNotEmpty
                                                    ? img.name
                                                    : 'screenshot.jpg',
                                                path: img.path,
                                                type: 'image',
                                              ),
                                            );
                                          });
                                        }
                                      },
                                    ),
                                    ListTile(
                                      leading: const Icon(Icons.attach_file,
                                          color: Color(0xFFA83900)),
                                      title: const Text(
                                          'Attach Document or Audio'),
                                      onTap: () async {
                                        Navigator.pop(subCtx);
                                        final res = await FilePicker.pickFiles();
                                        if (res.isNotEmpty) {
                                          final f = res.first;
                                          setModalState(() {
                                            modalAttachments.add(
                                              IncidentAttachment(
                                                id: 'att_${DateTime.now().millisecondsSinceEpoch}',
                                                name: f.name,
                                                path: f.path ?? '',
                                                type: 'document',
                                              ),
                                            );
                                          });
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.attach_file_rounded,
                              color: Color(0xFFFF5A00), size: 16),
                          label: Text(
                            '+ ATTACH PHOTO / SCREENSHOT / AUDIO',
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A1C1C),
                              letterSpacing: 0.6,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: const Color(0xFFF3F3F3),
                            side: BorderSide.none,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Save & Cancel Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                final text = _noteController.text.trim();
                                if (text.isEmpty &&
                                    audioPath == null &&
                                    modalAttachments.isEmpty) {
                                  _showToast('Please enter details or voice note',
                                      icon: Icons.info_outline_rounded);
                                  return;
                                }

                                final note = IncidentNote(
                                  id: 'note_${DateTime.now().millisecondsSinceEpoch}',
                                  title: _title,
                                  category: _categoryLabel.contains('TRAFFIC')
                                      ? 'TRAFFIC'
                                      : (_categoryLabel.contains('HOUSING')
                                          ? 'HOUSING'
                                          : (_categoryLabel.contains('COUPLE')
                                              ? 'COUPLES'
                                              : 'POLICE')),
                                  dateString:
                                      'Today, ${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}',
                                  gps: 'GPS: 28.6139° N, 77.2090° E',
                                  venue: _title,
                                  officer: officerCtrl.text.trim(),
                                  verbatim: text.isNotEmpty
                                      ? text
                                      : 'Voice/media incident evidence captured.',
                                  audioPath: audioPath,
                                  audioDuration: audioDuration,
                                  attachments: modalAttachments,
                                  createdAt: DateTime.now(),
                                );

                                await IncidentNotesService.saveNote(note);

                                timer?.cancel();
                                recorder.dispose();
                                officerCtrl.dispose();
                                _noteController.clear();
                                if (ctx.mounted) Navigator.pop(ctx);
                                _showToast(
                                    'Incident note saved to encrypted Vault',
                                    icon: Icons.verified_user_rounded);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF101F18),
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 13),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'SAVE TO INCIDENT VAULT',
                                style: GoogleFonts.montserrat(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.0,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton(
                            onPressed: () {
                              timer?.cancel();
                              recorder.dispose();
                              officerCtrl.dispose();
                              Navigator.pop(ctx);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 13),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: Text(
                              'CANCEL',
                              style: GoogleFonts.montserrat(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF5B4137),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChecklistModal() {
    final checklistData = CivicGuidanceService.getEmergencyChecklist(
      scenarioId: _card?.scenario ?? widget.cardId,
      role: _currentRole,
      fallbackTitle: _title,
      cardEvidenceChecklist: _card?.evidenceChecklist,
    );

    // Track checked items interactively inside the modal
    final checkedIndices = <int>{};

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
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
                  Row(
                    children: [
                      const Icon(Icons.checklist_rounded,
                          color: Color(0xFFA83900), size: 22),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          checklistData.title,
                          style: GoogleFonts.montserrat(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1A1C1C),
                            letterSpacing: 0.8,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (checkedIndices.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF15803D).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${checkedIndices.length}/${checklistData.items.length}',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF15803D),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    checklistData.subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFF5B4137),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ...List.generate(checklistData.items.length, (index) {
                    final isChecked = checkedIndices.contains(index);
                    final itemText = checklistData.items[index];
                    final displayNumber = '${index + 1}. ';
                    final fullText = itemText.startsWith(RegExp(r'^\d+\.'))
                        ? itemText
                        : '$displayNumber$itemText';

                    return _buildInteractiveChecklistTile(
                      text: fullText,
                      isChecked: isChecked,
                      onTap: () {
                        setModalState(() {
                          if (isChecked) {
                            checkedIndices.remove(index);
                          } else {
                            checkedIndices.add(index);
                          }
                        });
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showToast(
                          checkedIndices.length == checklistData.items.length
                              ? 'All ${checklistData.items.length} steps verified & completed'
                              : 'Emergency checklist acknowledged',
                          icon: Icons.verified_rounded,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA83900),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 13),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'ACKNOWLEDGE CHECKLIST',
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildInteractiveChecklistTile({
    required String text,
    required bool isChecked,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 2.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(
                isChecked
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: isChecked
                    ? const Color(0xFF15803D)
                    : const Color(0xFFA09490),
                size: 19,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12.5,
                  fontWeight: isChecked ? FontWeight.w700 : FontWeight.w500,
                  color: isChecked
                      ? const Color(0xFF101F18)
                      : const Color(0xFF2C2523),
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Navigation Bar
            _buildAppBar(),

            // 2. Scrollable Content Body
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF5A00),
                      ),
                    )
                  : Stack(
                      children: [
                        // Ambient Graphic Accents
                        _buildAmbientBackground(),

                        // Main Scrollable Rights Detail View
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(
                              18.0, 10.0, 18.0, 32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // A. Header Meta & Context Title
                              _buildHeaderMeta(),
                              const SizedBox(height: 18),

                              // B. Isometric Graphic Spotlight Card
                              _buildSpotlightCard(),
                              const SizedBox(height: 18),

                              // C. Role Selector Interactive Chips
                              _buildRoleSelector(),
                              const SizedBox(height: 14),

                              // D. Fast Action Sticky Tray (4 Action Buttons)
                              _buildFastActionTray(),
                              const SizedBox(height: 14),

                              // E. Role Context Alert Banner
                              _buildRoleAlertBanner(),
                              const SizedBox(height: 20),

                              // F. Mandatory DOs Section (Forest Green)
                              _buildDosSection(),
                              const SizedBox(height: 18),

                              // G. Critical DON'Ts Section (Crimson Red)
                              _buildDontsSection(),
                              const SizedBox(height: 18),

                              // H. Expandable Legal Basis Accordion
                              _buildLegalBasisAccordion(),
                              const SizedBox(height: 24),

                              // I. Bottom Action Pill & Return Button
                              _buildBottomActions(),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// App Bar matching the Stitch specification
  Widget _buildAppBar() {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9F9).withValues(alpha: 0.88),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE8E8E8), width: 0.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_rounded,
                    color: Color(0xFF1A1C1C), size: 22),
                onPressed: () => Navigator.pop(context),
              ),
              Image.asset(
                'assets/images/civic_logo.png',
                width: 26,
                height: 26,
                fit: BoxFit.contain,
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CIVIC',
                    style: GoogleFonts.montserrat(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFA83900),
                      letterSpacing: 1.4,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Rights Detail',
                    style: GoogleFonts.montserrat(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1A1C1C),
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFA83900),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: 17,
            ),
          ),
        ],
      ),
    );
  }

  /// Neo-Constructivist Background Graphic Accents
  Widget _buildAmbientBackground() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            Positioned(
              top: -30,
              right: -30,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFF5A00).withValues(alpha: 0.08),
                ),
              ),
            ),
            Positioned(
              top: 240,
              left: -40,
              child: Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8E8E8).withValues(alpha: 0.5),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 14,
              child: SvgPicture.string(
                '''<svg width="70" height="70" viewBox="0 0 100 100" fill="none">
                  <circle cx="50" cy="50" r="46" stroke="#907065" stroke-opacity="0.25" stroke-dasharray="4 4" stroke-width="1.5"/>
                  <circle cx="50" cy="50" r="26" stroke="#907065" stroke-opacity="0.2" stroke-width="1.5"/>
                  <rect fill="#FF5A00" height="6" width="6" x="47" y="5"/>
                </svg>''',
                width: 70,
                height: 70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Meta & Context Title
  Widget _buildHeaderMeta() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'PROTOCOL DESK',
              style: GoogleFonts.montserrat(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFA83900),
                letterSpacing: 1.4,
              ),
            ),
            const SizedBox(width: 6),
            const Text('•', style: TextStyle(color: Color(0xFF907065))),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _categoryLabel,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.montserrat(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B4137),
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                _title,
                style: GoogleFonts.montserrat(
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF101F18),
                  letterSpacing: -0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF5A00),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'LIVE GUIDE',
                    style: GoogleFonts.montserrat(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101F18),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Stay calm, composed, and verify statutory protocol. Constitutional protection is active from initial contact.',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: const Color(0xFF5B4137),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Isometric Spotlight Card with dual-tone pedestal artwork
  Widget _buildSpotlightCard() {
    final spot = CivicGuidanceService.getSpotlightMeta(
      scenarioId: _card?.scenario ?? widget.cardId,
      fallbackTitle: _title,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Soft Peach/Orange Peeking Arc
          Positioned(
            right: -24,
            bottom: -24,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF5A00).withValues(alpha: 0.18),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spot.tag,
                        style: GoogleFonts.montserrat(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFA83900),
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spot.title,
                        style: GoogleFonts.montserrat(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF101F18),
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        spot.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: const Color(0xFF5B4137),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),

                // Architectural Isometric Gateway Artwork
                SizedBox(
                  width: 76,
                  height: 76,
                  child: SvgPicture.string(
                    '''<svg viewBox="0 0 120 120" fill="none">
                      <path d="M60 20 L102 44 L60 68 L18 44 Z" fill="#eeeeee" stroke="#1a1c1c" stroke-linejoin="round" stroke-width="2"/>
                      <path d="M18 44 L60 68 L60 88 L18 64 Z" fill="#e2e2e2" stroke="#1a1c1c" stroke-linejoin="round" stroke-width="2"/>
                      <path d="M60 68 L102 44 L102 64 L60 88 Z" fill="#ff5a00" stroke="#1a1c1c" stroke-linejoin="round" stroke-width="2"/>
                      <path d="M42 34 Q60 14 78 34 V52 Q60 40 42 52 Z" fill="#ffffff" stroke="#1a1c1c" stroke-width="2"/>
                      <circle cx="60" cy="38" fill="#a83900" r="4"/>
                      <path d="M52 48 L68 48" stroke="#1a1c1c" stroke-linecap="round" stroke-width="2"/>
                    </svg>''',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Role Selector Interactive Chips
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SELECT YOUR PRESENT ROLE',
          style: GoogleFonts.montserrat(
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF5B4137),
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildRoleChip(UserRole.affected, 'AFFECTED'),
              const SizedBox(width: 8),
              _buildRoleChip(UserRole.accused, 'ACCUSED'),
              const SizedBox(width: 8),
              _buildRoleChip(UserRole.witness, 'WITNESS'),
              const SizedBox(width: 8),
              _buildRoleChip(UserRole.parent, 'PARENT / FRIEND'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRoleChip(UserRole role, String label) {
    final isSelected = _currentRole == role;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentRole = role;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF101F18) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x1F000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected) ...[
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 15),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF101F18),
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Fast Action Sticky Tray (4 Action Buttons)
  Widget _buildFastActionTray() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Read Aloud
          _buildActionButton(
            icon: _isSpeaking
                ? Icons.stop_circle_rounded
                : Icons.volume_up_rounded,
            label: _isSpeaking ? 'Pause TTS' : 'Read Aloud',
            iconBg: const Color(0xFFD5E7DC),
            iconColor: const Color(0xFF101F18),
            onTap: _toggleTts,
          ),
          // Share GPS
          _buildActionButton(
            icon: Icons.share_location_rounded,
            label: 'Share GPS',
            iconBg: const Color(0xFFE8E8E8),
            iconColor: const Color(0xFFA83900),
            onTap: _shareGpsLocation,
          ),
          // Record Note
          _buildActionButton(
            icon: Icons.mic_rounded,
            label: 'Record Note',
            iconBg: const Color(0xFFE8E8E8),
            iconColor: const Color(0xFF101F18),
            onTap: _showNoteModal,
          ),
          // SOS 112
          _buildActionButton(
            icon: Icons.emergency_rounded,
            label: 'SOS 112',
            iconBg: const Color(0xFFBA1A1A),
            iconColor: Colors.white,
            labelColor: const Color(0xFFBA1A1A),
            onTap: () => _callEmergency('112'),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color iconBg,
    required Color iconColor,
    Color? labelColor,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: labelColor ?? const Color(0xFF101F18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Role Context Alert Banner (Soft Peach)
  Widget _buildRoleAlertBanner() {
    final roleMessage = CivicGuidanceService.getRoleAlertMessage(
      scenarioId: _card?.scenario ?? widget.cardId,
      role: _currentRole,
      fallbackTitle: _title,
    );

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFDBCF).withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFFA83900),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              roleMessage,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF380D00),
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mandatory DOs Section (Forest Green Accent)
  Widget _buildDosSection() {
    final dos = CivicGuidanceService.getDos(
      scenarioId: _card?.scenario ?? widget.cardId,
      role: _currentRole,
      fallbackTitle: _title,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Green Accent Left Edge Bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              color: const Color(0xFF15803D),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFF15803D),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 15),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'MANDATORY DOS',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF101F18),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'LEGAL OBLIGATIONS',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF15803D),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dynamic DOs list
                ...dos.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGuidanceItem(
                        icon: Icons.verified_rounded,
                        iconColor: const Color(0xFF15803D),
                        title: item.title,
                        subtitle: item.subtitle,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Critical DON'Ts Section (Crimson Red Accent)
  Widget _buildDontsSection() {
    final donts = CivicGuidanceService.getDonts(
      scenarioId: _card?.scenario ?? widget.cardId,
      role: _currentRole,
      fallbackTitle: _title,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Red Accent Left Edge Bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(
              width: 6,
              color: const Color(0xFFDC2626),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 16, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "CRITICAL DON'TS",
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF101F18),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'PROHIBITED RISKS',
                        style: GoogleFonts.montserrat(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFDC2626),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dynamic DON'Ts list
                ...donts.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildGuidanceItem(
                        icon: Icons.cancel_rounded,
                        iconColor: const Color(0xFFDC2626),
                        title: item.title,
                        subtitle: item.subtitle,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidanceItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 19),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF101F18),
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF5B4137),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Expandable Legal Basis Accordion
  Widget _buildLegalBasisAccordion() {
    final data = _statutoryData;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEEEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E2E2)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isLegalBasisExpanded = !_isLegalBasisExpanded;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Icon(Icons.gavel_rounded,
                            color: Color(0xFFA83900), size: 19),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'STATUTORY CITATIONS & LEGAL BASIS',
                            style: GoogleFonts.montserrat(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101F18),
                              letterSpacing: 0.6,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isLegalBasisExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: const Color(0xFF101F18),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_isLegalBasisExpanded) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0xFFE2E2E2), height: 1),
                  const SizedBox(height: 12),

                  // Category Scope Tag
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA83900).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      data.categoryTag,
                      style: GoogleFonts.montserrat(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFA83900),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Primary Governing Act
                  _buildLegalBasisRow(
                    icon: Icons.menu_book_rounded,
                    label: 'PRIMARY GOVERNING ACT',
                    value: data.primaryAct,
                    url: data.primaryActUrl,
                    isHighlight: true,
                  ),
                  const SizedBox(height: 8),

                  // Statutory Sections
                  _buildLegalBasisRow(
                    icon: Icons.article_outlined,
                    label: 'ENACTED SECTIONS & PROVISIONS',
                    value: data.enactedSections,
                    url: data.enactedSectionsUrl,
                  ),
                  const SizedBox(height: 8),

                  // 2024 New Criminal Codes (BNS / BNSS)
                  _buildLegalBasisRow(
                    icon: Icons.published_with_changes_rounded,
                    label: '2024 BNS / BNSS / BSA EQUIVALENT',
                    value: data.newCriminalCodes,
                    url: data.newCriminalCodesUrl,
                    badgeColor: const Color(0xFF15803D),
                  ),
                  const SizedBox(height: 8),

                  // Landmark Precedent
                  _buildLegalBasisRow(
                    icon: Icons.account_balance_rounded,
                    label: 'LANDMARK JUDICIAL PRECEDENT',
                    value: data.landmarkPrecedent,
                    url: data.landmarkPrecedentUrl,
                  ),
                  const SizedBox(height: 8),

                  // Key Citizen Protection
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFD5E7DC)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            color: Color(0xFF15803D), size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'STATUTORY CITIZEN SAFEGUARD',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF15803D),
                                      letterSpacing: 0.4,
                                    ),
                                  ),
                                  if (data.keyStatutorySafeguardUrl != null || _resolveLegalUrl('SAFEGUARD', data.keyStatutorySafeguard) != null)
                                    MouseRegion(
                                      cursor: SystemMouseCursors.click,
                                      child: InkWell(
                                        onTap: () => _openLegalUrl(
                                          data.keyStatutorySafeguardUrl ?? _resolveLegalUrl('SAFEGUARD', data.keyStatutorySafeguard),
                                          'STATUTORY CITIZEN SAFEGUARD',
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'OFFICIAL DIRECTIVE',
                                                style: GoogleFonts.montserrat(
                                                  fontSize: 8.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: const Color(0xFF15803D),
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                              const SizedBox(width: 3),
                                              const Icon(Icons.open_in_new_rounded, size: 10, color: Color(0xFF15803D)),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                data.keyStatutorySafeguard,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Individual Statutory Provisions from Card Model
                  if (_card?.legalBasis != null && _card!.legalBasis.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFE2E2E2), height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.verified_outlined, color: Color(0xFFA83900), size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'SCENARIO STATUTES & PROVISIONS',
                          style: GoogleFonts.montserrat(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFA83900),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ..._card!.legalBasis.map((item) {
                      final itemUrl = (item.sourceUrl.isNotEmpty && !item.sourceUrl.contains('example'))
                          ? item.sourceUrl
                          : _resolveLegalUrl(item.status, '${item.act} ${item.section}');
                      final hasUrl = itemUrl != null && itemUrl.isNotEmpty;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 7),
                        child: MouseRegion(
                          cursor: hasUrl ? SystemMouseCursors.click : SystemMouseCursors.basic,
                          child: InkWell(
                            onTap: hasUrl ? () => _openLegalUrl(itemUrl, '${item.act} - ${item.section}') : null,
                            borderRadius: BorderRadius.circular(8),
                            hoverColor: const Color(0xFFA83900).withValues(alpha: 0.05),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFE2E2E2)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(Icons.menu_book_rounded, size: 14, color: Color(0xFF526259)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '${item.act} — ${item.section}',
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w700,
                                            color: const Color(0xFF101F18),
                                            decoration: hasUrl ? TextDecoration.underline : TextDecoration.none,
                                            decorationStyle: TextDecorationStyle.dotted,
                                            decorationColor: const Color(0xFFA83900).withValues(alpha: 0.5),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          item.status,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF526259),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (hasUrl) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA83900).withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'OFFICIAL ACT',
                                            style: GoogleFonts.montserrat(
                                              fontSize: 7.5,
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFFA83900),
                                              letterSpacing: 0.3,
                                            ),
                                          ),
                                          const SizedBox(width: 2.5),
                                          const Icon(
                                            Icons.open_in_new_rounded,
                                            size: 9,
                                            color: Color(0xFFA83900),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 10),

                  // Verification Badge & Official Source
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded,
                          color: Color(0xFF526259), size: 14),
                      const SizedBox(width: 5),
                      Expanded(
                        child: MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: InkWell(
                            onTap: () {
                              final sourceUrl = data.officialSourceUrl ??
                                  _resolveLegalUrl('SOURCE', data.officialSource, officialSource: data.officialSource);
                              if (sourceUrl != null) {
                                _openLegalUrl(sourceUrl, 'Official Source (${data.officialSource})');
                              }
                            },
                            child: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: '${data.lastVerified} • Source: ',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontStyle: FontStyle.italic,
                                      color: const Color(0xFF5B4137),
                                    ),
                                  ),
                                  TextSpan(
                                    text: data.officialSource,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: 10.5,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFFA83900),
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.open_in_new_rounded, size: 12, color: Color(0xFFA83900)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Launch external legal repository link in browser
  Future<void> _openLegalUrl(String? rawUrl, String label) async {
    if (rawUrl == null || rawUrl.trim().isEmpty) return;
    String url = rawUrl.trim();
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    final uri = Uri.tryParse(url);
    if (uri != null) {
      try {
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (!launched) {
          _showToast('Could not open external resource: $url', icon: Icons.link_off_rounded);
        } else {
          _showToast('Opening verified legal resource: $label', icon: Icons.open_in_new_rounded);
        }
      } catch (e) {
        _showToast('Opening $label: $url', icon: Icons.open_in_new_rounded);
      }
    }
  }

  /// Automatic fallback legal URL resolver for statutes, notifications, judgments, and ministries
  String? _resolveLegalUrl(String label, String value, {String? explicitUrl, String? officialSource}) {
    if (explicitUrl != null && explicitUrl.trim().isNotEmpty) {
      return explicitUrl.trim();
    }
    final lower = value.toLowerCase();
    final sourceLower = (officialSource ?? '').toLowerCase();

    // Check embedded domains in text or official source
    final domainRegex = RegExp(r'([a-zA-Z0-9-]+\.(?:nic\.in|gov\.in|org\.in|sci\.gov\.in|rbi\.org\.in|morth\.nic\.in|antiragging\.in|cybercrime\.gov\.in|ncw\.nic\.in|ncpcr\.gov\.in|labour\.gov\.in|mohua\.gov\.in))');
    final match = domainRegex.firstMatch(lower) ?? domainRegex.firstMatch(sourceLower);
    if (match != null) {
      return 'https://${match.group(1)}';
    }

    // Known judicial landmarks
    if (lower.contains('d.k. basu') || lower.contains('dk basu')) {
      return 'https://indiankanoon.org/doc/501198/';
    }
    if (lower.contains('arnesh kumar')) {
      return 'https://indiankanoon.org/doc/2982624/';
    }
    if (lower.contains('lalita kumari')) {
      return 'https://indiankanoon.org/doc/102852/';
    }
    if (lower.contains('puttaswamy')) {
      return 'https://indiankanoon.org/doc/91938676/';
    }
    if (lower.contains('shreya singhal')) {
      return 'https://indiankanoon.org/doc/110813550/';
    }
    if (lower.contains('neeraj dutta')) {
      return 'https://indiankanoon.org/doc/86461947/';
    }
    if (lower.contains('vishaka')) {
      return 'https://indiankanoon.org/doc/1031794/';
    }
    if (lower.contains('navtej singh johar')) {
      return 'https://indiankanoon.org/doc/168671544/';
    }
    if (lower.contains('shafin jahan')) {
      return 'https://indiankanoon.org/doc/178964722/';
    }

    // Specific statutes and ministries
    if (lower.contains('motor vehicles act') || lower.contains('cmvr')) {
      return 'https://www.indiacode.nic.in/handle/123456789/1798';
    }
    if (lower.contains('bharatiya nagarik suraksha') || lower.contains('bnss')) {
      return 'https://www.mha.gov.in/en/commoncontent/bharatiya-nagarik-suraksha-sanhita-2023';
    }
    if (lower.contains('bharatiya nyaya sanhita') || lower.contains('bns')) {
      return 'https://www.mha.gov.in/en/commoncontent/bharatiya-nyaya-sanhita-2023';
    }
    if (lower.contains('constitution of india')) {
      return 'https://www.india.gov.in/my-government/constitution-india';
    }
    if (lower.contains('code of criminal procedure') || lower.contains('crpc')) {
      return 'https://www.indiacode.nic.in/handle/123456789/1611';
    }
    if (lower.contains('information technology act') || lower.contains('it act')) {
      return 'https://www.meity.gov.in/content/information-technology-act-2000';
    }
    if (lower.contains('prevention of corruption')) {
      return 'https://www.cvc.gov.in/';
    }
    if (lower.contains('posh') || lower.contains('sexual harassment')) {
      return 'https://shebox.wcd.gov.in/';
    }
    if (lower.contains('model tenancy act')) {
      return 'https://mohua.gov.in/cms/model-tenancy-act.php';
    }

    // General fallback by label
    if (label.contains('JUDICIAL') || label.contains('PRECEDENT')) {
      return 'https://indiankanoon.org/search/?formInput=${Uri.encodeComponent(value)}';
    }
    if (label.contains('ACT') || label.contains('PROVISIONS') || label.contains('SECTIONS')) {
      return 'https://www.indiacode.nic.in';
    }

    return null;
  }

  Widget _buildLegalBasisRow({
    required IconData icon,
    required String label,
    required String value,
    String? url,
    bool isHighlight = false,
    Color? badgeColor,
  }) {
    final effectiveUrl = _resolveLegalUrl(label, value, explicitUrl: url);
    final hasLink = effectiveUrl != null && effectiveUrl.isNotEmpty;

    return MouseRegion(
      cursor: hasLink ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: InkWell(
        onTap: hasLink ? () => _openLegalUrl(effectiveUrl, label) : null,
        borderRadius: BorderRadius.circular(8),
        hoverColor: const Color(0xFFA83900).withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: badgeColor ?? const Color(0xFF526259), size: 13),
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: GoogleFonts.montserrat(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: badgeColor ?? const Color(0xFF526259),
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (hasLink) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFA83900).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'OFFICIAL RESOURCE',
                            style: GoogleFonts.montserrat(
                              fontSize: 7.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFA83900),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(width: 2.5),
                          const Icon(
                            Icons.open_in_new_rounded,
                            size: 9,
                            color: Color(0xFFA83900),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 18),
                child: Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w500,
                    color: const Color(0xFF101F18),
                    height: 1.35,
                    decoration: hasLink ? TextDecoration.underline : TextDecoration.none,
                    decorationColor: const Color(0xFFA83900).withValues(alpha: 0.45),
                    decorationStyle: TextDecorationStyle.dotted,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bottom Action Pill & Return Indicator
  Widget _buildBottomActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Return to categories button
        InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(24),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFF101F18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'RETURN TO CATEGORIES',
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF5B4137),
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),

        // Emergency Checklist CTA
        ElevatedButton.icon(
          onPressed: _showChecklistModal,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFA83900),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
          ),
          icon:
              const Icon(Icons.checklist_rounded, size: 17, color: Colors.white),
          label: Text(
            'CHECKLIST',
            style: GoogleFonts.montserrat(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ],
    );
  }
}
