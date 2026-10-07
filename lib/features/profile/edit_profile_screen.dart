import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/app_preferences.dart';

/// Complete, pixel-perfect Edit Profile Screen based on the Stitch Neo-Constructivist design.
/// Allows citizens to configure their local on-device identity, avatar caricature,
/// jurisdiction, language preferences, and emergency SOS contacts with zero telemetry.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _handleController;
  late final TextEditingController _districtController;
  late final TextEditingController _sosKinController;
  late final TextEditingController _sosCounselController;

  late String _selectedJurisdiction;
  late String _selectedAvatarVariant;
  late String _activeAvatarUrl;
  late List<String> _selectedLanguages;

  bool _isSaving = false;
  bool _savedSuccessfully = false;

  static const List<String> _jurisdictionOptions = [
    'Delhi NCR (BNS & CrPC 2024 active)',
    'Maharashtra (Bombay HC Jurisdiction)',
    'Karnataka (Bengaluru Urban & Rural)',
    'Tamil Nadu (Madras HC Zone)',
    'Uttar Pradesh (Allahabad HC Jurisdiction)',
    'West Bengal (Calcutta HC Jurisdiction)',
  ];

  static const List<Map<String, String>> _caricaturePresets = [
    {
      'id': 'orange',
      'title': 'Civic Youth',
      'accent': '#FF5A00',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDERKRSFZHHzh_rdRyeBkuQAjngOvev0MbbGQYR0HDPp5omKS1Z_g2_6wVPpzZldG0ZgjNi7thX-C6i4SnV-LaEJEocfTNB5rMNCdLTisxZVXs71nlD8VBwJmEvH9xHoLf-4CRum4xXM1rE41l7Zzu3ppeING_0CSBLQsbP7S2WGhrLvJs10PjfgR_lJ7htljvMAj9IfvWHcyft7eB-zxK8yi3clvEAMTW6NRcKE5IcOZuobg95Il-Ggg',
    },
    {
      'id': 'indigo',
      'title': 'Guardian Advocate',
      'accent': '#4F46E5',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBzXZc5Vn1tnShwXFiVNYXVJo2q4jf7o9GyGIIrkOUGYQ-6EUM6-9jOSmjL_555MDgf6Kmf9iXzxO8KzNAvPk_t81hdLF6Zp3TEf4Trs3yifkmppy-dVRakBDrpZcU72VFqn402qoOvBgqK1VZHL_reV7vIMj1g6DLiB-KvxYwO5nV4iMhMyUJGyl7oDoerwxxRBRC2t4bVTck3tmgkOTWDUTA81t8iLeO5rlZeGB__ZZt1H9P6FmB97g',
    },
    {
      'id': 'teal',
      'title': 'Rights Defender',
      'accent': '#0D9488',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDERKRSFZHHzh_rdRyeBkuQAjngOvev0MbbGQYR0HDPp5omKS1Z_g2_6wVPpzZldG0ZgjNi7thX-C6i4SnV-LaEJEocfTNB5rMNCdLTisxZVXs71nlD8VBwJmEvH9xHoLf-4CRum4xXM1rE41l7Zzu3ppeING_0CSBLQsbP7S2WGhrLvJs10PjfgR_lJ7htljvMAj9IfvWHcyft7eB-zxK8yi3clvEAMTW6NRcKE5IcOZuobg95Il-Ggg',
    },
    {
      'id': 'gold',
      'title': 'Constitutional Watch',
      'accent': '#D97706',
      'url':
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBzXZc5Vn1tnShwXFiVNYXVJo2q4jf7o9GyGIIrkOUGYQ-6EUM6-9jOSmjL_555MDgf6Kmf9iXzxO8KzNAvPk_t81hdLF6Zp3TEf4Trs3yifkmppy-dVRakBDrpZcU72VFqn402qoOvBgqK1VZHL_reV7vIMj1g6DLiB-KvxYwO5nV4iMhMyUJGyl7oDoerwxxRBRC2t4bVTck3tmgkOTWDUTA81t8iLeO5rlZeGB__ZZt1H9P6FmB97g',
    },
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: AppPreferences.profileFullName);
    _handleController = TextEditingController(text: AppPreferences.profileHandle);
    _districtController = TextEditingController(text: AppPreferences.profileDistrict);
    _sosKinController = TextEditingController(text: AppPreferences.profileSosKin);
    _sosCounselController = TextEditingController(text: AppPreferences.profileSosCounsel);

    _fullNameController.addListener(_onFullNameChanged);

    _selectedJurisdiction = _jurisdictionOptions.contains(AppPreferences.profileJurisdiction)
        ? AppPreferences.profileJurisdiction
        : _jurisdictionOptions.first;
    _selectedAvatarVariant = AppPreferences.profileAvatarVariant;
    _activeAvatarUrl = AppPreferences.profileAvatarUrl;
    _selectedLanguages = List<String>.from(AppPreferences.profileLanguages);
  }

  @override
  void dispose() {
    _fullNameController.removeListener(_onFullNameChanged);
    _fullNameController.dispose();
    _handleController.dispose();
    _districtController.dispose();
    _sosKinController.dispose();
    _sosCounselController.dispose();
    super.dispose();
  }

  String _generateHandleFromName(String name) {
    final clean = name
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .replaceAll(RegExp(r'\s+'), '_');
    if (clean.isEmpty) return 'citizen.civic';
    return '$clean.civic';
  }

  void _onFullNameChanged() {
    final newName = _fullNameController.text;
    final generated = _generateHandleFromName(newName);
    if (_handleController.text != generated) {
      _handleController.text = generated;
      setState(() {});
    }
  }

  Future<void> _pickProfilePhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 600,
        maxHeight: 600,
        imageQuality: 85,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        final base64String = 'data:image/jpeg;base64,${base64Encode(bytes)}';
        setState(() {
          _activeAvatarUrl = base64String;
          _selectedAvatarVariant = 'custom';
        });
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Personal profile picture selected. Tap SAVE PROFILE to commit.'),
              duration: Duration(seconds: 2),
              backgroundColor: Color(0xFF15803D),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to access camera or gallery: $e'),
            duration: const Duration(seconds: 2),
            backgroundColor: const Color(0xFFBA1A1A),
          ),
        );
      }
    }
  }

  Widget _buildAvatarImage(String url, {double size = 124}) {
    if (url.startsWith('data:image')) {
      try {
        final base64Data = url.contains(',') ? url.split(',').last : url;
        final bytes = base64Decode(base64Data);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _defaultAvatarIcon(size),
        );
      } catch (_) {
        return _defaultAvatarIcon(size);
      }
    } else if (url.startsWith('http')) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _defaultAvatarIcon(size),
      );
    } else {
      return _defaultAvatarIcon(size);
    }
  }

  Widget _defaultAvatarIcon(double size) {
    return Container(
      width: size,
      height: size,
      color: const Color(0xFFEEEEEE),
      child: Icon(
        Icons.face_rounded,
        size: size * 0.5,
        color: const Color(0xFFFF5A00),
      ),
    );
  }

  Future<void> _callHelpline(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    } catch (_) {}
  }

  void _toggleLanguage(String code) {
    setState(() {
      if (_selectedLanguages.contains(code)) {
        if (_selectedLanguages.length > 1) {
          _selectedLanguages.remove(code);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('At least one statutory language must remain active.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        _selectedLanguages.add(code);
      }
    });
  }

  void _selectAvatarVariant(String variantId) {
    final preset = _caricaturePresets.firstWhere(
      (p) => p['id'] == variantId,
      orElse: () => _caricaturePresets.first,
    );
    setState(() {
      _selectedAvatarVariant = variantId;
      _activeAvatarUrl = preset['url']!;
    });
  }

  void _showChangeCaricatureModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
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
                  Text(
                    'PROFILE PICTURE & AVATAR',
                    style: GoogleFonts.montserrat(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF101F18),
                      letterSpacing: 0.6,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD5E7DC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'LOCAL SECURE',
                      style: GoogleFonts.montserrat(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF101F18),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // SECTION A: UPLOAD PERSONAL PROFILE PICTURE
              Text(
                'PERSONAL PHOTO (DEVICE)',
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B4137),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickProfilePhoto(ImageSource.camera),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF5A00).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFFF5A00)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_camera_rounded,
                                color: Color(0xFFFF5A00), size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Take Photo',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFFF5A00),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickProfilePhoto(ImageSource.gallery),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F3F3),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE2E2E2)),
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_rounded,
                                color: Color(0xFF526259), size: 24),
                            const SizedBox(height: 4),
                            Text(
                              'Choose Gallery',
                              style: GoogleFonts.montserrat(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1A1C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // SECTION B: CIVIC CARICATURE PRESETS
              Text(
                'OR CHOOSE CIVIC PRESET',
                style: GoogleFonts.montserrat(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF5B4137),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _caricaturePresets.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 2.2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  final item = _caricaturePresets[index];
                  final isSelected = _selectedAvatarVariant == item['id'];
                  return InkWell(
                    onTap: () {
                      _selectAvatarVariant(item['id']!);
                      Navigator.pop(context);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFFFF5A00).withValues(alpha: 0.08)
                            : const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFFF5A00)
                              : const Color(0xFFE2E2E2),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? const Color(0xFFFF5A00)
                                  : const Color(0xFFEEEEEE),
                            ),
                            child: Icon(
                              index == 0
                                  ? Icons.face_rounded
                                  : index == 1
                                      ? Icons.verified_user_rounded
                                      : index == 2
                                          ? Icons.balance_rounded
                                          : Icons.account_circle_rounded,
                              size: 20,
                              color: isSelected ? Colors.white : const Color(0xFF526259),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title']!,
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF101F18),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  isSelected ? 'Active Avatar' : 'Line-art Style',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 9.5,
                                    color: const Color(0xFF526259),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final name = _fullNameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your legal full name.'),
          backgroundColor: Color(0xFFBA1A1A),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await AppPreferences.setProfileFullName(name);
    await AppPreferences.setProfileHandle(_handleController.text.trim());
    await AppPreferences.setProfileJurisdiction(_selectedJurisdiction);
    await AppPreferences.setProfileDistrict(_districtController.text.trim());
    await AppPreferences.setProfileAvatarVariant(_selectedAvatarVariant);
    await AppPreferences.setProfileAvatarUrl(_activeAvatarUrl);
    await AppPreferences.setProfileLanguages(_selectedLanguages);
    await AppPreferences.setProfileSosKin(_sosKinController.text.trim());
    await AppPreferences.setProfileSosCounsel(_sosCounselController.text.trim());

    // Update global app language if changed
    if (_selectedLanguages.isNotEmpty) {
      await AppPreferences.setSelectedLanguage(_selectedLanguages.first);
    }

    // Sync selected state code if possible
    if (_selectedJurisdiction.contains('Delhi')) {
      await AppPreferences.setSelectedState('DL');
    } else if (_selectedJurisdiction.contains('Maharashtra')) {
      await AppPreferences.setSelectedState('MH');
    } else if (_selectedJurisdiction.contains('Karnataka')) {
      await AppPreferences.setSelectedState('KA');
    } else if (_selectedJurisdiction.contains('Tamil Nadu')) {
      await AppPreferences.setSelectedState('TN');
    }

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _savedSuccessfully = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Profile changes stored in local encrypted database.',
              style: GoogleFonts.plusJakartaSans(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF15803D),
        duration: const Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryOrange = Color(0xFFA83900);
    const primaryContainer = Color(0xFFFF5A00);
    const onSurface = Color(0xFF1A1C1C);
    const onSurfaceVariant = Color(0xFF5B4137);
    const surfaceContainerLow = Color(0xFFF3F3F3);
    const surfaceContainerLowest = Color(0xFFFFFFFF);
    const surfaceContainerHigh = Color(0xFFE8E8E8);
    const secondaryColor = Color(0xFF526259);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9).withValues(alpha: 0.95),
                border: const Border(
                  bottom: BorderSide(color: Color(0xFFE2E2E2), width: 1),
                ),
              ),
              child: Column(
                children: [
                  // Emergency Quick Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: primaryContainer,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.near_me_rounded,
                              size: 14, color: primaryOrange),
                          const SizedBox(width: 4),
                          Text(
                            'GPS LIVE DISPATCH',
                            style: GoogleFonts.montserrat(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceVariant,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          InkWell(
                            onTap: () => _callHelpline('112'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFBF0715),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.emergency_rounded,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    '112 POLICE',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            onTap: () => _callHelpline('15100'),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: secondaryColor,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.gavel_rounded,
                                      size: 12, color: Colors.white),
                                  const SizedBox(width: 3),
                                  Text(
                                    '15100 NALSA',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Nav Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: onSurface, size: 22),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'EDIT PROFILE',
                            style: GoogleFonts.montserrat(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: onSurface,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.help_outline_rounded,
                                color: onSurfaceVariant, size: 20),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'CIVIC Profile: All data is stored locally in device SQLite with AES-256.'),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: primaryOrange,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_rounded,
                                size: 17, color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Scrollable Profile Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Top Ambient Decorative Avatar Container
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Soft blurred ambient glow
                        Positioned(
                          top: 0,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: primaryContainer.withValues(alpha: 0.12),
                            ),
                          ),
                        ),

                        // Avatar Circle (Tap to Change)
                        GestureDetector(
                          onTap: _showChangeCaricatureModal,
                          child: Container(
                            width: 124,
                            height: 124,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: surfaceContainerLowest,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child: _buildAvatarImage(_activeAvatarUrl, size: 120),
                            ),
                          ),
                        ),

                        // Edit Pencil floating badge
                        Positioned(
                          bottom: 2,
                          right: MediaQuery.of(context).size.width / 2 - 64,
                          child: InkWell(
                            onTap: _showChangeCaricatureModal,
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: primaryContainer,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryContainer.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  color: Colors.white, size: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Change Photo / Caricature Button
                    OutlinedButton.icon(
                      onPressed: _showChangeCaricatureModal,
                      style: OutlinedButton.styleFrom(
                        backgroundColor: surfaceContainerHigh,
                        foregroundColor: onSurface,
                        side: const BorderSide(color: Color(0xFFE2E2E2)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      icon: const Icon(Icons.add_a_photo_rounded,
                          size: 16, color: primaryOrange),
                      label: Text(
                        'CHANGE CARICATURE',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Take a photo, choose from gallery, or select a civic caricature',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),

                    // Avatar Variant Selector Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildVariantButton(
                          variantId: 'orange',
                          icon: Icons.face_rounded,
                          color: const Color(0xFFFF5A00),
                        ),
                        const SizedBox(width: 10),
                        _buildVariantButton(
                          variantId: 'indigo',
                          icon: Icons.verified_user_rounded,
                          color: const Color(0xFF4F46E5),
                        ),
                        const SizedBox(width: 10),
                        _buildVariantButton(
                          variantId: 'teal',
                          icon: Icons.balance_rounded,
                          color: const Color(0xFF0D9488),
                        ),
                        const SizedBox(width: 10),
                        _buildVariantButton(
                          variantId: 'gold',
                          icon: Icons.account_circle_rounded,
                          color: const Color(0xFFD97706),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // SECTION 1: CITIZEN IDENTITY
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: primaryContainer,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'CITIZEN IDENTITY',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: onSurface,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD5E7DC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'STATUTORY ID',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF101F18),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Citizen Identity Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Full Legal Name
                          Text(
                            'LEGAL FULL NAME',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _fullNameController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: surfaceContainerLow,
                              hintText: 'Enter your legal full name',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                color: onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(Icons.badge_outlined,
                                  size: 19, color: onSurfaceVariant),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // CIVIC ID Handle
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CIVIC ID HANDLE',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.verified_user_rounded,
                                      size: 12, color: secondaryColor),
                                  const SizedBox(width: 3),
                                  Text(
                                    'VERIFIED ON-DEVICE',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                      color: secondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _handleController,
                            style: GoogleFonts.montserrat(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: surfaceContainerLow,
                              prefixIcon: const Icon(Icons.alternate_email_rounded,
                                  size: 19, color: primaryOrange),
                              suffixIcon: Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Chip(
                                  avatar: const Icon(Icons.sync_rounded,
                                      size: 13, color: Color(0xFF15803D)),
                                  label: Text(
                                    'AUTO-SYNCED',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF15803D),
                                    ),
                                  ),
                                  backgroundColor: const Color(0xFFD5E7DC),
                                  visualDensity: VisualDensity.compact,
                                  padding: EdgeInsets.zero,
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Civic ID handle auto-updates as you change your full name.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Primary Legal Jurisdiction Dropdown
                          Text(
                            'PRIMARY LEGAL JURISDICTION',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedJurisdiction,
                                isExpanded: true,
                                icon: const Icon(Icons.expand_more_rounded,
                                    color: onSurfaceVariant),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                ),
                                items: _jurisdictionOptions.map((opt) {
                                  return DropdownMenuItem<String>(
                                    value: opt,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.gavel_rounded,
                                            size: 16, color: onSurfaceVariant),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            opt,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _selectedJurisdiction = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Residential District & Pincode
                          Text(
                            'RESIDENTIAL DISTRICT & PINCODE',
                            style: GoogleFonts.montserrat(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: onSurfaceVariant,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _districtController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: surfaceContainerLow,
                              prefixIcon: const Icon(Icons.location_on_outlined,
                                  size: 19, color: onSurfaceVariant),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Preferred Statutory Language
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  'PREFERRED STATUTORY LANGUAGE',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: onSurfaceVariant,
                                    letterSpacing: 0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _selectedLanguages.length > 1
                                    ? 'Bilingual Active'
                                    : 'Single Active',
                                style: GoogleFonts.montserrat(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildLangPill('en', 'English'),
                              _buildLangPill('hi', 'हिंदी (Hindi)'),
                              _buildLangPill('mr', 'मराठी'),
                              _buildLangPill('bn', 'বাংলা'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // SECTION 2: EMERGENCY & LEGAL SAFEGUARDS
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Color(0xFFBF0715),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'EMERGENCY SAFEGUARDS',
                              style: GoogleFonts.montserrat(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: onSurface,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFDAD6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'SOS PROTOCOLS',
                            style: GoogleFonts.montserrat(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF410002),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Safeguard Inputs Stack
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x08000000),
                            blurRadius: 10,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Primary SOS Kin
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PRIMARY SOS CONTACT (KIN)',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'ACTIVE RELAY',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: secondaryColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _sosKinController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: surfaceContainerLow,
                              hintText: '+91 98765 43210 (Kin Name / Relationship)',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(
                                  Icons.contact_emergency_rounded,
                                  size: 19,
                                  color: Color(0xFFBF0715)),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Legal Counsel SOS
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'LEGAL COUNSEL / RETAINER SOS',
                                style: GoogleFonts.montserrat(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: onSurfaceVariant,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                'SEC. 41D CRPC',
                                style: GoogleFonts.montserrat(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  color: primaryOrange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _sosCounselController,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: surfaceContainerLow,
                              hintText: '+91 91234 56789 (Advocate Name)',
                              hintStyle: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                color: onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              prefixIcon: const Icon(Icons.support_agent_rounded,
                                  size: 19, color: primaryOrange),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // DigiLocker Offline Cache Banner
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD5E7DC).withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFD5E7DC)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: secondaryColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.lock_outline_rounded,
                                      size: 18, color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DIGILOCKER OFFLINE CACHE',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: onSurface,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      Text(
                                        'Driving License & Masked Aadhaar',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: secondaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.verified_rounded,
                                    size: 20, color: secondaryColor),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Zero-Knowledge Vault Card
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: surfaceContainerLow,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFE2E2E2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.key_rounded,
                                      size: 18, color: onSurfaceVariant),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'ENCLAVE KEY',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w800,
                                          color: onSurface,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                      Text(
                                        'Hardware Keystore #8841-CIVIC',
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 11,
                                          color: onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE2E2E2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'HARDWARE SEC',
                                    style: GoogleFonts.montserrat(
                                      fontSize: 8,
                                      fontWeight: FontWeight.w800,
                                      color: onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BOTTOM ACTION SECTION
                    // Save Profile CTA
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _savedSuccessfully
                              ? const Color(0xFF15803D)
                              : const Color(0xFF2F3131),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 2,
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _savedSuccessfully
                                    ? Icons.check_circle_rounded
                                    : Icons.save_rounded,
                                size: 20,
                              ),
                        label: Text(
                          _savedSuccessfully
                              ? 'PROFILE STORED LOCALLY'
                              : 'SAVE PROFILE CHANGES',
                          style: GoogleFonts.montserrat(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Discard Changes Button
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          foregroundColor: onSurfaceVariant,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        child: Text(
                          'DISCARD CHANGES',
                          style: GoogleFonts.montserrat(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Zero Telemetry Disclaimer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shield_rounded,
                            size: 14, color: secondaryColor),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            'All changes are saved to local SQLite database only. Zero telemetry or server syncing.',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 10.5,
                              color: onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantButton({
    required String variantId,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedAvatarVariant == variantId;
    return InkWell(
      onTap: () => _selectAvatarVariant(variantId),
      borderRadius: BorderRadius.circular(24),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFF5A00) : const Color(0xFFE2E2E2),
              shape: BoxShape.circle,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFEEEEEE),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
          ),
          if (isSelected)
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFA83900),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded,
                    size: 11, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLangPill(String code, String label) {
    final isActive = _selectedLanguages.contains(code);
    return InkWell(
      onTap: () => _toggleLanguage(code),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? (code == 'en' ? const Color(0xFF2F3131) : const Color(0xFFFF5A00))
              : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isActive) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? Colors.white : const Color(0xFF1A1C1C),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
