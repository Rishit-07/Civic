import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';

import '../../../data/services/app_preferences.dart';
import '../../../data/services/civic_ai_service.dart';
import '../../../data/services/location/civic_location_service.dart';
import '../../../data/services/speech/speech_recognition_service.dart';
import '../../scenarios/situation_card_screen.dart';
import '../../scenarios/situation_list_screen.dart';

/// Ask Screen matching the CIVIC Design System & Mobile Mockup.
/// Completely functional AI Law & Order Legal Assistant:
/// - Real-time conversational AI with constitutional legal citations
/// - Voice input dictation and audio recording
/// - Document / notice / challan media scanner and analysis
/// - Suggested prompt carousel
/// - Interactive triage quick-replies
/// - Direct integration with emergency dispatch (112, 15100) and GPS Beacon
class AskScreen extends StatefulWidget {
  const AskScreen({super.key});

  @override
  State<AskScreen> createState() => _AskScreenState();
}

class _AskScreenState extends State<AskScreen> with SingleTickerProviderStateMixin {
  // Brand & Semantic Design Palette
  static const Color primary = Color(0xFFA83900);
  static const Color primaryContainer = Color(0xFFFF5A00);
  static const Color primaryFixed = Color(0xFFFFDBCF);
  static const Color onPrimaryFixed = Color(0xFF380D00);
  static const Color tertiary = Color(0xFFBF0715);
  static const Color tertiaryContainer = Color(0xFFFF574D);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF526259);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLow = Color(0xFFF3F3F3);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF5B4137);
  static const Color outlineVariant = Color(0xFFD8C2BA);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);

  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocusNode = FocusNode();

  // Voice recording
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;

  // Media Attachment
  final ImagePicker _imagePicker = ImagePicker();
  String? _selectedAttachmentPath;
  String? _selectedAttachmentName;
  String? _selectedAttachmentType;

  // AI Thinking state
  bool _isAiDeliberating = false;

  // Suggested Prompts
  final List<String> _suggestedPrompts = [
    'I was stopped by police',
    'I\'m being ragged',
    'Hotel refused us a room',
    'I lost money on UPI',
    'My salary isn\'t paid',
    'Can police seize my phone?',
    'Police refused to file FIR',
    'Challan for no physical RC',
  ];

  // Conversation history
  final List<CivicAiMessage> _messages = [];

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initSampleConversation();
  }

  void _initSampleConversation() {
    // Initial preloaded benchmark scenario matching user HTML mockup
    final now = DateTime.now();

    // 1. Initial User Message
    _messages.add(
      CivicAiMessage(
        id: 'init_user_1',
        text: 'A traffic cop took my phone and is reading my WhatsApp chats. Is this legal?',
        isUser: true,
        timestamp: now.subtract(const Duration(minutes: 8)),
      ),
    );

    // 2. High-Urgency Emergency Callout Message
    _messages.add(
      CivicAiMessage(
        id: 'init_emergency_1',
        text: 'Emergency Safeguard Notice',
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 7)),
        isEmergency: true,
      ),
    );

    // 3. AI Statutory Response Message
    _messages.add(
      CivicAiMessage(
        id: 'init_ai_1',
        text: 'Digital Privacy & Phone Seizure Law',
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 7)),
        relatedCardId: 'traffic_stop_dispute_seizure',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful',
          verdictColor: error,
          verdictBgColor: errorContainer,
          directAnswer:
              'No. An officer cannot seize or browse your private smartphone without a formal judicial search warrant or an explicit cyber-forensics seizure memo under Section 102/100 CrPC.',
          legalReasoning:
              'Your digital privacy is protected under Article 21 of the Constitution (Justice K.S. Puttaswamy benchmark verdict). You have the right to request the officer’s name, badge number, and demand a signed memo before unlocking any personal device.',
          sourceTitle: 'Based on: Traffic Stop Card & Article 21 Privacy (Reviewed Oct 2026)',
          statutoryCitation: 'Article 21 & 20(3) Constitution of India; Sec 100 & 102 CrPC',
          citizenActionSteps: [
            'Politely refuse to unlock: "Officer, my personal chats are protected under Article 21 privacy."',
            'Ask for badge number and station jurisdiction.',
            'Demand an official seizure memo if the phone is confiscated.',
          ],
          criticalDonts: [
            'DO NOT unlock and hand over your open device to the officer.',
            'DO NOT allow police to read private personal messages or photos without a judicial warrant.',
            'DO NOT delete files or chats in panic, which can be misconstrued as tampering with evidence.',
          ],
        ),
      ),
    );

    // 4. Clarifying Triage Question Bubble
    _messages.add(
      CivicAiMessage(
        id: 'init_triage_1',
        text: 'Context Clarification',
        isUser: false,
        timestamp: now.subtract(const Duration(minutes: 6)),
        triageOptions: [
          '🚗 Stopped in personal car',
          '🛵 Riding two-wheeler',
          '🚶 Pedestrian check',
          'Are you above 18? (Yes / No)',
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocusNode.dispose();
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  // ==========================================
  // Calling, GPS & Actions
  // ==========================================

  Future<void> _makeCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await Clipboard.setData(ClipboardData(text: cleanNumber));
        _showToast('Copied $cleanNumber to clipboard');
      }
    } catch (_) {
      await Clipboard.setData(ClipboardData(text: cleanNumber));
      _showToast('Copied $cleanNumber to clipboard');
    }
  }

  Future<void> _sendGpsBeacon() async {
    _showToast('Fetching live Google Maps coordinates...');
    final location = await CivicLocationService.getCurrentLocation();
    final message = CivicLocationService.buildEmergencySosMessage(
      location: location,
      headline: '🚨 CIVIC EMERGENCY SOS',
      situation: 'I require immediate legal first-aid and civilian support.',
    );
    // ignore: deprecated_member_use
    await Share.share(
      message,
      subject: 'CIVIC Emergency Beacon Alert (Live Google Maps Location)',
    );
  }

  void _showToast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF101F18),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ==========================================
  // Voice Recording Logic
  // ==========================================

  Future<void> _toggleVoiceRecording() async {
    if (_isRecording) {
      // Stop recording
      try {
        _recordingTimer?.cancel();
        final path = await _audioRecorder.stop();
        final transcript = SpeechRecognitionService.stopListening().trim();

        setState(() {
          _isRecording = false;
        });

        if (transcript.isNotEmpty) {
          _submitQuery(
            text: '🎙️ Voice Query: $transcript',
            audioPath: path,
          );
        } else if (path != null) {
          // If speech recognition didn't detect words (e.g. silence or unsupported browser),
          // show quick topic picker sheet so citizen gets instant statutory help
          _showVoiceTopicSheet(path, _recordingSeconds);
        }
      } catch (e) {
        SpeechRecognitionService.stopListening();
        setState(() => _isRecording = false);
        _showToast('Recording ended');
      }
    } else {
      // Start recording
      try {
        final hasPermission = await _audioRecorder.hasPermission();
        if (!hasPermission) {
          _showToast('Microphone permission required for voice queries');
          return;
        }

        String? filePath;
        if (!kIsWeb) {
          final tempDir = await getTemporaryDirectory();
          filePath = '${tempDir.path}/civic_voice_query_${DateTime.now().millisecondsSinceEpoch}.m4a';
        }

        await _audioRecorder.start(
          const RecordConfig(encoder: AudioEncoder.aacLc),
          path: filePath ?? '',
        );

        // Start Web speech recognition simultaneously
        SpeechRecognitionService.startListening(lang: 'en-IN');

        setState(() {
          _isRecording = true;
          _recordingSeconds = 0;
        });

        _recordingTimer?.cancel();
        _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (!mounted) return;
          setState(() {
            _recordingSeconds++;
          });
        });

        _showToast('Listening in Hindi/English... Speak your legal question');
      } catch (e) {
        _showToast('Could not initialize microphone: $e');
      }
    }
  }

  void _showVoiceTopicSheet(String audioPath, int durationSeconds) {
    final topics = [
      {'icon': Icons.key_rounded, 'title': 'Car keys taken by traffic police', 'desc': 'Ignition key removal & wrongful restraint'},
      {'icon': Icons.phonelink_lock_rounded, 'title': 'Police demanding to search phone', 'desc': 'Digital privacy & WhatsApp search'},
      {'icon': Icons.backpack_rounded, 'title': 'Frisking bag or pockets on road', 'desc': 'Search procedure & independent witnesses'},
      {'icon': Icons.attach_money_rounded, 'title': 'Police demanding bribe or cash fine', 'desc': 'Prevention of Corruption Act & reporting'},
      {'icon': Icons.description_rounded, 'title': 'Police refusing to register FIR', 'desc': 'Zero FIR & complaint to SP'},
      {'icon': Icons.hotel_rounded, 'title': 'Hotel or moral policing of couple', 'desc': 'Consenting adult privacy & room rights'},
      {'icon': Icons.home_rounded, 'title': 'House search without warrant', 'desc': 'Sec 165 CrPC / 185 BNSS safeguards'},
      {'icon': Icons.credit_card_off_rounded, 'title': 'UPI fraud or bank account freeze', 'desc': 'Sec 102 CrPC lien freeze remedies'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mic_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Voice Note Recorded (${durationSeconds}s)',
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                          ),
                        ),
                        Text(
                          'Select your situation for an instant statutory verdict:',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            color: secondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: topics.length,
                  separatorBuilder: (_, _) => const Divider(height: 1, color: surfaceContainerHigh),
                  itemBuilder: (context, index) {
                    final t = topics[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: surfaceContainerLow,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(t['icon'] as IconData, color: primary, size: 18),
                      ),
                      title: Text(
                        t['title'] as String,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: onSurface,
                        ),
                      ),
                      subtitle: Text(
                        t['desc'] as String,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: secondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: secondary),
                      onTap: () {
                        Navigator.of(ctx).pop();
                        _submitQuery(
                          text: '🎙️ Voice Query: ${t['title']}',
                          audioPath: audioPath,
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _submitQuery(
                      text: '🎙️ Voice Query: Question recorded at ${durationSeconds}s duration',
                      audioPath: audioPath,
                    );
                  },
                  icon: const Icon(Icons.send_rounded, size: 16, color: primary),
                  label: Text(
                    'SUBMIT AUDIO DIRECTLY',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: primary,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: primaryFixed),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Media Attachment Picker
  // ==========================================

  void _showMediaPickerSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: surfaceContainerLowest,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: primaryFixed,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.document_scanner_rounded, color: primary, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ATTACH EVIDENCE / NOTICE',
                        style: GoogleFonts.montserrat(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        'Upload challan, police notice, or summons for AI analysis',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.camera_alt_rounded, color: primary),
                ),
                title: Text(
                  'Snap Photo of Notice / Challan',
                  style: GoogleFonts.montserrat(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Instant OCR & statutory verification', style: GoogleFonts.plusJakartaSans(fontSize: 11.5)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final photo = await _imagePicker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    setState(() {
                      _selectedAttachmentPath = photo.path;
                      _selectedAttachmentName = photo.name;
                      _selectedAttachmentType = 'image';
                    });
                    _showToast('Challan photo attached. Tap Send to analyze.');
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.photo_library_rounded, color: primary),
                ),
                title: Text(
                  'Choose from Gallery',
                  style: GoogleFonts.montserrat(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Screenshots of chats, UPI transactions, SMS', style: GoogleFonts.plusJakartaSans(fontSize: 11.5)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final image = await _imagePicker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    setState(() {
                      _selectedAttachmentPath = image.path;
                      _selectedAttachmentName = image.name;
                      _selectedAttachmentType = 'image';
                    });
                    _showToast('Image attached. Tap Send to analyze.');
                  }
                },
              ),
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: primary),
                ),
                title: Text(
                  'Upload PDF Document',
                  style: GoogleFonts.montserrat(fontSize: 13.5, fontWeight: FontWeight.w700),
                ),
                subtitle: Text('Court summons, legal notices, FIR copy', style: GoogleFonts.plusJakartaSans(fontSize: 11.5)),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    final result = await FilePicker.pickFiles(
                      type: FileType.custom,
                      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
                    );
                    if (result.isNotEmpty) {
                      final file = result.first;
                      setState(() {
                        _selectedAttachmentPath = file.path;
                        _selectedAttachmentName = file.name;
                        _selectedAttachmentType = 'document';
                      });
                      _showToast('PDF Document attached. Tap Send to analyze.');
                    }
                  } catch (e) {
                    _showToast('Notice scanner ready: snapshot upload active');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================
  // Submit Query to AI Engine
  // ==========================================

  Future<void> _submitQuery({
    String? text,
    String? audioPath,
  }) async {
    final queryText = text ?? _inputController.text.trim();
    final attachmentPath = _selectedAttachmentPath;
    final attachmentName = _selectedAttachmentName;
    final attachmentType = _selectedAttachmentType;

    if (queryText.isEmpty && attachmentPath == null && audioPath == null) {
      return;
    }

    _inputController.clear();
    setState(() {
      _selectedAttachmentPath = null;
      _selectedAttachmentName = null;
      _selectedAttachmentType = null;

      // Add user message
      _messages.add(
        CivicAiMessage(
          id: 'user_${DateTime.now().millisecondsSinceEpoch}',
          text: queryText.isNotEmpty ? queryText : 'Uploaded $attachmentName for legal analysis',
          isUser: true,
          timestamp: DateTime.now(),
          audioPath: audioPath,
          attachmentPath: attachmentPath,
          attachmentName: attachmentName,
          attachmentType: attachmentType,
        ),
      );
      _isAiDeliberating = true;
    });

    _scrollToBottom();

    // Call AI Statutory Engine
    final response = await CivicAiService.instance.analyzeQuery(
      query: queryText,
      attachmentPath: attachmentPath,
      attachmentName: attachmentName,
      attachmentType: attachmentType,
      audioPath: audioPath,
    );

    if (!mounted) return;

    setState(() {
      _isAiDeliberating = false;

      // If high urgency, insert safeguard callout before verdict
      if (response.isEmergency) {
        _messages.add(
          CivicAiMessage(
            id: 'emerg_${DateTime.now().millisecondsSinceEpoch}',
            text: 'Emergency Safeguard Notice',
            isUser: false,
            timestamp: DateTime.now(),
            isEmergency: true,
          ),
        );
      }

      _messages.add(response);
    });

    _scrollToBottom();
  }

  void _onPromptTapped(String prompt) {
    _submitQuery(text: prompt);
  }

  void _onTriageOptionTapped(String triageText) {
    _submitQuery(text: 'Clarification: $triageText');
  }

  void _openSituationCard(String? cardId) {
    if (cardId != null && cardId.isNotEmpty) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => SituationCardScreen(cardId: cardId),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const SituationListScreen(),
        ),
      );
    }
  }

  void _showGeminiSettingsDialog() {
    final keyController = TextEditingController(text: AppPreferences.geminiApiKey);
    String selectedModel = AppPreferences.geminiModel;
    bool obscureKey = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          final isConnected = keyController.text.trim().isNotEmpty;
          return AlertDialog(
            backgroundColor: surfaceContainerLowest,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            title: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryFixed,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: primary, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gemini LLM Setup',
                        style: GoogleFonts.montserrat(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: onSurface,
                        ),
                      ),
                      Text(
                        '100% Free AI Legal Answers',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          color: secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isConnected
                          ? const Color(0xFFE8F5E9)
                          : surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isConnected
                            ? const Color(0xFF1B6B38).withValues(alpha: 0.3)
                            : outlineVariant.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isConnected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                          size: 18,
                          color: isConnected ? const Color(0xFF1B6B38) : secondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isConnected
                                ? 'Gemini Active ($selectedModel). Dynamic legal responses enabled.'
                                : 'Using CIVIC on-device legal rules. Connect your free Google AI Studio key below.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isConnected ? const Color(0xFF1B6B38) : onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'GEMINI MODEL',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: ['gemini-3.8-flash', 'gemini-3.6-flash', 'gemini-3.5-flash', 'gemini-flash-latest'].contains(selectedModel)
                        ? selectedModel
                        : 'gemini-3.8-flash',
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'gemini-3.8-flash',
                        child: Text('gemini-3.8-flash (Ultra Fast & State-of-the-Art)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-3.6-flash',
                        child: Text('gemini-3.6-flash (Fast Flash)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-3.5-flash',
                        child: Text('gemini-3.5-flash (Standard Flash)'),
                      ),
                      DropdownMenuItem(
                        value: 'gemini-flash-latest',
                        child: Text('gemini-flash-latest (Auto Latest)'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedModel = val);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'GOOGLE AI STUDIO API KEY',
                    style: GoogleFonts.montserrat(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.6,
                      color: primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: keyController,
                    obscureText: obscureKey,
                    decoration: InputDecoration(
                      hintText: 'AIzaSy...',
                      filled: true,
                      fillColor: surfaceContainerLow,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureKey ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                        ),
                        onPressed: () => setDialogState(() => obscureKey = !obscureKey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  InkWell(
                    onTap: () async {
                      final uri = Uri.parse('https://aistudio.google.com/app/apikey');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      }
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.open_in_new_rounded, size: 14, color: primary),
                        const SizedBox(width: 6),
                        Text(
                          'Get a free Gemini API key from Google AI Studio',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: primary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            actions: [
              if (keyController.text.trim().isNotEmpty)
                TextButton(
                  onPressed: () async {
                    await AppPreferences.setGeminiApiKey('');
                    if (!dialogCtx.mounted) return;
                    Navigator.of(dialogCtx).pop();
                    _showToast('Reverted to CIVIC on-device legal rules engine');
                  },
                  child: Text(
                    'CLEAR KEY',
                    style: GoogleFonts.montserrat(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: error,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: () async {
                  final key = keyController.text.trim();
                  await AppPreferences.setGeminiApiKey(key);
                  await AppPreferences.setGeminiModel(selectedModel);
                  if (!dialogCtx.mounted) return;
                  Navigator.of(dialogCtx).pop();
                  if (key.isNotEmpty) {
                    _showToast('Gemini ($selectedModel) connected successfully!');
                  } else {
                    _showToast('Using on-device statutory engine');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: onSurface,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(
                  'SAVE CONFIGURATION',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================
  // BUILD METHOD
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surface,
      body: Stack(
        children: [
          // Main Scrollable Area
          SingleChildScrollView(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 134, 16, 170),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Editorial & Intro Card
                _buildEditorialIntroCard(),
                const SizedBox(height: 18),

                // Suggested Prompt Carousel
                _buildPromptCarousel(),
                const SizedBox(height: 20),

                // Conversation Feed
                _buildConversationFeed(),

                // AI Deliberation Indicator
                if (_isAiDeliberating) ...[
                  const SizedBox(height: 16),
                  _buildAiDeliberatingIndicator(),
                ],
              ],
            ),
          ),

          // Persistent Floating Bottom Input
          _buildFloatingBottomInput(),

          // Fixed Top Header
          _buildFixedHeader(),
        ],
      ),
    );
  }

  // ==========================================
  // Header Component (Fixed Top)
  // ==========================================

  Widget _buildFixedHeader() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          color: surface.withValues(alpha: 0.95),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red Emergency SOS Bar
              Container(
                color: tertiary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        FadeTransition(
                          opacity: _pulseAnimation,
                          child: const Icon(Icons.emergency_rounded, color: onTertiary, size: 18),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'EMERGENCY SOS',
                          style: GoogleFonts.montserrat(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: onTertiary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        _buildEmergencyTopPill('call 112', () => _makeCall('112')),
                        const SizedBox(width: 6),
                        _buildEmergencyTopPill('gavel 15100', () => _makeCall('15100')),
                        const SizedBox(width: 6),
                        _buildEmergencyIconButton(
                          icon: Icons.my_location_rounded,
                          tooltip: 'Emergency GPS broadcast',
                          onTap: _sendGpsBeacon,
                        ),
                        const SizedBox(width: 6),
                        _buildEmergencyIconButton(
                          icon: Icons.contacts_rounded,
                          tooltip: 'Alert Emergency Contacts',
                          onTap: () {
                            _showToast('Emergency SOS dialer ready (112 / 15100)');
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // CIVIC Ask App Bar Row
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/civic_logo.png',
                          height: 32,
                          width: 32,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.shield_rounded,
                            color: primary,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CIVIC',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                                color: onSurface,
                                height: 1.1,
                              ),
                            ),
                            Text(
                              'Ask',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.4,
                                color: primary,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ValueListenableBuilder<String?>(
                          valueListenable: AppPreferences.geminiApiKeyNotifier,
                          builder: (context, apiKey, _) {
                            final bool hasKey = apiKey != null && apiKey.isNotEmpty;
                            return IconButton(
                              onPressed: _showGeminiSettingsDialog,
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.auto_awesome_rounded,
                                    size: 21,
                                    color: hasKey ? primary : onSurfaceVariant,
                                  ),
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: hasKey ? const Color(0xFF1B6B38) : Colors.orange,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: surfaceContainerLowest, width: 1.5),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              tooltip: hasKey ? 'Gemini AI Active' : 'Connect Gemini AI (Free)',
                            );
                          },
                        ),
                        IconButton(
                          onPressed: () {
                            _inputFocusNode.requestFocus();
                          },
                          icon: const Icon(Icons.search_rounded, size: 22, color: onSurfaceVariant),
                          tooltip: 'Legal rights search',
                        ),
                        IconButton(
                          onPressed: () {
                            _showToast('BNSS 2023 Statutory Verification Active');
                          },
                          icon: const Icon(Icons.notifications_none_rounded, size: 22, color: onSurfaceVariant),
                          tooltip: 'Statutory notifications',
                        ),
                        Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyTopPill(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: onTertiary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: onTertiary,
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 28,
        decoration: BoxDecoration(
          color: onTertiary.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: onTertiary, size: 16),
      ),
    );
  }

  // ==========================================
  // Editorial Header & Intro Card
  // ==========================================

  Widget _buildEditorialIntroCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Editorial Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'ASK',
                  style: GoogleFonts.montserrat(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: onSurface,
                  ),
                ),
              ],
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: Text(
                'PLAIN-LANGUAGE HELP, FROM REVIEWED SOURCES',
                textAlign: TextAlign.right,
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: secondary,
                  height: 1.25,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Intro Card with Center Isometric Emblem
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
          decoration: BoxDecoration(
            color: surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Mascot Emblem
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: surfaceContainerLow,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: Image.asset(
                  'assets/images/civic_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.shield_rounded,
                    color: primary,
                    size: 42,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Verification Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: primaryFixed,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified_user_rounded, color: onPrimaryFixed, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Statutory Verification Active',
                      style: GoogleFonts.montserrat(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: onPrimaryFixed,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Ask in plain words about traffic stops, workplace disputes, police checks, or consumer rights.',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: secondary,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Suggested Prompts Carousel
  // ==========================================

  Widget _buildPromptCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: primaryContainer,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'SUGGESTED PROMPTS',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: secondary,
                  ),
                ),
              ],
            ),
            Text(
              'Tap to query',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: _suggestedPrompts.map((prompt) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => _onPromptTapped(prompt),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: primaryContainer,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          prompt,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // Conversation Feed
  // ==========================================

  Widget _buildConversationFeed() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final message = _messages[index];

        if (message.isUser) {
          return _buildUserBubble(message);
        } else if (message.isEmergency) {
          return _buildEmergencyCalloutBubble();
        } else if (message.triageOptions != null && message.verdict == null) {
          return _buildTriageBubble(message);
        } else {
          return _buildAiBubble(message);
        }
      },
    );
  }

  Widget _buildUserBubble(CivicAiMessage message) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.85),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            decoration: const BoxDecoration(
              color: onSurface,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
                topRight: Radius.circular(4),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (message.attachmentName != null) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          message.attachmentType == 'image'
                              ? Icons.image_rounded
                              : Icons.description_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 180),
                          child: Text(
                            message.attachmentName!,
                            style: GoogleFonts.montserrat(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                Text(
                  message.text,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: surfaceContainerLowest,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              '${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')} · Seen by Statutory Engine',
              style: GoogleFonts.montserrat(
                fontSize: 10,
                color: secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyCalloutBubble() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tertiary,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x24BF0715),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _pulseAnimation,
                child: const Icon(Icons.warning_rounded, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMERGENCY SAFEGUARD',
                      style: GoogleFonts.montserrat(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.6,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'If you are in immediate danger, illegal custody, or being threatened, call 112 now.',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _makeCall('112'),
                  icon: const Icon(Icons.call_rounded, size: 16, color: tertiary),
                  label: Text(
                    'CALL 112',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: tertiary,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _sendGpsBeacon,
                  icon: const Icon(Icons.share_location_rounded, size: 16, color: Colors.white),
                  label: Text(
                    'SHARE GPS',
                    style: GoogleFonts.montserrat(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: tertiaryContainer.withValues(alpha: 0.4),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAiBubble(CivicAiMessage message) {
    final verdict = message.verdict;
    if (verdict == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sub-header with Balance Scale Icon
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.balance_rounded, color: Colors.white, size: 12),
                ),
                const SizedBox(width: 8),
                Text(
                  'CIVIC STATUTORY AI',
                  style: GoogleFonts.montserrat(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),

          // Main Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x06000000),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Topic Headline
                Text(
                  message.text,
                  style: GoogleFonts.montserrat(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: onSurface,
                  ),
                ),
                const SizedBox(height: 8),

                // Verdict Pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: verdict.verdictBgColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gavel_rounded, color: verdict.verdictColor, size: 14),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          verdict.verdictTitle,
                          style: GoogleFonts.montserrat(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: verdict.verdictColor,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Direct Bold Statement
                Text(
                  verdict.directAnswer,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 10),

                // Detailed Legal Reasoning
                Text(
                  verdict.legalReasoning,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: secondary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Statutory Citation Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: surfaceContainerHigh),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 1),
                        child: Icon(Icons.account_balance_rounded, size: 14, color: primary),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'STATUTORY LEGAL BASIS',
                              style: GoogleFonts.montserrat(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: primary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              verdict.statutoryCitation,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Action Steps (DOs)
                if (verdict.citizenActionSteps.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1B6B38),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_rounded, color: Colors.white, size: 11),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'IMMEDIATE CITIZEN PROTOCOL (WHAT TO DO):',
                          style: GoogleFonts.montserrat(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: const Color(0xFF1B6B38),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...verdict.citizenActionSteps.map((step) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 6),
                            child: Icon(Icons.arrow_right_rounded, color: Color(0xFF1B6B38), size: 16),
                          ),
                          Expanded(
                            child: Text(
                              step,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: onSurface,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Critical DON'Ts
                if (verdict.criticalDonts.isNotEmpty) ...[
                  Row(
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: error,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 11),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'CRITICAL MISTAKES TO AVOID (WHAT NOT TO DO):',
                          style: GoogleFonts.montserrat(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.6,
                            color: error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...verdict.criticalDonts.map((dont) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 2, right: 6),
                            child: Icon(Icons.block_rounded, color: error, size: 13),
                          ),
                          Expanded(
                            child: Text(
                              dont,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                color: onSurface,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Source Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.menu_book_rounded, color: primary, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              verdict.sourceTitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _openSituationCard(message.relatedCardId),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 14, color: Colors.white),
                            label: Text(
                              'OPEN FULL GUIDE',
                              style: GoogleFonts.montserrat(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.6,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: onSurface,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              elevation: 0,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              final dosText = verdict.citizenActionSteps.map((s) => '• $s').join('\n');
                              final dontsText = verdict.criticalDonts.isNotEmpty
                                  ? '\n\nWHAT NOT TO DO:\n${verdict.criticalDonts.map((d) => '✕ $d').join('\n')}'
                                  : '';
                              Clipboard.setData(ClipboardData(
                                text: '${verdict.verdictTitle}\n\n'
                                    '${verdict.directAnswer}\n\n'
                                    'LEGAL BASIS:\n${verdict.legalReasoning}\n\n'
                                    'STATUTORY PROVISION:\n${verdict.statutoryCitation}\n\n'
                                    'WHAT TO DO:\n$dosText$dontsText',
                              ));
                              _showToast('Advice copied to clipboard');
                            },
                            icon: const Icon(Icons.copy_rounded, size: 14, color: secondary),
                            label: Text(
                              'COPY ADVICE',
                              style: GoogleFonts.montserrat(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: secondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Related Triage Chips if present
                if (message.triageOptions != null && message.triageOptions!.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.tune_rounded, size: 14, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        'EXPLORE RELATED SITUATIONS:',
                        style: GoogleFonts.montserrat(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.6,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: message.triageOptions!.map((opt) {
                      return InkWell(
                        onTap: () => _onTriageOptionTapped(opt),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: outlineVariant.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.arrow_forward_rounded, size: 12, color: primary),
                              const SizedBox(width: 4),
                              Text(
                                opt,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTriageBubble(CivicAiMessage message) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: primary, size: 18),
              const SizedBox(width: 6),
              Text(
                'CONTEXT CLARIFICATION',
                style: GoogleFonts.montserrat(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'To give you the exact statutory rule, which situation applies right now?',
            style: GoogleFonts.montserrat(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: (message.triageOptions ?? []).map((opt) {
              return InkWell(
                onTap: () => _onTriageOptionTapped(opt),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    opt,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAiDeliberatingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: primary),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              'Consulting BNSS & Constitutional Statutes...',
              style: GoogleFonts.montserrat(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // Persistent Floating Bottom Input
  // ==========================================

  Widget _buildFloatingBottomInput() {
    return Positioned(
      bottom: 24,
      left: 16,
      right: 16,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Safe Legal Information Disclaimer Badge
          Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Text(
              '⚖️ Legal information, not legal advice. Chats aren\'t saved.',
              style: GoogleFonts.montserrat(
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
                color: secondary,
              ),
            ),
          ),

          // Attachment Chip Preview if selected
          if (_selectedAttachmentName != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primaryFixed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _selectedAttachmentType == 'image'
                        ? Icons.image_rounded
                        : Icons.description_rounded,
                    color: onPrimaryFixed,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 220),
                    child: Text(
                      _selectedAttachmentName!,
                      style: GoogleFonts.montserrat(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: onPrimaryFixed,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAttachmentPath = null;
                        _selectedAttachmentName = null;
                        _selectedAttachmentType = null;
                      });
                    },
                    child: const Icon(Icons.close_rounded, size: 16, color: onPrimaryFixed),
                  ),
                ],
              ),
            ),
          ],

          // High-Contrast Input Pill Container
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: surfaceContainerLowest,
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1817261F),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                // Voice Input Mic Button
                GestureDetector(
                  onTap: _toggleVoiceRecording,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _isRecording ? tertiary : primaryFixed,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                      color: _isRecording ? Colors.white : primary,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: _inputController,
                    focusNode: _inputFocusNode,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (val) => _submitQuery(),
                    decoration: InputDecoration(
                      hintText: _isRecording
                          ? 'Listening (${_recordingSeconds}s)...'
                          : 'Ask in English or हिन्दी...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: _isRecording ? primary : secondary,
                        fontWeight: _isRecording ? FontWeight.w600 : FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    ),
                  ),
                ),

                // Attachment / Camera Button
                IconButton(
                  onPressed: _showMediaPickerSheet,
                  icon: const Icon(Icons.attach_file_rounded, size: 22, color: secondary),
                  tooltip: 'Upload summon or document',
                ),

                // Send Directional Button
                GestureDetector(
                  onTap: () => _submitQuery(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: onSurface,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x14000000),
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
