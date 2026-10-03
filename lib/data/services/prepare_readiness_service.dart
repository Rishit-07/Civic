import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Data model representing a core readiness lesson
class PrepareLesson {
  final String id;
  final String title;
  final String category; // 'Police', 'Campus', 'Couples', 'Online Fraud', 'Work', 'Housing'
  final String duration;
  final String priorityTag;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;
  final String? scenarioId;
  final String summary;
  final List<String> keyCheckpoints;
  final String legalCitation;

  const PrepareLesson({
    required this.id,
    required this.title,
    required this.category,
    required this.duration,
    required this.priorityTag,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
    this.scenarioId,
    required this.summary,
    required this.keyCheckpoints,
    required this.legalCitation,
  });
}

/// Data model for an option in a legal drill quiz
class DrillOption {
  final String id;
  final String text;
  final bool isCorrect;
  final String feedback;

  const DrillOption({
    required this.id,
    required this.text,
    required this.isCorrect,
    required this.feedback,
  });
}

/// Data model for a daily practice scenario legal drill
class LegalDrill {
  final String id;
  final String question;
  final String subtitle;
  final List<DrillOption> options;
  final String statutoryCitation;
  final int xpReward;

  const LegalDrill({
    required this.id,
    required this.question,
    required this.subtitle,
    required this.options,
    required this.statutoryCitation,
    this.xpReward = 20,
  });
}

/// Persistent service managing citizen preparedness lessons, daily legal drills,
/// readiness score calculation, and synchronization with local cache & Cloud Firestore.
class PrepareReadinessService {
  static const String _keyCompletedLessons = 'prepare_completed_lessons';
  static const String _keyUserXp = 'prepare_user_xp';
  static const String _keyFeaturedCompleted = 'prepare_featured_18_completed';

  static SharedPreferences? _prefs;

  // Reactive notifiers for instant UI updates
  static final ValueNotifier<Set<String>> completedLessonsNotifier =
      ValueNotifier<Set<String>>({'lesson_police_stop'}); // Default initial completed
  static final ValueNotifier<Map<String, String>> completedDrillsNotifier =
      ValueNotifier<Map<String, String>>({});
  static final ValueNotifier<int> xpNotifier = ValueNotifier<int>(60);
  static final ValueNotifier<bool> featuredCompletedNotifier = ValueNotifier<bool>(false);

  /// All standardized Core Readiness Lessons for CIVIC
  static const List<PrepareLesson> allLessons = [
    PrepareLesson(
      id: 'lesson_police_stop',
      title: "If you're stopped by police",
      category: 'Police',
      duration: '90 sec',
      priorityTag: 'High Priority',
      icon: Icons.shield_rounded,
      iconBgColor: Color(0xFFD5E7DC),
      iconColor: Color(0xFF101F18),
      scenarioId: 'traffic_stop_default',
      summary:
          'Routine vehicle check protocols, production of digital credentials on DigiLocker, and prevention of arbitrary roadside seizure.',
      keyCheckpoints: [
        'Present digital DL & RC via DigiLocker / mParivahan (Rule 139 CMVR valid).',
        'Only Sub-Inspector or higher rank can demand compounding spot fines.',
        'Police cannot confiscate vehicle keys or arbitrarily impound without Sec 207 memo.',
      ],
      legalCitation:
          'Motor Vehicles Act 2019 Sec 130, 200, 207; Rule 139 CMVR; Supreme Court D.K. Basu guidelines.',
    ),
    PrepareLesson(
      id: 'lesson_arrest_rights',
      title: 'Your rights if arrested',
      category: 'Police',
      duration: '90 sec',
      priorityTag: 'Statutory DK Basu Rules',
      icon: Icons.balance_rounded,
      iconBgColor: Color(0xFFE8E8E8),
      iconColor: Color(0xFFFF5A00),
      scenarioId: 'summons_notice_default',
      summary:
          'Constitutional and statutory rights on detention, formal arrest memo requirement, and mandatory intimation of kin.',
      keyCheckpoints: [
        'Demand written Section 41A CrPC notice before attending police questioning.',
        'Mandatory arrest memo signed by at least one family member or respectable local witness.',
        'Right to notify family within 1 hour and receive free legal aid (15100).',
        'Independent medical examination mandatory every 48 hours under Sec 54 CrPC.',
      ],
      legalCitation:
          'CrPC Sec 41A, 50, 50A, 54, 57; BNSS Sec 35, 47, 48, 53; Constitution Art 22(1); D.K. Basu (1997).',
    ),
    PrepareLesson(
      id: 'lesson_hotel_checkin',
      title: 'Hotel check-in basics',
      category: 'Couples',
      duration: '90 sec',
      priorityTag: 'Article 21 Privacy',
      icon: Icons.meeting_room_rounded,
      iconBgColor: Color(0xFFEEEEEE),
      iconColor: Color(0xFF101F18),
      scenarioId: 'police_detain_couple_default',
      summary:
          'Constitutional privacy and freedom of association rights for consenting adults in public and private hospitality establishments.',
      keyCheckpoints: [
        'Two consenting adults (18+) holding valid government photo ID have absolute right to book rooms.',
        'Hotels and police have zero legal authority to moral-police or contact parents.',
        'No woman can be summoned to a police station (Sec 160(1) CrPC / Sec 179(1) BNSS).',
      ],
      legalCitation:
          'Constitution of India Art 19 & 21; Supreme Court in Shafin Jahan (2018) & Navtej Singh Johar (2018).',
    ),
    PrepareLesson(
      id: 'lesson_ragging_report',
      title: 'What is ragging and how to report it',
      category: 'Campus',
      duration: '90 sec',
      priorityTag: 'UGC Anti-Ragging Mandate',
      icon: Icons.school_rounded,
      iconBgColor: Color(0xFFEEEEEE),
      iconColor: Color(0xFF101F18),
      scenarioId: 'ragging_victim_default',
      summary:
          'Strict statutory anti-ragging laws in Indian educational institutions, mandatory FIR filing, and institutional accountability.',
      keyCheckpoints: [
        'College Head of Institution is legally mandated under Regulation 7 to lodge an FIR with police within 24 hours.',
        'National Anti-Ragging 24/7 Helpline: 1800-180-5522.',
        'Failure of college management to report attracts personal criminal prosecution under Sec 176 IPC.',
      ],
      legalCitation:
          'UGC Regulations on Curbing the Menace of Ragging 2009; Supreme Court in Vishwa Jagriti Mission (2001).',
    ),
    PrepareLesson(
      id: 'lesson_spot_upi_scam',
      title: 'Spot a UPI scam',
      category: 'Online Fraud',
      duration: '90 sec',
      priorityTag: 'Golden Hour Protocol 1930',
      icon: Icons.phonelink_lock_rounded,
      iconBgColor: Color(0xFFEEEEEE),
      iconColor: Color(0xFF101F18),
      scenarioId: 'upi_fraud_default',
      summary:
          'Immediate countermeasures for fraudulent UPI transfers, cyber cell reporting, and zero bank liability rules.',
      keyCheckpoints: [
        'Never enter your UPI PIN to receive money or cashbacks from anyone.',
        'Dial Helpline 1930 within the Golden Hour to freeze money in recipient mule accounts.',
        'RBI circular mandates zero customer liability when unauthorized breach is reported within 3 days.',
      ],
      legalCitation:
          'Information Technology Act Sec 66C, 66D; RBI Circular DBR.No.Leg.BC.78/09.07.005/2017-18.',
    ),
    PrepareLesson(
      id: 'lesson_workplace_salary',
      title: 'Workplace & unpaid wages defense',
      category: 'Work',
      duration: '90 sec',
      priorityTag: 'Payment of Wages & POSH',
      icon: Icons.work_outline_rounded,
      iconBgColor: Color(0xFFEEEEEE),
      iconColor: Color(0xFF101F18),
      scenarioId: 'workplace_harassment_default',
      summary:
          'Statutory protections against wage withholding, wrongful termination, and workplace harassment redressal.',
      keyCheckpoints: [
        'Full & Final settlement must be cleared within 2 working days of resignation/termination (Sec 17 Code on Wages).',
        'Internal Committee (IC) under POSH Act has Civil Court powers to order interim transfer and paid leave.',
        'Employers cannot withhold experience certificates or statutory dues (EPF, Gratuity) against bonds.',
      ],
      legalCitation:
          'Code on Wages 2019 Sec 17; POSH Act 2013; Industrial Disputes Act Sec 25F.',
    ),
    PrepareLesson(
      id: 'lesson_tenant_eviction',
      title: 'Tenant protection against eviction',
      category: 'Housing',
      duration: '90 sec',
      priorityTag: 'Model Tenancy Act 2021',
      icon: Icons.home_work_rounded,
      iconBgColor: Color(0xFFEEEEEE),
      iconColor: Color(0xFF101F18),
      scenarioId: 'refund_denied_default',
      summary:
          'Rights against arbitrary lockouts, utility cutoffs, and wrongful security deposit deductions.',
      keyCheckpoints: [
        'Landlords cannot disconnect electricity or water under any circumstances (Sec 430 IPC / Sec 324 BNS).',
        'Eviction requires formal order from Rent Authority or Civil Court; private lockout is criminal trespass.',
        'Security deposit deductions require written receipts and itemized invoices for documented damage.',
      ],
      legalCitation:
          'Model Tenancy Act 2021 Sec 13, 20; Transfer of Property Act Sec 106; IPC Sec 430, 448.',
    ),
  ];

  /// Standardized Daily Legal Drills pool
  static const List<LegalDrill> dailyDrills = [
    LegalDrill(
      id: 'drill_traffic_stop',
      question:
          'An officer asks you to step out of your car without giving a reason. What do you do?',
      subtitle:
          'Tap the legally sound course of action under the Motor Vehicles Act & CrPC guidelines.',
      statutoryCitation:
          'Motor Vehicles Act 1988 Sec 130, 200; Police Standing Orders & CrPC Sec 100.',
      xpReward: 20,
      options: [
        DrillOption(
          id: 'a',
          text: 'Refuse to speak and speed away immediately.',
          isCorrect: false,
          feedback:
              'Speeding away is a serious criminal offense under Section 132/179 MV Act and obstructs lawful public enforcement.',
        ),
        DrillOption(
          id: 'b',
          text:
              "Calmly ask for the officer's name, station, and statutory reason while remaining composed.",
          isCorrect: true,
          feedback:
              'Under Section 130 of the MV Act and Police Standing Orders, officers must identify themselves and state cause. You are entitled to remain in vehicle unless lawful search grounds exist.',
        ),
        DrillOption(
          id: 'c',
          text: 'Offer cash on the spot to avoid delay.',
          isCorrect: false,
          feedback:
              'Offering unreceipted cash constitutes an offense under Section 8 of the Prevention of Corruption Act.',
        ),
      ],
    ),
    LegalDrill(
      id: 'drill_fake_cbi_call',
      question:
          'A caller claims to be a cyber officer threatening a "digital arrest" over WhatsApp video. What is your response?',
      subtitle:
          'Choose the proper protocol against online extortion and fake law enforcement calls.',
      statutoryCitation:
          'IT Act Sec 66D, 66E; IPC Sec 419, 384; MHA Cyber Crime Cell SOPs.',
      xpReward: 20,
      options: [
        DrillOption(
          id: 'a',
          text: 'Transfer funds immediately to the escrow account they mention.',
          isCorrect: false,
          feedback:
              'Never transfer funds. Indian law enforcement agencies do not operate escrow accounts or demand money for clearing charges.',
        ),
        DrillOption(
          id: 'b',
          text:
              'Disconnect immediately, block the number, and report to Helpline 1930 / cybercrime.gov.in.',
          isCorrect: true,
          feedback:
              'Correct procedure! The Supreme Court and MHA have confirmed that "Digital Arrest" does not exist in Indian law. Police never conduct video interrogations over WhatsApp or Skype.',
        ),
        DrillOption(
          id: 'c',
          text: 'Agree to a video interrogation while showing your government IDs.',
          isCorrect: false,
          feedback:
              'Complying allows cyber fraudsters to capture screenshots and recordings for deeper blackmail.',
        ),
      ],
    ),
    LegalDrill(
      id: 'drill_forced_resignation',
      question:
          'An employer summons you and insists you sign a resignation letter before leaving the room. What should you do?',
      subtitle:
          'Identify your statutory protection against coerced resignation and forfeiture of dues.',
      statutoryCitation:
          'Industrial Disputes Act Sec 25F; Contract Act Sec 23, 27; Code on Wages Sec 17.',
      xpReward: 20,
      options: [
        DrillOption(
          id: 'a',
          text: 'Sign immediately to avoid a negative performance review.',
          isCorrect: false,
          feedback:
              'Signing voluntary resignation forfeits your statutory retrenchment compensation, severance dues, and wrongful dismissal claims.',
        ),
        DrillOption(
          id: 'b',
          text:
              'Decline to sign under coercion and request any formal termination notice in writing with statutory grounds.',
          isCorrect: true,
          feedback:
              'Correct! Under the Industrial Disputes Act and Contract Act, forced resignations obtained under duress are legally void. Termination requires formal written notice and statutory severance.',
        ),
        DrillOption(
          id: 'c',
          text: 'Surrender your personal laptop and company badges without any receipt.',
          isCorrect: false,
          feedback:
              'Never hand over company assets without a countersigned physical clearance checklist.',
        ),
      ],
    ),
  ];

  /// Initialize persistent state from SharedPreferences and Firebase
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();

    final storedLessons = _prefs?.getStringList(_keyCompletedLessons) ?? ['lesson_police_stop'];
    completedLessonsNotifier.value = storedLessons.toSet();

    final storedXp = _prefs?.getInt(_keyUserXp) ?? 60;
    xpNotifier.value = storedXp;

    final isFeatured = _prefs?.getBool(_keyFeaturedCompleted) ?? false;
    featuredCompletedNotifier.value = isFeatured;

    // Load completed drills map
    final storedDrillsKeys = _prefs?.getKeys().where((k) => k.startsWith('drill_answer_')).toList() ?? [];
    final Map<String, String> drillMap = {};
    for (final k in storedDrillsKeys) {
      final drillId = k.replaceFirst('drill_answer_', '');
      final ans = _prefs?.getString(k);
      if (ans != null) {
        drillMap[drillId] = ans;
      }
    }
    completedDrillsNotifier.value = drillMap;
  }

  /// Whether a lesson is completed
  static bool isLessonCompleted(String lessonId) {
    return completedLessonsNotifier.value.contains(lessonId);
  }

  /// Mark a lesson as completed, award XP, and persist
  static Future<void> markLessonCompleted(String lessonId) async {
    final updated = Set<String>.from(completedLessonsNotifier.value)..add(lessonId);
    completedLessonsNotifier.value = updated;
    await _prefs?.setStringList(_keyCompletedLessons, updated.toList());

    // Add XP
    final newXp = xpNotifier.value + 15;
    xpNotifier.value = newXp;
    await _prefs?.setInt(_keyUserXp, newXp);

    _syncToFirestore();
  }

  /// Mark the featured "Just Turned 18" transition guide as completed
  static Future<void> markFeaturedCompleted() async {
    featuredCompletedNotifier.value = true;
    await _prefs?.setBool(_keyFeaturedCompleted, true);

    final newXp = xpNotifier.value + 50;
    xpNotifier.value = newXp;
    await _prefs?.setInt(_keyUserXp, newXp);

    _syncToFirestore();
  }

  /// Record an answer for a legal practice drill
  static Future<void> recordDrillAnswer(String drillId, String chosenOptionId, bool isCorrect) async {
    final updated = Map<String, String>.from(completedDrillsNotifier.value);
    updated[drillId] = chosenOptionId;
    completedDrillsNotifier.value = updated;
    await _prefs?.setString('drill_answer_$drillId', chosenOptionId);

    if (isCorrect) {
      final newXp = xpNotifier.value + 20;
      xpNotifier.value = newXp;
      await _prefs?.setInt(_keyUserXp, newXp);
    }

    _syncToFirestore();
  }

  /// Calculate dynamic readiness percentage based on completed modules & drills
  static double getReadinessPercentage() {
    final completedLessons = completedLessonsNotifier.value.length;
    final totalModules = allLessons.length + 1; // Lessons + Featured Transition
    final featuredBonus = featuredCompletedNotifier.value ? 1 : 0;
    final totalCompleted = completedLessons + featuredBonus;

    final pct = (totalCompleted / totalModules).clamp(0.0, 1.0);
    return pct;
  }

  /// Formatted readiness summary text (e.g. "3 of 8 modules done (38%)")
  static String getReadinessSummary() {
    final completedLessons = completedLessonsNotifier.value.length;
    final totalModules = allLessons.length + 1;
    final featuredBonus = featuredCompletedNotifier.value ? 1 : 0;
    final totalCompleted = completedLessons + featuredBonus;
    final pct = ((totalCompleted / totalModules) * 100).round();

    return '$totalCompleted of $totalModules modules done ($pct%)';
  }

  /// Background sync with Firebase Firestore if user is authenticated
  static Future<void> _syncToFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('readiness').doc('progress');
      await doc.set({
        'completedLessons': completedLessonsNotifier.value.toList(),
        'completedDrills': completedDrillsNotifier.value,
        'featuredCompleted': featuredCompletedNotifier.value,
        'xp': xpNotifier.value,
        'readinessPercentage': getReadinessPercentage(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('Firestore readiness sync: $e');
    }
  }
}
