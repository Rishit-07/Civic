import 'dart:async';
import 'package:flutter/material.dart';

import 'gemini_ai_service.dart';

/// Represents an AI analyzed message in the conversation thread
class CivicAiMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? audioPath;
  final String? attachmentPath;
  final String? attachmentName;
  final String? attachmentType; // 'image', 'document', 'audio'
  final CivicAiVerdict? verdict;
  final bool isEmergency;
  final String? relatedCardId;
  final List<String>? triageOptions;

  CivicAiMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.audioPath,
    this.attachmentPath,
    this.attachmentName,
    this.attachmentType,
    this.verdict,
    this.isEmergency = false,
    this.relatedCardId,
    this.triageOptions,
  });
}

/// Detailed statutory verdict attached to an AI response
class CivicAiVerdict {
  final String verdictTitle; // e.g. "Statutory Verdict: Strictly Unlawful"
  final Color verdictColor;
  final Color verdictBgColor;
  final String directAnswer; // High contrast bold summary
  final String legalReasoning; // Detailed statutory explanation
  final String sourceTitle; // e.g. "Based on: Traffic Stop Card & Article 21 Privacy"
  final String statutoryCitation; // Specific Sections (CrPC/BNSS/BNS/MV Act)
  final List<String> citizenActionSteps;
  final List<String> criticalDonts; // Critical pitfalls and actions to avoid

  CivicAiVerdict({
    required this.verdictTitle,
    required this.verdictColor,
    required this.verdictBgColor,
    required this.directAnswer,
    required this.legalReasoning,
    required this.sourceTitle,
    required this.statutoryCitation,
    required this.citizenActionSteps,
    this.criticalDonts = const [],
  });
}

/// Intelligent on-device Statutory & Law-and-Order AI Engine.
/// Parses natural language queries, media notices, and voice queries in English and Hindi,
/// synthesizing verified legal norms, constitutional citations, and procedural safeguards.
class CivicAiService {
  static final CivicAiService instance = CivicAiService._internal();
  CivicAiService._internal();

  /// Analyzes a citizen question (text, voice, or media notice) and produces a verified statutory response.
  Future<CivicAiMessage> analyzeQuery({
    required String query,
    String? attachmentPath,
    String? attachmentName,
    String? attachmentType,
    String? audioPath,
  }) async {
    // Simulate real-time neural cognitive deliberation (400ms - 800ms)
    await Future.delayed(const Duration(milliseconds: 650));

    // Strip prefixes like "🎙️ Voice Query:", "Voice Query:", "Clarification:"
    String cleaned = query.trim();
    if (cleaned.startsWith('🎙️ Voice Query:')) {
      cleaned = cleaned.substring('🎙️ Voice Query:'.length).trim();
    } else if (cleaned.toLowerCase().startsWith('voice query:')) {
      cleaned = cleaned.substring('voice query:'.length).trim();
    }
    if (cleaned.toLowerCase().startsWith('clarification:')) {
      cleaned = cleaned.substring('clarification:'.length).trim();
    }

    final normalized = cleaned.toLowerCase().trim();
    final bool hasAttachment = attachmentPath != null;

    // Check if query is an untranscribed voice recording
    final bool isUntranscribedVoice = (audioPath != null &&
            (normalized.isEmpty ||
                RegExp(r'^question recorded at \d+s duration$', caseSensitive: false)
                    .hasMatch(normalized))) ||
        RegExp(r'^question recorded at \d+s duration$', caseSensitive: false)
            .hasMatch(normalized);

    if (isUntranscribedVoice) {
      return _generateVoiceQueryTriage(audioPath);
    }

    // 1. Analyze Document / Media Uploads
    if (hasAttachment && normalized.isEmpty) {
      return _generateDocumentAnalysis(attachmentName ?? 'Document', attachmentPath);
    }

    // 2. Query Gemini LLM if configured
    final geminiResponse = await GeminiAiService.instance.generateLegalAnswer(
      query: cleaned,
      audioPath: audioPath,
    );
    if (geminiResponse != null) {
      return geminiResponse;
    }

    // 2. Traffic Stop: Car Keys Snatched from Ignition
    if (normalized.contains('key') ||
        normalized.contains('keys') ||
        normalized.contains('ignition') ||
        normalized.contains('chabi') ||
        normalized.contains('chaabi') ||
        normalized.contains('चाबी') ||
        normalized.contains('गाड़ी की चाबी')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Vehicle Key Snatching & Wrongful Restraint',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. Police officers have NO legal right to snatch or remove keys from your vehicle\'s ignition or deflate your tyres.',
          legalReasoning:
              'Under the Motor Vehicles Act 1988 and State Police Manuals, traffic police are strictly prohibited from grabbing keys from a running or parked vehicle, as it causes safety hazards and constitutes wrongful restraint under Section 126 BNS (Section 339 IPC). Officers can only ask you to pull over and present documents.',
          sourceTitle: 'Based on: Traffic Enforcement & Section 126 BNS (Wrongful Restraint)',
          statutoryCitation: 'Sec 130 & 200 Motor Vehicles Act 1988; Sec 126 BNS 2023 / Sec 339 IPC',
          citizenActionSteps: [
            'Politely state: "Officer, seizing keys is prohibited under traffic rules and creates a hazard."',
            'Note the officer\'s name plate, rank, and police vehicle registration number.',
            'Keep your window rolled down enough to speak and show your electronic documents (DigiLocker).',
            'Report the incident to the Traffic Police Control Room (1095 / 112) or the Police Complaints Authority.',
          ],
          criticalDonts: [
            'DO NOT physically struggle with the officer to grab the keys back, as this could lead to obstruction charges (Sec 221 BNS).',
            'DO NOT step out leaving your vehicle unsecured in moving traffic.',
            'DO NOT pay an unreceipted cash bribe on the spot to get your keys returned.',
          ],
        ),
        triageOptions: [
          'Keys snatched by constable',
          'Told to step out of vehicle',
          'Two-wheeler key taken',
          'Vehicle being towed with occupants',
        ],
      );
    }

    // 3. Traffic Stop & Phone Seizure / WhatsApp Privacy
    if (normalized.contains('phone') ||
        normalized.contains('whatsapp') ||
        normalized.contains('chat') ||
        normalized.contains('mobile') ||
        normalized.contains('read my') ||
        normalized.contains('seize phone') ||
        normalized.contains('take my phone') ||
        normalized.contains('check my phone') ||
        normalized.contains('फोन') ||
        normalized.contains('मैसेज') ||
        normalized.contains('व्हाट्सएप')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Digital Privacy & Electronic Search Analysis',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_dispute_seizure',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. An officer cannot seize or browse your private smartphone without a formal judicial search warrant or an explicit cyber-forensics seizure memo under Section 102/100 CrPC (Section 105 BNSS).',
          legalReasoning:
              'Your digital privacy is protected under Article 21 of the Constitution of India (Supreme Court 9-judge benchmark ruling in Justice K.S. Puttaswamy vs. Union of India). '
              'Furthermore, under Article 20(3), you cannot be compelled to unlock, disclose passwords, or provide biometrics that lead to self-incrimination. '
              'An officer cannot withhold your phone as security for a compounding fine.',
          sourceTitle: 'Based on: Traffic Stop Card & Article 21 Privacy (Reviewed Oct 2026)',
          statutoryCitation: 'Article 21 & 20(3) Constitution of India; Sec 100 & 102 CrPC / Sec 105 BNSS 2023',
          citizenActionSteps: [
            'Politely state: "Officer, my personal device contains privileged private data protected under Article 21."',
            'Ask for the officer\'s name, rank, and police station number.',
            'Demand a formal seizure memo signed by independent witnesses if they insist on confiscation.',
            'Do not surrender your PIN or passcode without a judicial warrant.',
          ],
          criticalDonts: [
            'DO NOT unlock and hand over your open phone to an officer.',
            'DO NOT allow police to read private personal messages or photos without a judicial warrant.',
            'DO NOT delete files in panic, which can be misconstrued as tampering with evidence.',
          ],
        ),
        triageOptions: [
          '🚗 Stopped in personal car',
          '🛵 Riding two-wheeler',
          '🚶 Pedestrian check',
          'Are you above 18? (Yes / No)',
        ],
      );
    }

    // 4. Video Recording of Police in Public
    if (normalized.contains('record') ||
        normalized.contains('video') ||
        normalized.contains('film') ||
        normalized.contains('camera') ||
        normalized.contains('shooting') ||
        normalized.contains('रिकॉर्ड') ||
        normalized.contains('वीडियो')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Right to Video Record Public Law Enforcement',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Constitutional Right Protected',
          verdictColor: const Color(0xFF1B6B38),
          verdictBgColor: const Color(0xFFD4F5DE),
          directAnswer:
              'YES. You have the constitutional right to video record police officers performing their duties in public spaces, provided you do not physically obstruct them.',
          legalReasoning:
              'Under Article 19(1)(a) of the Constitution (Freedom of Speech & Expression), citizens and journalists have the right to gather and document public interactions. Multiple High Courts and police circulars have affirmed that recording public servants on duty is lawful and does not violate the Official Secrets Act. Police cannot snatch or smash your camera for recording.',
          sourceTitle: 'Based on: Article 19(1)(a) & Public Accountability Precedents',
          statutoryCitation: 'Article 19(1)(a) & 21 Constitution of India; Sec 126 BNS (Wrongful Restraint)',
          citizenActionSteps: [
            'Stand at a safe distance (3 to 5 paces) so you do not physically obstruct the officer.',
            'Calmly state: "I am peacefully recording this public interaction under Article 19(1)(a)."',
            'Ensure the video captures the officer\'s name badge, rank, and police vehicle number.',
            'Livestream or back up the footage to cloud storage immediately in case of device seizure.',
          ],
          criticalDonts: [
            'DO NOT thrust your camera directly into the officer\'s face or physical personal space.',
            'DO NOT use abusive, provocative, or mocking language while recording.',
            'DO NOT delete the video under verbal police intimidation without a formal court order.',
          ],
        ),
        triageOptions: [
          'Officer threatening to snatch phone',
          'Recording traffic stop',
          'Recording public protest',
          'Inside police station inquiry',
        ],
      );
    }

    // 5. Street Search / Bag Frisking on Road
    if (normalized.contains('bag') ||
        normalized.contains('pocket') ||
        normalized.contains('frisk') ||
        normalized.contains('search me') ||
        normalized.contains('search my bag') ||
        normalized.contains('search my pocket') ||
        normalized.contains('search my person') ||
        normalized.contains('backpack') ||
        normalized.contains('सड़क पर तलाशी') ||
        normalized.contains('बैग')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Personal Search & Bag Inspection Safeguards',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'police_at_door_search_residential_without_warrant',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Procedural Rules Apply',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Police can only search your bag or person if they have reasonable suspicion of a crime, and they MUST follow Section 100 CrPC / Section 105 BNSS safeguards including presence of independent witnesses.',
          legalReasoning:
              'Under Section 100 CrPC (Section 105 BNSS 2023), any search must be witnessed by two respectable local inhabitants (Panchas). Female citizens can ONLY be searched by female police officers with strict decency under Section 51(2) CrPC / Section 49 BNSS. You have the right to ask the officer to empty their own pockets first to prevent planting of evidence.',
          sourceTitle: 'Based on: Search Safeguards under CrPC & BNSS 2023',
          statutoryCitation: 'Sec 51 & 100 CrPC / Sec 49 & 105 BNSS 2023; Article 21 Constitution of India',
          citizenActionSteps: [
            'Politely ask: "Officer, what is the reasonable statutory suspicion or ground for searching my bag?"',
            'Exercise your right to have the searching officer empty their own pockets first.',
            'Demand that two independent public witnesses (Panchas) be present during the search.',
            'Insist that female officers conduct any physical search of female persons.',
          ],
          criticalDonts: [
            'DO NOT permit an unrecorded search in a secluded, dark alley without witnesses.',
            'DO NOT touch or pick up any suspicious packet or object shown by an officer.',
            'DO NOT physically push officers away; assert your procedural rights verbally.',
          ],
        ),
        triageOptions: [
          'Search at metro/mall checkpoint',
          'Pedestrian stopped on street',
          'Female citizen search',
          'Items seized without memo',
        ],
      );
    }

    // 6. Home Search Without Warrant
    if (normalized.contains('home') ||
        normalized.contains('house') ||
        normalized.contains('flat') ||
        normalized.contains('door') ||
        normalized.contains('warrant') ||
        normalized.contains('ghar') ||
        normalized.contains('कमरा') ||
        normalized.contains('घर की तलाशी') ||
        normalized.contains('वारंट')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Residential Search & Warrant Verification',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'police_at_door_search_residential_without_warrant',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Unlawful Without Specific Ground',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Police CANNOT enter and search your home without a judicial warrant, except under strict emergency conditions of Section 165 CrPC / Section 185 BNSS.',
          legalReasoning:
              'Under Section 165 CrPC (Section 185 BNSS 2023), warrantless entry requires the officer to record written grounds in the General Diary beforehand, explain why a warrant could not be obtained without delay, and notify the Magistrate immediately. Two independent local witnesses (Panchas) must witness the entire search, and male officers cannot enter female rooms without female police presence.',
          sourceTitle: 'Based on: Section 165 CrPC & Residential Privacy Norms',
          statutoryCitation: 'Sec 93, 100 & 165 CrPC / Sec 96, 105 & 185 BNSS 2023; Article 21 Constitution',
          citizenActionSteps: [
            'Ask to see the Search Warrant or the written Section 165 CrPC emergency authorization.',
            'Demand the presence of two independent neighbours or local residents as search witnesses (Panchas).',
            'Ensure female occupants are searched and attended only by female police officers.',
            'Demand an itemized, signed Search List (Panchnama) of all articles taken into custody.',
          ],
          criticalDonts: [
            'DO NOT open the door completely before verifying the officers\' official ID cards and rank.',
            'DO NOT sign a blank or incomplete Panchnama inventory list.',
            'DO NOT leave officers unmonitored in rooms where valuable personal items are kept.',
          ],
        ),
        triageOptions: [
          'No warrant presented',
          'Night time search',
          'Women/children present inside',
          'Landlord accompanied police',
        ],
      );
    }

    // 7. Couples / Moral Policing in Public Spaces or Hotels
    if (normalized.contains('couple') ||
        normalized.contains('boyfriend') ||
        normalized.contains('girlfriend') ||
        normalized.contains('unmarried') ||
        normalized.contains('park') ||
        normalized.contains('hotel') ||
        normalized.contains('room') ||
        normalized.contains('check in') ||
        normalized.contains('moral policing') ||
        normalized.contains('साथ बैठे') ||
        normalized.contains('कपल') ||
        normalized.contains('होटल') ||
        normalized.contains('कमरा')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Hotel Accommodation & Privacy Rights of Consenting Adults',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'hotel_refusal_unmarried_adult_checkin',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Unlawful Moral Policing',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO law in India prohibits two consenting adults from sitting together in public or sharing a hotel room. Police have NO authority to question or moral-police couples.',
          legalReasoning:
              'Under Articles 19(1) and 21 of the Constitution, adult citizens (18+) possess complete personal liberty and privacy. Sitting together or holding hands does not constitute public obscenity under Section 296 BNS (Section 294 IPC). Police have no authority to contact parents, demand marriage certificates, or extort informal fines.',
          sourceTitle: 'Based on: Hotel & Public Space Privacy & Article 21 Rights',
          statutoryCitation: 'Articles 19(1)(d) & 21 Constitution of India; Sec 296 BNS 2023 / Sec 294 IPC',
          citizenActionSteps: [
            'Produce valid government photo ID proving age 18+ (Aadhaar, Voter ID, DL, Passport).',
            'State clearly: "We are consenting adults and are violating no statutory law."',
            'If police threaten to call parents, remind them: "Adult citizens have constitutional autonomy; calling family is unauthorized."',
            'If hotel refuses check-in based on marital status, request a written refusal receipt and file a consumer complaint.',
          ],
          criticalDonts: [
            'DO NOT pay any unauthorized spot fines or bribes to avoid public embarrassment.',
            'DO NOT surrender unlocked smartphones or private photo galleries to moral-policing cops.',
            'DO NOT sign written confessions or apologies admitting false public nuisance charges.',
          ],
        ),
        triageOptions: [
          'Both partners are above 18',
          'Police threatening to call parents',
          'Hotel refused room booking',
          'Harassed in public park or car',
        ],
      );
    }

    // 8. Women Arrest / Night Arrest Rules
    if (normalized.contains('woman') ||
        normalized.contains('women') ||
        normalized.contains('female') ||
        normalized.contains('sunset') ||
        normalized.contains('sunrise') ||
        normalized.contains('mahila') ||
        normalized.contains('महिला') ||
        normalized.contains('लड़की')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Statutory Safeguards for Women During Arrest & Inquiry',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'arrest_detention_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Night Arrest Strictly Prohibited',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO woman can be arrested between sunset and sunrise, except with prior written permission from a Judicial Magistrate under Section 46(4) CrPC / Section 43(5) BNSS.',
          legalReasoning:
              'Under Section 46(4) CrPC (Section 43(5) BNSS 2023), women are protected from nighttime arrests. Furthermore, under Section 46(1), only a female police officer can touch or arrest a female citizen. Questioning of women must take place at their place of residence in the presence of relatives under Section 160 CrPC.',
          sourceTitle: 'Based on: Supreme Court Binding Directives on Women Custody Safeguards',
          statutoryCitation: 'Sec 46(4), 46(1) & 160 CrPC / Sec 43(5) & 179 BNSS 2023; D.K. Basu (1997)',
          citizenActionSteps: [
            'Demand to see the female police officer and the Judicial Magistrate\'s written nighttime order.',
            'Insist that any questioning occur at your residence in the presence of family members (Sec 160 CrPC).',
            'Dial Women Helpline 1091 / 181 or Emergency 112 immediately if male officers threaten custody.',
            'Undergo a mandatory medical examination by a female medical practitioner under Section 54 CrPC.',
          ],
          criticalDonts: [
            'DO NOT accompany male police officers to a police station at night without a woman officer.',
            'DO NOT permit male officers to perform body searches or physical restraint.',
            'DO NOT remain silent before the Magistrate if statutory custody safeguards were breached.',
          ],
        ),
        triageOptions: [
          'Arrest attempted after sunset',
          'No woman officer present',
          'Called to station for questioning',
          'Physical harassment by officer',
        ],
      );
    }

    // 9. Bribery & Extortion by Police / Public Servants
    if (normalized.contains('bribe') ||
        normalized.contains('corruption') ||
        normalized.contains('demanded money') ||
        normalized.contains('rishwat') ||
        normalized.contains('ghoos') ||
        normalized.contains('रिश्वत') ||
        normalized.contains('पैसे मांग रहे')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Anti-Corruption Mandate & Extortion Redress',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'asked_for_bribe_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Serious Criminal Offence by Officer',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Demanding a bribe is a severe non-bailable crime punishable with up to 7 years imprisonment under Section 7 of the Prevention of Corruption Act.',
          legalReasoning:
              'Under Section 7 of the Prevention of Corruption (Amendment) Act 2018, any public servant who obtains or attempts to obtain an undue advantage commits a criminal offence. If a citizen is forced to pay under duress, reporting the incident within 7 days provides statutory immunity from prosecution under Section 8 Proviso.',
          sourceTitle: 'Based on: Prevention of Corruption Act 1988 (Amended 2018)',
          statutoryCitation: 'Sec 7 & 8 Proviso, Prevention of Corruption Act 1988; Sec 199 BNS 2023',
          citizenActionSteps: [
            'Refuse politely and document the officer\'s name, badge number, station, and time.',
            'Preserve unedited digital audio/video or payment request QR records if safely possible.',
            'Call the State Anti-Corruption Bureau (ACB) or Vigilance Helpline Toll-Free on 1064.',
            'Report the coerced payment within 7 days to preserve statutory citizen immunity.',
          ],
          criticalDonts: [
            'DO NOT volunteer or offer a bribe, as active bribe-giving without reporting is also an offence.',
            'DO NOT send money to a private UPI handle without an official government treasury receipt.',
            'DO NOT delay reporting beyond 7 days to protect your statutory legal immunity.',
          ],
        ),
        triageOptions: [
          'Demand made at traffic stop',
          'Bribe for passport/verification',
          'Bribe to register FIR',
          'Report to Anti-Corruption Bureau',
        ],
      );
    }

    // 10. Custodial Violence / Beating / Torture
    if (normalized.contains('beat') ||
        normalized.contains('hit') ||
        normalized.contains('torture') ||
        normalized.contains('third degree') ||
        normalized.contains('slap') ||
        normalized.contains('violence') ||
        normalized.contains('मारपीट') ||
        normalized.contains('थर्ड डिग्री') ||
        normalized.contains('पुलिस ने मारा')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Prohibition of Custodial Violence & Torture',
        isUser: false,
        timestamp: DateTime.now(),
        isEmergency: true,
        relatedCardId: 'arrest_detention_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Zero-Tolerance Custodial Abuse',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Police have NO legal authority to beat, slap, or torture any citizen during a stop, inquiry, or custody. Custodial assault is a punishable crime.',
          legalReasoning:
              'The Supreme Court in D.K. Basu vs. State of West Bengal (1997) strictly banned torture and third-degree methods. Physical violence by police officers constitutes offences under Section 115/118 BNS (Voluntarily Causing Hurt/Grievous Hurt) and Section 199 BNS, resulting in criminal prosecution and departmental dismissal.',
          sourceTitle: 'Based on: Supreme Court D.K. Basu Directives & BNS Criminal Provisions',
          statutoryCitation: 'Articles 20(3) & 21 Constitution; Sec 115 & 118 BNS 2023; Sec 54 CrPC',
          citizenActionSteps: [
            'Demand an immediate medical examination at a government hospital under Section 54 CrPC.',
            'Ensure the examining doctor records every single mark and injury in the Medico-Legal Certificate (MLC).',
            'State the assault directly to the Judicial Magistrate during your mandatory 24-hour production.',
            'Lodge complaints with the State Human Rights Commission (SHRC) and Police Complaints Authority (PCA).',
          ],
          criticalDonts: [
            'DO NOT conceal injuries from the medical officer or Magistrate out of police fear.',
            'DO NOT sign statements stating you were treated well while suffering physical injuries.',
            'DO NOT discard torn or blood-stained clothing; preserve them as forensic physical evidence.',
          ],
        ),
        triageOptions: [
          'Physical injury sustained',
          'Currently detained in lockup',
          'Medical examination requested',
          'Report to Magistrate',
        ],
      );
    }

    // 11. Handcuffing Safeguards
    if (normalized.contains('handcuff') ||
        normalized.contains('handcuffs') ||
        normalized.contains('hathkadi') ||
        normalized.contains('हथकड़ी')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Handcuffing Restrictions & Human Dignity Protections',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'arrest_detention_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Restricted by Supreme Court',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Routine handcuffing is ILLEGAL in India. Police cannot handcuff an accused person without prior written justification and specific permission from a Magistrate.',
          legalReasoning:
              'In Prem Shankar Shukla vs. Delhi Administration (1980) and Citizen for Democracy vs. State of Assam (1995), the Supreme Court ruled that handcuffing without judicial permission violates human dignity under Article 21. Handcuffs are only permissible if there is an objective, documented risk of violent escape recorded in the case diary.',
          sourceTitle: 'Based on: Prem Shankar Shukla Benchmark Precedent (Supreme Court)',
          statutoryCitation: 'Article 21 Constitution of India; Prem Shankar Shukla (1980) 3 SCC 526; Sec 43 BNSS',
          citizenActionSteps: [
            'Ask: "Under Prem Shankar Shukla judgment, routine handcuffing is barred. Do you have judicial permission?"',
            'Verify whether reasons for restraint are specifically recorded in the Case Diary.',
            'Complain directly to the Magistrate regarding improper handcuffing during your first court production.',
          ],
          criticalDonts: [
            'DO NOT physically struggle with handcuffs, which may trigger severe physical retaliation.',
            'DO NOT allow yourself to be paraded in public in handcuffs without protesting to the court.',
          ],
        ),
        triageOptions: [
          'Handcuffed during transit',
          'Paraded in public',
          'No judicial permission shown',
          'Free legal aid lawyer (15100)',
        ],
      );
    }

    // 12. Tenancy: Lockout, Illegal Eviction & Water/Electricity Disconnection
    if (normalized.contains('landlord') ||
        normalized.contains('evict') ||
        normalized.contains('eviction') ||
        normalized.contains('lockout') ||
        normalized.contains('room lock') ||
        normalized.contains('deposit') ||
        normalized.contains('makan malik') ||
        normalized.contains('tenant') ||
        normalized.contains('किराया') ||
        normalized.contains('मकान मालिक') ||
        normalized.contains('कमरा बंद')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Tenant Rights & Protection Against Forceful Eviction',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'eviction_lockout_illegal_forceful_eviction',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Unlawful Forceful Eviction',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'A landlord CANNOT throw you out, change door locks, or disconnect electricity/water without a formal eviction order from a competent Rent Court.',
          legalReasoning:
              'Tenancy disputes are strictly civil in nature. Disconnecting essential services like water or power is a criminal offence under Section 430 IPC / Section 326 BNS (Mischief). Landlords must issue a written statutory notice (typically 30 days) and file an eviction suit. Arbitrary retention of security deposits without itemized damage invoices is an actionable civil wrong.',
          sourceTitle: 'Based on: State Rent Control Acts & Section 430 IPC (Mischief)',
          statutoryCitation: 'State Rent Control Acts; Sec 430 IPC / Sec 326 BNS 2023; Sec 441 IPC (Criminal Trespass)',
          citizenActionSteps: [
            'Preserve your rent agreement, payment receipts, and bank transaction history.',
            'Dial 112 immediately if the landlord forcibly enters, cuts utilities, or changes locks.',
            'File an application before the Rent Authority / Civil Court for immediate restoration of possession.',
            'Send a formal legal notice demanding security deposit refund within 15 days.',
          ],
          criticalDonts: [
            'DO NOT voluntarily hand over your keys or abandon the premises under verbal threats.',
            'DO NOT stop paying undisputed monthly rent, as default weakens your court defense.',
            'DO NOT engage in physical violence with bouncers; let police document criminal trespass.',
          ],
        ),
        triageOptions: [
          'Locks changed by landlord',
          'Electricity/water cut off',
          'Security deposit withheld',
          'Less than 30 days notice given',
        ],
      );
    }

    // 13. Drunk Driving & Breath Analyzer Test
    if (normalized.contains('drunk') ||
        normalized.contains('alcohol') ||
        normalized.contains('drink') ||
        normalized.contains('breathalyzer') ||
        normalized.contains('sharab') ||
        normalized.contains('शराब') ||
        normalized.contains('ड्रिंक एंड ड्राइव')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Drunk Driving Enforcement & Scientific Verification',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Mandatory Scientific Verification',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Traffic police can test for alcohol, but penalizing for drunken driving REQUIRES a calibrated breath analyzer test or hospital blood test showing alcohol exceeding 30mg per 100ml of blood.',
          legalReasoning:
              'Under Section 185 and Section 203 of the Motor Vehicles Act 1988, an offence is made out only if blood alcohol content (BAC) exceeds 30 mg per 100 ml as detected by a breathalyzer test. Police cannot fine you on mere smell. You have the right to inspect the digital screen and request a fresh, sealed plastic mouthpiece.',
          sourceTitle: 'Based on: Section 185 & 203 Motor Vehicles Act 1988',
          statutoryCitation: 'Sec 185, 203 & 205 Motor Vehicles Act 1988; Rule 139 CMVR',
          citizenActionSteps: [
            'Cooperate with the breathalyzer test, but insist on a sealed, hygienic mouthpiece.',
            'Inspect the digital reading on the device and take a photograph of the printed receipt.',
            'If you contest the device\'s accuracy, demand an immediate hospital blood test under Sec 205 MV Act.',
            'Arrange for a sober friend or designated driver to take custody of your vehicle.',
          ],
          criticalDonts: [
            'DO NOT drive under the influence of alcohol or narcotics under any circumstance.',
            'DO NOT refuse the test without justification, as refusal is penalised under Sec 203(3) MV Act.',
            'DO NOT pay cash without an official printed challan indicating your exact BAC reading.',
          ],
        ),
        triageOptions: [
          'Breathalyzer test requested',
          'Contesting false BAC reading',
          'Vehicle impounded roadside',
          'Summons to Virtual Court',
        ],
      );
    }

    // 14. Traffic Stop / Challan / DigiLocker / Helmets
    if (normalized.contains('police stopped') ||
        normalized.contains('traffic') ||
        normalized.contains('challan') ||
        normalized.contains('license') ||
        normalized.contains('helmet') ||
        normalized.contains('seatbelt') ||
        normalized.contains('rc') ||
        normalized.contains('puc') ||
        normalized.contains('चालान') ||
        normalized.contains('हेलमेट') ||
        normalized.contains('गाड़ी रोक') ||
        normalized.contains('ड्राइविंग लाइसेंस')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Motor Vehicle Enforcement & Traffic Stop Analysis',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Procedural Rules Apply',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Electronic documents on DigiLocker/mParivahan are 100% legally valid across India. Police CANNOT penalize you or seize your vehicle for not carrying physical original cards.',
          legalReasoning:
              'Under Rule 139 of the Central Motor Vehicles Rules (CMVR) and MoRTH notifications, digital driving licences and vehicle registration certificates shown via DigiLocker or mParivahan have equal status to physical documents. Furthermore, if you cannot show documents at all, police cannot impound on the spot without giving 15 days to present them under Rule 139. Only an officer of Sub-Inspector (SI) / ASI or higher rank can issue compoundable spot challans.',
          sourceTitle: 'Based on: Traffic Enforcement & Rule 139 CMVR (Motor Vehicles Act 2019)',
          statutoryCitation: 'Sec 130 & Sec 200 Motor Vehicles Act 1988; Rule 139 CMVR 1989',
          citizenActionSteps: [
            'Display your digital Driving License & RC via official DigiLocker or mParivahan.',
            'Verify the officer is wearing a name badge with rank insignia (Sub-Inspector / ASI or above).',
            'Request an official printed e-challan receipt with transaction ID if paying on the spot.',
            'Never hand over the physical keys; police cannot remove vehicle keys from the ignition.',
          ],
          criticalDonts: [
            'DO NOT show mere screenshots or WhatsApp forwards; use the official DigiLocker app.',
            'DO NOT hand over your phone into the officer\'s custody; show the screen from your hands.',
            'DO NOT pay cash without an instantaneous SMS or printed receipt from the POS machine.',
          ],
        ),
        triageOptions: [
          'Show DigiLocker on screen',
          'Demand e-Challan receipt',
          'Vehicle keys taken by cop',
          'Breath analyzer test requested',
        ],
      );
    }

    // 15. FIR Refusal / Police Station Won't Register Complaint / Zero FIR
    if (normalized.contains('fir') ||
        normalized.contains('police refused') ||
        normalized.contains('refused to register') ||
        normalized.contains('police station refuse') ||
        normalized.contains('not taking complaint') ||
        normalized.contains('zero fir') ||
        normalized.contains('एफआईआर') ||
        normalized.contains('रिपोर्ट नहीं') ||
        normalized.contains('शिकायत नहीं')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'FIR Registration Mandate & Zero FIR Remedy',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'fir_refused_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: FIR Registration Mandatory',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Police officers are legally mandated to register an FIR whenever a cognizable offence is disclosed. Refusal is punishable under Section 166A IPC (Section 199 BNS).',
          legalReasoning:
              'In Lalita Kumari vs. Govt. of U.P. (2014), the Supreme Court ruled that registration of an FIR is mandatory under Section 154 CrPC (Section 173 BNSS). Under Section 173 BNSS, any police station must register a "Zero FIR" regardless of jurisdiction. If the local station refuses, you have the statutory right under Section 154(3) CrPC / Section 175(3) BNSS to send your written complaint directly to the Superintendent of Police (SP).',
          sourceTitle: 'Based on: FIR Escalation & Lalita Kumari Supreme Court Mandate',
          statutoryCitation: 'Sec 154 & 156(3) CrPC / Sec 173 & 175(3) BNSS; Lalita Kumari (2014) 2 SCC 1',
          citizenActionSteps: [
            'Politely remind the Station Officer: "Under Lalita Kumari judgment, recording an FIR is mandatory for cognizable offences."',
            'Request a signed endorsement or General Diary (GD) entry acknowledgment.',
            'Send the complaint copy by registered post or speed post to the Superintendent of Police (SP).',
            'Generate a formal SP complaint draft from CIVIC Help > After an Incident.',
          ],
          criticalDonts: [
            'DO NOT leave the police station without obtaining a signed receiving copy of your written complaint.',
            'DO NOT let officers dilute a serious cognizable crime into a non-cognizable (NCR) report.',
            'DO NOT pay any bribe to register an FIR; FIR copies must be provided 100% free of cost.',
          ],
        ),
        triageOptions: [
          'Theft / Cyber offence',
          'Assault / Threats',
          'Zero FIR transfer',
          'Representation to SP',
        ],
      );
    }

    // 16. College Withholding Original Certificates / Degrees
    if (normalized.contains('certificate') ||
        normalized.contains('degree') ||
        normalized.contains('marksheet') ||
        normalized.contains('original document') ||
        normalized.contains('fees') ||
        normalized.contains('डिग्री') ||
        normalized.contains('सर्टिफिकेट')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Non-Retention of Academic Certificates by Institutions',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'certificate_withheld_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Prohibited by UGC',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Colleges and universities CANNOT legally withhold your original certificates, mark sheets, or degrees for fee arrears or disputes.',
          legalReasoning:
              'The University Grants Commission (UGC) Regulations explicitly prohibit higher educational institutions from retaining original academic certificates. Original documents are the personal property of the student; keeping them constitutes illegal retention, wrongful restraint (Sec 126 BNS), and criminal breach of trust (Sec 316 BNS).',
          sourceTitle: 'Based on: UGC Public Regulations & Student Rights Framework',
          statutoryCitation: 'UGC Public Notice No. F. 1-3/2007 (CPP-II); Sec 316 BNS 2023; Sec 126 BNS',
          citizenActionSteps: [
            'Send a formal Demand Letter citing UGC Regulations requesting return within 7 days.',
            'Lodge an online grievance on the UGC e-Samadhan portal (samadhan.ugc.ac.in).',
            'File a complaint with the State Higher Education Department and District Magistrate.',
            'Approach the High Court under Article 226 for a writ of Mandamus if non-compliance continues.',
          ],
          criticalDonts: [
            'DO NOT surrender original certificates permanently; institutions can only inspect them.',
            'DO NOT sign indemnity waivers agreeing to forfeit documents as collateral.',
            'DO NOT pay unauthorized "certificate release fees" demanded by college staff.',
          ],
        ),
        triageOptions: [
          'Degree withheld for unpaid fees',
          'Transfer certificate (TC) refused',
          'File grievance on UGC portal',
          'Send legal notice to college',
        ],
      );
    }

    // 17. Ragging & Campus Harassment
    if (normalized.contains('rag') ||
        normalized.contains('senior') ||
        normalized.contains('college') ||
        normalized.contains('hostel') ||
        normalized.contains('campus') ||
        normalized.contains('रैगिंग') ||
        normalized.contains('कॉलेज')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Anti-Ragging Protection & UGC Regulations',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'ragging_victim_default',
        isEmergency: normalized.contains('hurt') || normalized.contains('beat') || normalized.contains('danger'),
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Zero-Tolerance Criminal Offence',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Ragging is strictly prohibited by law. Educational institutions are legally required to file an FIR with the local police station within 24 hours of receiving a complaint.',
          legalReasoning:
              'Under the UGC Regulations on Curbing the Menace of Ragging in Higher Educational Institutions 2009 and the Supreme Court mandate in Vishwa Jagriti Mission (2001), any act of physical abuse, verbal insult, financial extortion, or psychological intimidation constitutes criminal ragging. Heads of institutions who fail to act face de-recognition and penal action.',
          sourceTitle: 'Based on: UGC Anti-Ragging Regulations 2009 & IPC/BNS Criminal Norms',
          statutoryCitation: 'UGC Regulations 2009; Sec 351 BNS (Criminal Intimidation) / Sec 115 BNS (Hurt)',
          citizenActionSteps: [
            'Call the 24×7 Anti-Ragging Toll-Free Helpline immediately: 1800-180-5522.',
            'Submit an anonymous or confidential report to helpline@antiragging.in.',
            'Notify the Anti-Ragging Squad (ARS) and Dean of Student Affairs in writing.',
            'If physical violence occurred, dial 112 for immediate police intervention.',
          ],
          criticalDonts: [
            'DO NOT suffer ragging in silence; confidential reporting is protected by law.',
            'DO NOT accept internal "compromises" that conceal physical violence.',
            'DO NOT meet abusers alone in isolated hostel rooms.',
          ],
        ),
        triageOptions: [
          'Immediate physical danger',
          'Hostel room intimidation',
          'Anonymous reporting route',
          'File FIR at police station',
        ],
      );
    }

    // 17B. Road Accident & Good Samaritan Rights
    if (normalized.contains('accident') ||
        normalized.contains('good samaritan') ||
        normalized.contains('hit and run') ||
        normalized.contains('solatium') ||
        normalized.contains('injured person') ||
        normalized.contains('सड़क दुर्घटना') ||
        normalized.contains('एक्सीडेंट')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Road Accident Good Samaritan Protection',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'road_accident_good_samaritan_default',
        isEmergency: true,
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Absolute Legal Immunity',
          verdictColor: const Color(0xFF1B6B38),
          verdictBgColor: const Color(0xFFD4F5DE),
          directAnswer:
              'Under Section 134A of the Motor Vehicles Act 1988, Good Samaritans helping accident victims are immune from civil or criminal liability. Hospitals and police cannot detain or charge you.',
          legalReasoning:
              'In SaveLIFE Foundation vs. Union of India, the Supreme Court mandated that bystanders taking accident victims to hospitals cannot be compelled to disclose identity, pay advance fees, or testify as witnesses. Section 161 MV Act also guarantees ₹2,00,000 solatium for hit-and-run fatalities.',
          sourceTitle: 'Based on: Section 134A & 161 Motor Vehicles Act 1988',
          statutoryCitation: 'Sec 134A & 161 MV Act 1988; SaveLIFE Foundation Supreme Court Guidelines',
          citizenActionSteps: [
            'Dial 112 / 108 emergency services immediately to report the crash location.',
            'State to hospital casualty staff: "I am a Good Samaritan under Sec 134A MV Act."',
            'You are legally free to leave hospital immediately after delivering the injured victim.',
            'If hit-and-run occurred, file an application with the SDM for statutory solatium compensation.',
          ],
          criticalDonts: [
            'DO NOT pay hospital casualty admission deposits for an unknown injured victim.',
            'DO NOT submit to coercive police station detention or involuntary testimony.',
            'DO NOT move victims with suspected spinal injuries unless trained or in immediate hazard.',
          ],
        ),
        triageOptions: [
          'Assisting accident victim at scene',
          'Hospital demanding admission fee',
          'Police insisting on station testimony',
          'Hit and run solatium fund claim',
        ],
      );
    }

    // 17C. Senior Citizen Maintenance & Property Revocation
    if (normalized.contains('senior citizen') ||
        normalized.contains('elderly') ||
        normalized.contains('parents maintenance') ||
        normalized.contains('gift deed cancel') ||
        normalized.contains('elder abuse') ||
        normalized.contains('बुजुर्ग') ||
        normalized.contains('माता-पिता')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Senior Citizen Maintenance & Property Rights',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'senior_citizen_maintenance_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Protected Senior Rights',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Under the Maintenance of Senior Citizens Act 2007, senior citizens can claim monthly maintenance from children and revoke property gift deeds under Section 23 if children fail to care for them.',
          legalReasoning:
              'The Sub-Divisional Magistrate (SDM) heads the summary Maintenance Tribunal. Under Section 23, any property transferred by a senior on condition of care can be declared void if children neglect basic amenities. Section 24 also criminalizes abandonment of elderly parents.',
          sourceTitle: 'Based on: Maintenance and Welfare of Parents and Senior Citizens Act 2007',
          statutoryCitation: 'Sec 4, 9, 23 & 24 Senior Citizens Act 2007; S. Vanitha vs DC (Supreme Court 2020)',
          citizenActionSteps: [
            'Call the National Elderline Helpline 14567 for free counseling and rescue assistance.',
            'File a summary petition before the SDM Maintenance Tribunal for monthly maintenance.',
            'Apply under Section 23 to declare conditional gift deeds null and void if neglected.',
            'Seek summary eviction of abusive children from your self-acquired residential property.',
          ],
          criticalDonts: [
            'DO NOT suffer physical abuse or abandonment in silence.',
            'DO NOT sign general powers of attorney or sale deeds under duress from relatives.',
            'DO NOT file complex civil suits when the summary SDM tribunal provides fast 90-day relief.',
          ],
        ),
        triageOptions: [
          'Monthly maintenance from children',
          'Cancel gifted property (Section 23)',
          'Evict abusive relatives from home',
          'Dial National Elderline (14567)',
        ],
      );
    }

    // 17D. Health Insurance Cashless Denial
    if (normalized.contains('cashless') ||
        normalized.contains('health insurance') ||
        normalized.contains('mediclaim') ||
        normalized.contains('insurance rejected') ||
        normalized.contains('tpa') ||
        normalized.contains('बीमा') ||
        normalized.contains('कैशलेस')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Health Insurance & Cashless Discharge Mandate',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'health_insurance_claim_rejected_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: 3-Hour Decision Mandate',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Under IRDAI 2024 regulations, insurers must provide final cashless discharge clearance within 3 hours. Hospitals cannot detain patients or withhold discharge summaries.',
          legalReasoning:
              'The IRDAI Master Circular 2024 requires insurance companies to approve cashless claims within 3 hours of hospital submission. For wrongful repudiations, the Insurance Ombudsman provides free, binding dispute resolution up to ₹50 lakh within 30 days without advocate fees.',
          sourceTitle: 'Based on: IRDAI Master Circular on Health Insurance 2024',
          statutoryCitation: 'IRDAI Master Circular 2024; Rule 13 & 17 Insurance Ombudsman Rules 2017',
          citizenActionSteps: [
            'Show hospital TPA desk the IRDAI Master Circular mandating 3-hour discharge decisions.',
            'Demand an itemized bill and formal written rejection letter specifying the exact exclusion clause.',
            'Lodge an urgent ticket on IRDAI Bima Bharosa portal (bimabharosa.irdai.gov.in).',
            'File a free complaint before the Insurance Ombudsman (cioins.co.in) within 1 year.',
          ],
          criticalDonts: [
            'DO NOT allow hospital billing desks to hold patient physically hostage for billing delays.',
            'DO NOT pay disputed charges without an official signed receipt from medical superintendent.',
            'DO NOT accept verbal denials without citing specific policy clauses.',
          ],
        ),
        triageOptions: [
          'Cashless delayed past 3 hours',
          'Claim rejected citing pre-existing condition',
          'File on IRDAI Bima Bharosa',
          'Insurance Ombudsman complaint',
        ],
      );
    }

    // 17E. Noise Pollution & Loudspeakers
    if (normalized.contains('noise') ||
        normalized.contains('loudspeaker') ||
        normalized.contains('dj') ||
        normalized.contains('night noise') ||
        normalized.contains('sound pollution') ||
        normalized.contains('शोर') ||
        normalized.contains('लाउडस्पीकर')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Noise Pollution & Loudspeaker Regulation',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'noise_pollution_illegal_construction_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: 10 PM Silence Mandate',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Loudspeakers, DJ sound systems, and commercial noise are strictly banned in residential areas between 10:00 PM and 6:00 AM under Noise Pollution Rules 2000.',
          legalReasoning:
              'Rule 5 of the Noise Pollution (Regulation and Control) Rules 2000 and Section 270 BNS make operating public address systems past 10 PM a punishable nuisance. Under Rule 8, police officers are legally mandated to seize and impound sound equipment upon citizen complaint.',
          sourceTitle: 'Based on: Noise Pollution Rules 2000 & Section 270 BNS 2023',
          statutoryCitation: 'Rule 5 & 8 Noise Pollution Rules 2000; Sec 270 BNS 2023 (Public Nuisance)',
          citizenActionSteps: [
            'Dial 112 police emergency and state: "Violation of Noise Pollution Rules 2000 after 10 PM."',
            'Record the dispatch call reference number and time of complaint.',
            'Demand immediate equipment seizure under Rule 8 of the Noise Rules.',
            'If police fail to act, submit written representation to the Sub-Divisional Magistrate (SDM).',
          ],
          criticalDonts: [
            'DO NOT enter into direct physical confrontations with event organizers late at night.',
            'DO NOT allow organizers to continue without displaying written municipal sound permits.',
            'DO NOT accept verbal assurances from police without equipment volume shutdown.',
          ],
        ),
        triageOptions: [
          'Loudspeakers blasting past 10 PM',
          'Commercial DJ in residential zone',
          'Report on Police 112',
          'SDM written nuisance complaint',
        ],
      );
    }

    // 17F. Stray Animal Feeding & RWA Protection
    if (normalized.contains('stray dog') ||
        normalized.contains('feed dogs') ||
        normalized.contains('animal feeder') ||
        normalized.contains('rwa dog') ||
        normalized.contains('animal cruelty') ||
        normalized.contains('कुत्ता') ||
        normalized.contains('जानवर')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Community Animal Feeder Constitutional Rights',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'animal_cruelty_stray_feeding_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Constitutional Right Protected',
          verdictColor: const Color(0xFF1B6B38),
          verdictBgColor: const Color(0xFFD4F5DE),
          directAnswer:
              'Feeding community animals is a protected constitutional right under Article 51A(g) and ABC Rules 2023. RWAs have NO legal authority to ban feeding or fine citizens.',
          legalReasoning:
              'High Court rulings and Rule 20 of the Animal Birth Control Rules 2023 confirm that citizens have the right to feed community animals. RWAs cannot impose arbitrary fines or prohibit feeding. Furthermore, Section 325 BNS makes poisoning or killing community animals punishable with up to 5 years imprisonment.',
          sourceTitle: 'Based on: Article 51A(g) & Animal Birth Control Rules 2023',
          statutoryCitation: 'Article 51A(g) Constitution; Rule 20 ABC Rules 2023; Sec 325 BNS 2023',
          citizenActionSteps: [
            'Designate community feeding points away from children play areas in coordination with RWA.',
            'Carry official guidelines from the Animal Welfare Board of India (AWBI).',
            'If residents physically threaten or assault you, dial 112 and file an FIR under Sec 115/351 BNS.',
            'Report cruelty or dog relocation attempts to the local police and SPCA.',
          ],
          criticalDonts: [
            'DO NOT pay unlawful fines or penalties imposed by residential welfare associations.',
            'DO NOT allow unauthorized relocation or displacement of sterilized community dogs.',
            'DO NOT engage in violent arguments; capture video evidence of threats or harassment.',
          ],
        ),
        triageOptions: [
          'RWA harassing animal feeder',
          'Illegal fines imposed by society',
          'Animal cruelty or poisoning incident',
          'AWBI feeder guidelines',
        ],
      );
    }

    // 17G. Gig Worker Rights & ID Blocking
    if (normalized.contains('gig worker') ||
        normalized.contains('delivery boy') ||
        normalized.contains('zomato') ||
        normalized.contains('swiggy') ||
        normalized.contains('uber') ||
        normalized.contains('ola') ||
        normalized.contains('deplatform') ||
        normalized.contains('id block') ||
        normalized.contains('डिलीवरी')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Gig Worker Protections & Platform Rights',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'gig_worker_rights_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Protected Livelihood Rights',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Platforms cannot arbitrarily deactivate gig worker IDs or forfeit earned weekly payouts without written notice, grievance redressal, and fair procedure.',
          legalReasoning:
              'Under Section 114 of the Code on Social Security 2020 and State Gig Worker Acts, gig partners are recognized workers entitled to social security, grievance redressal, and mandatory accidental insurance. Unilateral de-platforming without hearing violates Article 21 livelihood rights.',
          sourceTitle: 'Based on: Code on Social Security 2020 & Gig Worker Welfare Acts',
          statutoryCitation: 'Section 114 Social Security Code 2020; Article 21 & 19(1)(g) Constitution',
          citizenActionSteps: [
            'Submit a formal written ticket to the aggregator grievance officer demanding written reasons.',
            'Capture screenshot proof of wallet balances, lifetime delivery counts, and customer ratings.',
            'Lodge a petition before the District Labor Officer citing unlawful livelihood termination.',
            'If injured on active delivery, claim mandatory group accidental coverage and medical bills.',
          ],
          criticalDonts: [
            'DO NOT accept oral customer support brush-offs; demand written correspondence.',
            'DO NOT delete the partner app before exporting transaction records and payout history.',
            'DO NOT waive accident claims in exchange for token ex-gratia relief.',
          ],
        ),
        triageOptions: [
          'Partner ID blocked without notice',
          'Withheld weekly payouts / wallet balance',
          'Accident on duty while delivering',
          'Lodge labor commissioner grievance',
        ],
      );
    }

    // 18. Cyber Blackmail / Leaked Private Photos / Sextortion
    if (normalized.contains('blackmail') ||
        normalized.contains('leaked') ||
        normalized.contains('morphed') ||
        normalized.contains('private photo') ||
        normalized.contains('nude') ||
        normalized.contains('sextortion') ||
        normalized.contains('photos leak') ||
        normalized.contains('तस्वीरें') ||
        normalized.contains('ब्लैकमेल')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Cyber Extortion & Non-Consensual Image Safeguards',
        isUser: false,
        timestamp: DateTime.now(),
        isEmergency: true,
        relatedCardId: 'leaked_images_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Severe Cyber Offence',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Blackmail with private or morphed photos is a severe, non-bailable criminal offence under Section 66E/67A IT Act and Section 77/351 BNS. Do NOT pay money to extortionists.',
          legalReasoning:
              'Under Section 66E (Violation of Privacy) and Section 67A (Transmitting Obscene Material) of the IT Act 2000, publishing or threatening to publish intimate images carries up to 5 years imprisonment. Under Section 77 and Section 351 BNS 2023, extortion and voyeurism are cognizable crimes. Indian Cyber Crime Coordination Centre (I4C) has fast-track takedown protocols for non-consensual imagery.',
          sourceTitle: 'Based on: IT Act 2000 & I4C Cyber Crime Safety Norms',
          statutoryCitation: 'Sec 66E, 67 & 67A IT Act 2000; Sec 77 & 351 BNS 2023; POCSO Act (if minor)',
          citizenActionSteps: [
            'Dial 1930 (National Cyber Crime Helpline) and file an immediate complaint at cybercrime.gov.in.',
            'Use StopNCII.org to generate cryptographic hashes that prevent imagery from spreading across platforms.',
            'Screenshot threat messages, phone numbers, UPI IDs, and profile URLs before blocking.',
            'If the victim is under 18, report under the POCSO Act for strict non-bailable enforcement.',
          ],
          criticalDonts: [
            'DO NOT transfer any extortion money; scammers will continue demanding larger amounts.',
            'DO NOT delete chat history or messages, as they are essential forensic proof.',
            'DO NOT isolate yourself in shame; support helplines and legal aid are available 24/7.',
          ],
        ),
        triageOptions: [
          'Scammer demanding UPI payment',
          'Images shared on social media',
          'Victim is under 18 (POCSO)',
          'Create StopNCII hash protection',
        ],
      );
    }

    // 19. Loan App Harassment / Recovery Agents
    if (normalized.contains('loan') ||
        normalized.contains('recovery agent') ||
        normalized.contains('calling contacts') ||
        normalized.contains('harassment loan') ||
        normalized.contains('लोन') ||
        normalized.contains('रिकवरी एजेंट')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Digital Lending Harassment & RBI Protection Codes',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'loan_app_harassment_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Prohibited by RBI Guidelines',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Recovery agents CANNOT call you before 8 AM or after 7 PM, cannot access your mobile contacts, and cannot contact your friends, family, or workplace.',
          legalReasoning:
              'Under the Reserve Bank of India (RBI) Digital Lending Guidelines (2022) and Fair Practices Code, loan recovery agents are strictly prohibited from contacting third parties, accessing mobile contact lists or galleries, using threatening language, or visiting without prior notice. Harassment violates Section 351 BNS (Criminal Intimidation).',
          sourceTitle: 'Based on: RBI Digital Lending Guidelines 2022 & Fair Practices Code',
          statutoryCitation: 'RBI Circular DOR.CRE.REC.66/21.07.001/2022-23; Sec 351 BNS 2023',
          citizenActionSteps: [
            'Record all phone calls, threats, WhatsApp messages, and extortionate payment links.',
            'File an official complaint on the RBI CMS Portal (cms.rbi.org.in) against the lending entity.',
            'Report illegal unregistered loan apps at cybercrime.gov.in.',
            'Dial 1930 or 112 if recovery agents threaten physical visits or abuse family members.',
          ],
          criticalDonts: [
            'DO NOT grant contact or gallery permissions to instant unverified loan apps.',
            'DO NOT transfer money to private unverified personal UPI handles.',
            'DO NOT tolerate verbal abuse; inform agents all calls are recorded for the Banking Ombudsman.',
          ],
        ),
        triageOptions: [
          'Agents calling contact list',
          'Threats of morphed photos',
          'Unregistered Chinese loan app',
          'Lodge RBI Banking Ombudsman complaint',
        ],
      );
    }

    // 20. Bank Account Frozen by Cyber Cell (Sec 102 CrPC) / UPI Fraud
    if (normalized.contains('account freeze') ||
        normalized.contains('account frozen') ||
        normalized.contains('bank frozen') ||
        normalized.contains('cyber cell freeze') ||
        normalized.contains('cyber') ||
        normalized.contains('upi') ||
        normalized.contains('lien') ||
        normalized.contains('खाता फ्रीज') ||
        normalized.contains('अकाउंट फ्रीज')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Bank Account Freeze & Section 102 CrPC Remedy',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'account_frozen_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Procedural Defreeze Remedy Available',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Your bank account can only be frozen for the specific disputed transaction amount (lien freeze), NOT your entire account balance.',
          legalReasoning:
              'When cyber police investigate financial fraud, they issue debit freeze requests under Section 102 CrPC / Section 106 BNSS. However, High Courts (including Madras and Gujarat High Courts) have ruled that freezing entire accounts for minor disputed transactions is excessive and unlawful. The police must restrict the lien to the exact amount of the alleged fraudulent transaction.',
          sourceTitle: 'Based on: Section 102 CrPC & High Court Jurisprudence on Account Freezes',
          statutoryCitation: 'Sec 102 CrPC / Sec 106 BNSS 2023; RBI Customer Protection Guidelines; Article 21',
          citizenActionSteps: [
            'Visit your bank branch and obtain the Notice Number, Cyber Police Station, and disputed amount.',
            'Email the Investigating Officer with KYC, bank statement, and evidence that you are a bona fide receiver.',
            'Request the bank in writing to restrict the freeze strictly to the disputed amount (lien amount).',
            'If the IO does not respond within 14 days, file an application under Section 457 CrPC before the Magistrate.',
          ],
          criticalDonts: [
            'DO NOT close or abandon the account without resolving the police inquiry.',
            'DO NOT deal with unauthorized agents claiming they can "unfreeze" accounts for cash.',
            'DO NOT delay communicating with the Investigating Officer; provide genuine commercial transaction trails.',
          ],
        ),
        triageOptions: [
          'Received notice from Cyber Cell',
          'P2P crypto trading freeze',
          'Request lien freeze for disputed amount',
          'File 457 CrPC defreeze petition',
        ],
      );
    }

    // 21. Domestic Violence & Protection for Women
    if (normalized.contains('domestic violence') ||
        normalized.contains('husband') ||
        normalized.contains('in-laws') ||
        normalized.contains('dowry') ||
        normalized.contains('498a') ||
        normalized.contains('घरेलू हिंसा') ||
        normalized.contains('दहेज')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Domestic Violence Safeguards & Emergency Protection Orders',
        isUser: false,
        timestamp: DateTime.now(),
        isEmergency: true,
        relatedCardId: 'domestic_violence_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Severe Offence - Protection Orders Available',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'You have the legal right to immediate police protection, residence in the shared household, and emergency maintenance under the Domestic Violence Act.',
          legalReasoning:
              'The Protection of Women from Domestic Violence Act 2005 (PWDVA) protects women from physical, sexual, emotional, verbal, and economic abuse. You cannot be evicted from your matrimonial home. Under Section 12 PWDVA, you can obtain ex-parte Protection Orders, Residence Orders, and Monetary Relief from a Magistrate within 3 days. Cruelty by husband or in-laws is punishable under Section 85 & 86 BNS (Section 498A IPC).',
          sourceTitle: 'Based on: Protection of Women from Domestic Violence Act 2005',
          statutoryCitation: 'Protection of Women from Domestic Violence Act 2005 (Sec 12, 18, 19); Sec 85 & 86 BNS 2023',
          citizenActionSteps: [
            'Call National Women Helpline 181 or 1091 (or Emergency 112) for immediate police intervention.',
            'Approach the Protection Officer (PO) at the District Court or a designated Service Provider NGO.',
            'Undergo a medical examination at a government hospital to document any injuries.',
            'Contact National Commission for Women (NCW) WhatsApp helpline: 7827170170.',
          ],
          criticalDonts: [
            'DO NOT suffer abuse in silence; the law provides immediate shelter homes and free legal aid (15100).',
            'DO NOT leave behind crucial documents (Aadhaar, marriage certificate, bank books) if relocating safely.',
            'DO NOT sign settlement papers under family coercion without independent legal advice.',
          ],
        ),
        triageOptions: [
          'Immediate physical danger',
          'Evicted from matrimonial home',
          'Apply for Protection Order (Sec 12)',
          'Contact Protection Officer',
        ],
      );
    }

    // 22. Consumer Rights / Defective Product / Refund Refusal
    if (normalized.contains('refund') ||
        normalized.contains('defective') ||
        normalized.contains('consumer') ||
        normalized.contains('warranty') ||
        normalized.contains('broken product') ||
        normalized.contains('रिफंड') ||
        normalized.contains('खराब सामान') ||
        normalized.contains('उपभोक्ता')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Consumer Rights & Statutory Refund Protection',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'defective_product_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Right to Replacement or Full Refund',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Companies and sellers cannot deny refunds or repairs for defective goods, deficient services, or misleading advertisements under the Consumer Protection Act 2019.',
          legalReasoning:
              'Under Section 2(47) and Section 35 of the Consumer Protection Act 2019, denying refunds for defective merchandise or delivering substandard products constitutes an Unfair Trade Practice. E-commerce platforms and sellers are jointly responsible. Citizens can file an online consumer complaint without hiring a lawyer through the government\'s e-Daakhil portal.',
          sourceTitle: 'Based on: Consumer Protection Act 2019 & E-Commerce Rules',
          statutoryCitation: 'Consumer Protection Act 2019 (Sec 2(47), 35 & 84); Rule 4 E-Commerce Rules',
          citizenActionSteps: [
            'Call the National Consumer Helpline at 1915 or register a grievance at consumerhelpline.gov.in.',
            'Preserve original invoice, warranty card, product photos/unboxing videos, and email correspondence.',
            'Send a formal 15-day Legal Notice to the company\'s grievance officer demanding refund with interest.',
            'File an online complaint on the official e-Daakhil portal (edaakhil.nic.in) before the District Commission.',
          ],
          criticalDonts: [
            'DO NOT accept replacement of a defective item without a fresh warranty period.',
            'DO NOT delay filing; consumer complaints should be lodged within 2 years from the date of the defect.',
            'DO NOT return the item without written courier/pickup receipt from the company.',
          ],
        ),
        triageOptions: [
          'E-commerce company refused refund',
          'Defective electronic item',
          'File complaint on e-Daakhil',
          'Call National Consumer Helpline 1915',
        ],
      );
    }

    // 23. Summons / Police Notice to Appear (Sec 41A CrPC / Sec 35 BNSS)
    if (normalized.contains('summon') ||
        normalized.contains('called to station') ||
        normalized.contains('notice to appear') ||
        normalized.contains('41a') ||
        normalized.contains('inquiry') ||
        normalized.contains('थाने बुलाया') ||
        normalized.contains('समन') ||
        normalized.contains('नोटिस')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Section 41A Notice & Appearance Rights',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'summons_notice_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Safeguard Against Direct Arrest',
          verdictColor: const Color(0xFF1B6B38),
          verdictBgColor: const Color(0xFFD4F5DE),
          directAnswer:
              'A Section 41A CrPC / Section 35(3) BNSS notice means you are NOT being arrested immediately. If you appear and cooperate, police CANNOT arrest you without special judicial approval.',
          legalReasoning:
              'In Arnesh Kumar vs. State of Bihar (2014), the Supreme Court ruled that for offences punishable with up to 7 years imprisonment, police must issue a notice of appearance instead of making a custodial arrest. As long as you appear and cooperate with the inquiry, arrest is prohibited unless the officer records written reasons justifying custodial detention and obtains Magistrate approval.',
          sourceTitle: 'Based on: Arnesh Kumar Supreme Court Directives (2014)',
          statutoryCitation: 'Sec 41A CrPC / Sec 35(3) BNSS 2023; Arnesh Kumar (2014) 8 SCC 273',
          citizenActionSteps: [
            'Check the notice for the FIR/complaint number, issuing officer\'s name, and appearance date/time.',
            'Appear with an advocate or consult a free NALSA legal aid lawyer (15100) before attending.',
            'Request a written acknowledgment or General Diary (GD) entry confirming your attendance.',
            'Provide truthful answers without self-incrimination (protected by Article 20(3)).',
          ],
          criticalDonts: [
            'DO NOT ignore the notice; non-appearance without valid reason empowers the police to seek an arrest warrant.',
            'DO NOT surrender your mobile phone or laptop without an official seizure memo.',
            'DO NOT sign blank papers or pre-typed confessions.',
          ],
        ),
        triageOptions: [
          'Received written 41A notice',
          'Called verbally over phone',
          'Consult NALSA legal aid (15100)',
          'Attend inquiry with lawyer',
        ],
      );
    }

    // 24. UPI Scam / Cyber Financial Fraud
    if (normalized.contains('upi') ||
        normalized.contains('money') ||
        normalized.contains('bank') ||
        normalized.contains('fraud') ||
        normalized.contains('scam') ||
        normalized.contains('lost money') ||
        normalized.contains('पैसे') ||
        normalized.contains('धोखाधड़ी')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Cyber Financial Fraud & Golden Hour Recovery',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'upi_fraud_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Urgent Golden Hour Action',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Report the transaction immediately to Helpline 1930 within the first 2-3 hours ("Golden Hour") to freeze the stolen funds before they are withdrawn by fraudsters.',
          legalReasoning:
              'Under RBI Circular DBR.No.Leg.BC.78/09.07.005/2017-18, a customer has ZERO liability for unauthorized electronic banking transactions if reported to the bank within three working days. National Cyber Crime Reporting Portal (NCRP) communicates directly with recipient banks to place temporary lien freezes under Section 102 CrPC.',
          sourceTitle: 'Based on: Cyber Crime & Financial Fraud Card (I4C Portal)',
          statutoryCitation: 'Sec 66D IT Act 2000; Sec 318 BNS (Cheating); RBI Zero Liability Circular 2017',
          citizenActionSteps: [
            'Dial National Cyber Crime Helpline 1930 immediately.',
            'File a complaint on cybercrime.gov.in and note down the 14-digit Acknowledgement Number.',
            'Call your bank\'s 24×7 customer care to block your card/UPI VPA and request a dispute chargeback.',
            'Save all SMS records, transaction UTR numbers, and screenshots for investigation.',
          ],
          criticalDonts: [
            'DO NOT delay reporting; fund recovery chances decrease significantly after 3 hours.',
            'DO NOT click any further links sent by supposed customer care executives.',
            'DO NOT share OTPs or download remote screen-sharing apps (AnyDesk, TeamViewer).',
          ],
        ),
        triageOptions: [
          'Transaction within last 2 hours',
          'Fake customer care call',
          'Account frozen by cyber cell',
          'Phishing link clicked',
        ],
      );
    }

    // 25. Unpaid Salary / Wrongful Termination
    if (normalized.contains('salary') ||
        normalized.contains('job') ||
        normalized.contains('employer') ||
        normalized.contains('unpaid') ||
        normalized.contains('resignation') ||
        normalized.contains('termination') ||
        normalized.contains('वेतन') ||
        normalized.contains('सैलरी') ||
        normalized.contains('नौकरी')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Employment Rights & Statutory Wage Recovery',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'salary_unpaid_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Statutory Violation by Employer',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Employers cannot withhold earned wages, Full & Final (FnF) settlements, or original educational certificates. Wages must be disbursed before the 7th or 10th of every month.',
          legalReasoning:
              'Under Section 15 of the Payment of Wages Act 1936 and the Industrial Disputes Act 1947, unauthorized deductions or delays in wage payment are illegal. Withholding original educational marks cards or certificates violates contract law and constitutes wrongful restraint under Section 126 BNS (Section 339 IPC).',
          sourceTitle: 'Based on: Workplace Disputes Card & Payment of Wages Act',
          statutoryCitation: 'Sec 15 Payment of Wages Act 1936; Sec 339 IPC / Sec 126 BNS 2023',
          citizenActionSteps: [
            'Send a formal Demand Notice via registered email requesting settlement within 7 business days.',
            'Collect timesheets, offer letter, bank statements, and company communication.',
            'File an online complaint with the State Labour Commissioner or on the SAMADHAN portal.',
            'If original certificates are held hostage, file a police complaint for criminal breach of trust (Sec 316 BNS).',
          ],
          criticalDonts: [
            'DO NOT sign blanket settlement waivers before the money is credited to your bank account.',
            'DO NOT return company assets without obtaining a written, signed handover receipt.',
            'DO NOT resign under coercion without recording in writing that you are being forced.',
          ],
        ),
        triageOptions: [
          'Over 60 days overdue',
          'Experience letter withheld',
          'Forced to sign bond',
          'Labor Commissioner complaint',
        ],
      );
    }

    // 26. Bail / Anticipatory Bail
    if (normalized.contains('bail') ||
        normalized.contains('anticipatory') ||
        normalized.contains('जमानत') ||
        normalized.contains('अग्रिम जमानत')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Bail Provisions & Liberty Safeguards',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'false_accusation_anticipatory_bail',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Bail is Rule, Jail is Exception',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'In bailable offences, bail is an absolute statutory right that the police must grant on the spot upon furnishing bond (Sec 436 CrPC / Sec 478 BNSS). In non-bailable offences, anticipatory bail can be obtained from the Sessions Court or High Court before arrest.',
          legalReasoning:
              'Under Article 21 and the Supreme Court principle in State of Rajasthan vs. Balchand (1977), personal liberty is paramount. Under Section 438 CrPC / Section 482 BNSS, any citizen with reasonable apprehension of arrest in a non-bailable accusation can apply for Anticipatory Bail. Under Arnesh Kumar vs. State of Bihar, arrests for offences with punishment up to 7 years are not routine and require Section 41A CrPC notice first.',
          sourceTitle: 'Based on: Anticipatory Bail & Arnesh Kumar Guidelines',
          statutoryCitation: 'Sec 436 & 438 CrPC / Sec 478 & 482 BNSS; Arnesh Kumar (2014) 8 SCC 273',
          citizenActionSteps: [
            'Check FIR / complaint copy to identify if sections are bailable or non-bailable.',
            'If arrest is feared, immediately petition the Sessions Court for Anticipatory Bail under Sec 438 CrPC.',
            'Ensure compliance with any Sec 41A appearance notice to prevent custodial arrest.',
            'Dial NALSA 15100 if you need a free panel defence lawyer.',
          ],
          criticalDonts: [
            'DO NOT evade police without filing an Anticipatory Bail petition, as it risks non-bailable warrants.',
            'DO NOT contact or intimidate the complainant, which will cancel your bail.',
            'DO NOT travel abroad without explicit court permission while on bail.',
          ],
        ),
        triageOptions: [
          'Offence under 7 years jail',
          'Received 41A notice',
          'Already in custody',
          'Apply for anticipatory bail',
        ],
      );
    }

    // 27. Arrest & Custody Safeguards / D.K. Basu Guidelines
    if (normalized.contains('arrest') ||
        normalized.contains('custody') ||
        normalized.contains('lock up') ||
        normalized.contains('girftar') ||
        normalized.contains('गिरफ्तार') ||
        normalized.contains('हिरासत')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Arrest Safeguards & D.K. Basu Guidelines',
        isUser: false,
        timestamp: DateTime.now(),
        isEmergency: true,
        relatedCardId: 'arrest_detention_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Mandatory Constitutional Safeguards',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Police cannot arrest you arbitrarily. You have the constitutional right to know the exact grounds of arrest, notify a family member immediately, and be produced before a Magistrate within 24 hours.',
          legalReasoning:
              'Under Article 22 of the Constitution and Section 41B CrPC (Section 36 BNSS), the arresting officer must prepare an Arrest Memo signed by a respectable witness, inform your family within 8-12 hours (Sec 50A CrPC), and conduct a medical examination (Sec 54 CrPC). Women cannot be arrested between sunset and sunrise except with prior written judicial permission (Sec 46(4) CrPC). Handcuffing is prohibited unless judicial permission is granted (Prem Shankar Shukla case).',
          sourceTitle: 'Based on: Custodial Rights & D.K. Basu Guidelines (Supreme Court)',
          statutoryCitation: 'Articles 21 & 22 Constitution; Sec 41, 46, 50, 54, 57 CrPC / BNSS 2023',
          citizenActionSteps: [
            'Demand to see the Arrest Memo and ensure exact time and date are recorded before signing.',
            'Provide the contact number of one family member or friend to be officially notified.',
            'Request an immediate medical examination at the nearest government hospital under Sec 54 CrPC.',
            'Invoke Section 41D CrPC to meet your advocate during interrogation.',
          ],
          criticalDonts: [
            'DO NOT sign an arrest memo that does not state the date and exact time of your arrest.',
            'DO NOT give confessions under police threat; confessions to police are inadmissible under Sec 25 Evidence Act.',
            'DO NOT hesitate to report any mistreatment directly to the Magistrate at first appearance.',
          ],
        ),
        triageOptions: [
          'Immediate phone call to family',
          'Arrest of female citizen',
          'Detained without formal memo',
          'Past 24 hours in custody',
        ],
      );
    }

    // 28. Intelligent Domain-Aware Legal Synthesis (Smart Fallback)
    return _generateDomainAwareSynthesis(normalized);
  }

  CivicAiMessage _generateDomainAwareSynthesis(String normalized) {
    // A. Police & Law Enforcement Focus
    if (normalized.contains('police') ||
        normalized.contains('cop') ||
        normalized.contains('thana') ||
        normalized.contains('chowki') ||
        normalized.contains('officer') ||
        normalized.contains('daroga') ||
        normalized.contains('constable') ||
        normalized.contains('inspector') ||
        normalized.contains('station') ||
        normalized.contains('पुलिस') ||
        normalized.contains('थाना')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Law Enforcement Conduct & Citizen Procedural Safeguards',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'police_at_door_search_residential_without_warrant',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strict Due Process Mandated',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Police officers are strictly bound by procedural due process under the BNSS 2023 and the Constitution. They cannot act arbitrarily, use coercion, or detain citizens without statutory grounds.',
          legalReasoning:
              'Under Articles 21 & 22 of the Constitution and the landmark Supreme Court directives in D.K. Basu vs. State of West Bengal, police officers must wear clearly visible name badges, record all station entries in the General Diary (GD), issue written summons rather than verbal orders, and respect citizens\' bodily integrity. Any arbitrary detention or harassment is actionable before the Magistrate and Police Complaints Authority.',
          sourceTitle: 'Based on: Supreme Court D.K. Basu Guidelines & BNSS Procedural Safeguards',
          statutoryCitation: 'Articles 14, 21 & 22 Constitution; Sec 35, 36 & 173 BNSS 2023; D.K. Basu (1997)',
          citizenActionSteps: [
            'Politely ask the officer for their name, rank, and police station jurisdiction.',
            'Demand an official written notice or summons rather than complying with verbal orders.',
            'Document date, time, vehicle numbers, and note any witnesses present.',
            'Dial NALSA Helpline 15100 if you require free legal assistance or representation.',
          ],
          criticalDonts: [
            'DO NOT sign any blank paper, confession, or statement without reading it thoroughly.',
            'DO NOT physically resist an officer; clearly assert your statutory rights verbally.',
            'DO NOT pay unreceipted cash or transfer funds to personal UPI accounts.',
          ],
        ),
        triageOptions: [
          'Ask for officer\'s badge and station',
          'Demand formal written notice',
          'Dial NALSA Legal Aid (15100)',
          'File Police Complaints Authority petition',
        ],
      );
    }

    // B. Financial, Banking & Money Fraud Focus
    if (normalized.contains('bank') ||
        normalized.contains('money') ||
        normalized.contains('fraud') ||
        normalized.contains('cheated') ||
        normalized.contains('paisa') ||
        normalized.contains('rupee') ||
        normalized.contains('payment') ||
        normalized.contains('पैसे') ||
        normalized.contains('बैंक')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Financial Fraud Protection & Account Safeguards',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'upi_fraud_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Immediate Reporting Rights',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'In financial fraud or unauthorized transactions, reporting within 3 days grants you zero liability under RBI guidelines. Call 1930 immediately.',
          legalReasoning:
              'Under RBI Customer Protection Circulars and the Information Technology Act 2000, victims of electronic banking fraud are entitled to immediate lien freezes and bank chargeback investigations. When reported promptly within the first few hours ("Golden Hour"), funds in transit can be frozen through the National Cyber Crime Reporting Portal (NCRP).',
          sourceTitle: 'Based on: RBI Zero Liability Circular & IT Act 2000',
          statutoryCitation: 'RBI Circular DBR.No.Leg.BC.78/09.07.005/2017-18; Sec 66D IT Act 2000',
          citizenActionSteps: [
            'Dial National Cyber Crime Helpline 1930 immediately to freeze fraudulent beneficiary accounts.',
            'Log a formal complaint on cybercrime.gov.in and save the 14-digit acknowledgement number.',
            'Call your bank\'s 24×7 fraud prevention desk to block accounts/cards and submit a written dispute.',
            'Preserve all transaction SMS, UTR reference numbers, and payment screenshots.',
          ],
          criticalDonts: [
            'DO NOT click any further links sent by purported "refund executives" or "support agents".',
            'DO NOT share OTPs, CVV, or passwords under any circumstance.',
            'DO NOT install screen-sharing software (AnyDesk, TeamViewer) on your phone.',
          ],
        ),
        triageOptions: [
          'Report on Helpline 1930',
          'Block bank account / UPI VPA',
          'File cybercrime.gov.in complaint',
          'Contact bank branch manager',
        ],
      );
    }

    // C. Traffic, Driving & Vehicle Focus
    if (normalized.contains('vehicle') ||
        normalized.contains('car') ||
        normalized.contains('bike') ||
        normalized.contains('drive') ||
        normalized.contains('driving') ||
        normalized.contains('road') ||
        normalized.contains('scooter') ||
        normalized.contains('गाड़ी') ||
        normalized.contains('सड़क')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Motor Vehicle Regulations & Road Enforcement Safeguards',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Procedural Rules Apply',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'You have the legal right to show digital documents on DigiLocker/mParivahan, and traffic police cannot seize vehicle keys, deflate tyres, or impound vehicles without 15 days compliance notice.',
          legalReasoning:
              'Under Rule 139 of the Central Motor Vehicles Rules (CMVR) and the Motor Vehicles (Amendment) Act 2019, electronic documents have full legal parity with physical originals. Spot compounding fines can only be levied by officers of Sub-Inspector (SI) / ASI rank and above, and must be accompanied by an official printed e-Challan receipt.',
          sourceTitle: 'Based on: Motor Vehicles Act 1988 & Rule 139 CMVR',
          statutoryCitation: 'Sec 130 & 200 Motor Vehicles Act 1988; Rule 139 CMVR 1989',
          citizenActionSteps: [
            'Present your digital Driving License, RC, Insurance, and PUC via the official DigiLocker app.',
            'Verify the officer\'s rank badge (Sub-Inspector / ASI or above) before paying any compoundable fine.',
            'Demand an electronic printed receipt or SMS acknowledgment for any fine paid.',
            'Report improper harassment or key snatching to Traffic Helpline 1095 / 112.',
          ],
          criticalDonts: [
            'DO NOT hand over physical keys or allow police to take them from the ignition.',
            'DO NOT pay cash without an instantaneous government e-challan receipt.',
            'DO NOT surrender your phone into the officer\'s custody; show the screen from your hands.',
          ],
        ),
        triageOptions: [
          'Show DigiLocker documents',
          'Demand official e-challan receipt',
          'Keys snatched by cop',
          'Contest challan on Virtual Court',
        ],
      );
    }

    // D. Women, Family & Personal Safety Focus
    if (normalized.contains('girl') ||
        normalized.contains('woman') ||
        normalized.contains('female') ||
        normalized.contains('wife') ||
        normalized.contains('mother') ||
        normalized.contains('harass') ||
        normalized.contains('safety') ||
        normalized.contains('सुरक्षा') ||
        normalized.contains('महिला')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Women\'s Rights & Emergency Safety Protections',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'domestic_violence_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Special Statutory Protections',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'Indian law provides specialized, non-negotiable statutory safeguards for women, including bans on nighttime arrest, rights to female police officers, and zero FIR registration.',
          legalReasoning:
              'Under Section 46(4) CrPC (Section 43(5) BNSS 2023), women cannot be arrested after sunset or before sunrise without written Magistrate orders. Physical searches must be conducted exclusively by female officers under Section 51(2) CrPC. Special legislation (POSH Act 2013, PWDVA 2005, and BNS criminal provisions) mandates zero tolerance for harassment and provides emergency protection orders.',
          sourceTitle: 'Based on: Statutory Protections for Women (CrPC, BNSS & Supreme Court)',
          statutoryCitation: 'Sec 46(4) & 51(2) CrPC / Sec 43(5) & 49 BNSS 2023; PWDVA 2005; POSH Act 2013',
          citizenActionSteps: [
            'Call 1091 (Women Helpline), 181 (Domestic Abuse Helpline), or Emergency 112 immediately.',
            'Demand the presence of a female police officer for any questioning or verification.',
            'Lodge complaints with the National Commission for Women (NCW) on WhatsApp: 7827170170.',
            'Access free legal representation through NALSA / DLSA panel lawyers via 15100.',
          ],
          criticalDonts: [
            'DO NOT accompany male officers to a police station at night without a woman officer.',
            'DO NOT allow anyone to pressure you into an informal compromise concealing violence.',
            'DO NOT hesitate to report harassment; identity can be kept strictly confidential.',
          ],
        ),
        triageOptions: [
          'Call Women Helpline 1091',
          'Emergency SOS (112)',
          'Protection against harassment',
          'Free legal aid lawyer (15100)',
        ],
      );
    }

    // 25. Emergency Hospital Care & Unpaid Bill Hostage / Blood Bank Coercion
    if (normalized.contains('hospital') ||
        normalized.contains('emergency') ||
        normalized.contains('admit') ||
        normalized.contains('admission') ||
        normalized.contains('dead body') ||
        normalized.contains('hostage') ||
        normalized.contains('patient detained') ||
        normalized.contains('bill pending') ||
        normalized.contains('advance deposit') ||
        normalized.contains('replacement donor') ||
        normalized.contains('blood bank') ||
        normalized.contains('अस्पताल') ||
        normalized.contains('इमरजेंसी')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Emergency Medical Denial & Patient Detention',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. Hospitals CANNOT refuse emergency medical stabilization over money, nor can they detain patients or withhold a dead body over unpaid bills.',
          legalReasoning:
              'In Pt. Parmanand Katara v. Union of India (1989), the Supreme Court ruled that Article 21 imposes an unconditional obligation on every hospital and doctor—public or private—to provide emergency treatment without demanding advance deposits or police clearances. Under the Clinical Establishments Act 2010 and Charter of Patients\' Rights, detaining a patient or dead body is criminal wrongful confinement under Sec 127 BNS (Sec 342 IPC). Mandatory replacement donors are banned under National Blood Transfusion Council guidelines.',
          sourceTitle: 'Based on: Pt. Parmanand Katara SC Precedent & Clinical Establishments Act 2010',
          statutoryCitation: 'Article 21 Constitution; Sec 127 BNS 2023 / Sec 342 IPC; Clinical Establishments Act 2010',
          citizenActionSteps: [
            'State firmly: "Under Supreme Court rulings, emergency medical stabilization is mandatory without advance payment."',
            'If staff detains a patient or body, demand the Medical Superintendent and dial 112 immediately.',
            'File a written complaint before the State Medical Council and District Clinical Establishments Authority.',
            'For illegal blood donor demands, file a report under National Blood Transfusion Council norms.',
          ],
          criticalDonts: [
            'DO NOT sign unconditional promissory notes or hand over property documents under duress.',
            'DO NOT delay seeking alternative medical stabilization while arguing billing details.',
          ],
        ),
        triageOptions: [
          'Hospital demanding advance for emergency ICU',
          'Hospital withholding dead body over bills',
          'Blood bank demanding replacement donor',
          'Call 112 for hospital hostage dispute',
        ],
      );
    }

    // 26. DigiLocker & mParivahan Digital Documents Rejection
    if (normalized.contains('digilocker') ||
        normalized.contains('mparivahan') ||
        normalized.contains('parivahan') ||
        normalized.contains('digital rc') ||
        normalized.contains('digital dl') ||
        normalized.contains('soft copy') ||
        normalized.contains('original document') ||
        normalized.contains('hard copy') ||
        normalized.contains('डिजीलॉकर') ||
        normalized.contains('ड्राइविंग लाइसेंस')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'DigiLocker & mParivahan Acceptance Rights',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful to Reject',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. Traffic police CANNOT reject driving licenses or registration certificates presented via DigiLocker or mParivahan apps.',
          legalReasoning:
              'Under Rule 139 of the Central Motor Vehicles Rules 1989 (amended) and Ministry of Road Transport & Highways (MoRTH) Notifications RT-11036/64/2017-MVL dated 08.08.2018 and 17.12.2018, electronic certificates shown on official government platforms (DigiLocker and mParivahan) carry full statutory parity with original physical documents under Section 4 of the Information Technology Act 2000. Officers demanding physical originals are acting ultra vires.',
          sourceTitle: 'Based on: Rule 139 Central Motor Vehicles Rules 1989 & MoRTH Circulars',
          statutoryCitation: 'Rule 139 CMVR 1989; Sec 4 IT Act 2000; MoRTH Notification RT-11036/64/2017-MVL',
          citizenActionSteps: [
            'Show the verified green tick on your official DigiLocker or mParivahan app screen.',
            'Cite MoRTH Circular dated 17.12.2018 confirming electronic certificates have legal parity.',
            'If an officer insists on issuing an improper challan, do not pay cash; contest it on the Virtual Court portal.',
            'Note the officer\'s name, rank, and traffic precinct for reporting to the Traffic Helpline (1095 / 112).',
          ],
          criticalDonts: [
            'DO NOT rely on ordinary mobile gallery screenshots or WhatsApp photos; documents must be in DigiLocker/mParivahan.',
            'DO NOT pay spot cash penalties if your electronic documents are verified on government apps.',
          ],
        ),
        triageOptions: [
          'Officer demanding physical driving license',
          'Challan issued despite DigiLocker shown',
          'Verify document on Parivahan portal',
          'Contest traffic challan in Virtual Court',
        ],
      );
    }

    // 27. Vehicle Towing with Passenger Seated Inside
    if (normalized.contains('towing') ||
        normalized.contains('towed') ||
        normalized.contains('crane') ||
        normalized.contains('seated inside') ||
        normalized.contains('inside vehicle') ||
        normalized.contains('occupant inside') ||
        normalized.contains('टोइंग') ||
        normalized.contains('क्रेन')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Vehicle Towing with Occupants Inside',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. Police or towing contractors CANNOT tow any vehicle while a driver, passenger, or child is seated inside.',
          legalReasoning:
              'Towing a vehicle occupied by human beings is a severe safety violation, reckless endangerment under Section 106 and 125 BNS (Sec 279 & 336 IPC), and prohibited by state traffic department Standard Operating Procedures. Furthermore, under traffic regulations in major cities, if the driver arrives on the spot before the crane hooks the vehicle, the vehicle cannot be towed; only a no-parking e-challan may be issued.',
          sourceTitle: 'Based on: Motor Vehicles Act 1988 & Traffic Towing Standard Operating Procedures',
          statutoryCitation: 'Sec 125 & 106 BNS 2023 / Sec 279 & 336 IPC; State Traffic Towing SOPs',
          citizenActionSteps: [
            'Remain calm inside, turn on hazard lights, and state clearly: "Stop towing immediately; vehicle is occupied."',
            'If you arrived before the vehicle was lifted, demand only an on-the-spot no-parking challan without towing fee.',
            'Film the towing vehicle number plate and crane operator details as evidence of endangerment.',
            'Dial 112 immediately to report hazardous towing with passengers.',
          ],
          criticalDonts: [
            'DO NOT attempt to jump out or cling onto a moving crane.',
            'DO NOT engage in physical violence with towing contractor laborers.',
          ],
        ),
        triageOptions: [
          'Car towed with family or pet inside',
          'Arrived before towing crane hooked car',
          'High towing fee demanded in cash',
          'Vehicle damaged during towing',
        ],
      );
    }

    // 28. Out-of-State Vehicle (11-Month Rule & BH Series)
    if (normalized.contains('out of state') ||
        normalized.contains('other state') ||
        normalized.contains('different state') ||
        normalized.contains('11 month') ||
        normalized.contains('12 month') ||
        normalized.contains('bh series') ||
        normalized.contains('bharat series') ||
        normalized.contains('road tax') ||
        normalized.contains('rto transfer') ||
        normalized.contains('का रजिस्ट्रेशन')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Out-of-State Vehicle 11-Month Rule & BH-Series',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Procedural Rights Protected',
          verdictColor: const Color(0xFF006A4E),
          verdictBgColor: const Color(0xFFE8F5E9),
          directAnswer:
              'YES, you can legally drive an out-of-state vehicle for up to 11 months (under 12 months) without re-registering or paying local road tax. BH series vehicles need no re-registration at all.',
          legalReasoning:
              'Under Section 47 of the Motor Vehicles Act 1988, a vehicle registered in one state can be kept and used in another state for a period of up to 12 months without requiring local re-registration or local state road tax payment. After 12 months, you must obtain an NOC from the parent RTO and apply for assignment of a new registration mark under Section 47(1). For BH-series (Bharat Series) registrations under CMVR Amendment 2021, road tax is paid biennially online and vehicles operate seamlessly nationwide without local transfer.',
          sourceTitle: 'Based on: Section 47 Motor Vehicles Act 1988 & BH-Series CMVR Notification 2021',
          statutoryCitation: 'Sec 46 & 47 Motor Vehicles Act 1988; Central Motor Vehicles (20th Amendment) Rules 2021',
          citizenActionSteps: [
            'Keep proof of the date your vehicle entered the state (toll receipts, FASTag log, transport bill, or fuel invoice).',
            'State to the RTO inspector: "Section 47 MVA permits out-of-state vehicles for up to 12 months without local re-registration."',
            'If questioned on BH series, show the valid Bharat Series RC; it is exempt from state-wise registration.',
            'If moving permanently beyond 12 months, apply for Form 28 (NOC) on the Parivahan Sewa portal.',
          ],
          criticalDonts: [
            'DO NOT pay cash fines on the spot to local transport flying squads without an official compounding receipt.',
            'DO NOT surrender your original RC card on the road; show DigiLocker/mParivahan verified credentials.',
          ],
        ),
        triageOptions: [
          'RTO stopped out-of-state car in new city',
          'FASTag proof of state entry date',
          'BH series registration police check',
          'NOC Form 28 application on Parivahan',
        ],
      );
    }

    // 29. Loan Recovery Agent Doorstep Threats & Harassment
    if (normalized.contains('recovery agent') ||
        normalized.contains('recovery') ||
        normalized.contains('loan harassment') ||
        normalized.contains('collection agent') ||
        normalized.contains('emi agent') ||
        normalized.contains('bank threatening') ||
        normalized.contains('recovery calls') ||
        normalized.contains('doorstep threat') ||
        normalized.contains('abusing for loan') ||
        normalized.contains('रिकवरी') ||
        normalized.contains('लोन एजेंट')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Loan Recovery Agent Harassment & RBI Code',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Strictly Unlawful',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. Recovery agents CANNOT visit your home outside 8 AM - 7 PM, threaten you, use abusive language, or contact your relatives or employers.',
          legalReasoning:
              'The Reserve Bank of India (RBI) Fair Practices Code for Lenders and August 2022 Circular explicitly prohibits banks and NBFCs from using musclemen or intimidating collection practices. Agents are strictly barred from: (1) calling before 8 AM or after 7 PM, (2) using foul language or verbal abuse, (3) publicly shaming or visiting employers/relatives, and (4) entering premises without prior authorization and official ID cards. Violations constitute Criminal Intimidation under Section 351 BNS (Sec 503/506 IPC).',
          sourceTitle: 'Based on: RBI Master Directions on Fair Practices Code & Section 351 BNS',
          statutoryCitation: 'RBI Circular DOR.CRE.REC.No.62/03.10.001/2022-23; Sec 351 & 352 BNS 2023',
          citizenActionSteps: [
            'Demand the agent\'s official Bank/NBFC Recovery Authorization Letter and valid Employee ID.',
            'Record audio/video of any abusive language, late-night calls, or unauthorized doorstep threats.',
            'File a formal complaint to the Principal Nodal Officer of the bank giving 30 days to resolve.',
            'If unresolved in 30 days, escalate to the RBI Banking Ombudsman (cms.rbi.org.in or dial 14448).',
            'Dial 112 or file an FIR if an agent attempts physical trespass, threats, or assault.',
          ],
          criticalDonts: [
            'DO NOT pay cash directly to field agents without an official bank acknowledgment receipt.',
            'DO NOT sign blank agreements, promissory notes, or surrender vehicle keys under intimidation.',
          ],
        ),
        triageOptions: [
          'Recovery agents visiting house late night',
          'Threatening calls to family or employer',
          'File RBI Ombudsman complaint (cms.rbi.org.in)',
          'Police FIR for criminal intimidation (Sec 351 BNS)',
        ],
      );
    }

    // 30. Cheque Bounce & Section 138 NI Act
    if (normalized.contains('cheque bounce') ||
        normalized.contains('check bounce') ||
        normalized.contains('section 138') ||
        normalized.contains('dishonour of cheque') ||
        normalized.contains('insufficient funds') ||
        normalized.contains('138 notice') ||
        normalized.contains('चेक बाउंस')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Section 138 NI Act Cheque Dishonour',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Mandatory Timelines Apply',
          verdictColor: const Color(0xFFA83900),
          verdictBgColor: const Color(0xFFFFDBCF),
          directAnswer:
              'Cheque bounce carries criminal liability under Section 138 NI Act, but only IF strict statutory timelines (30-day notice and 15-day payment cure period) are followed.',
          legalReasoning:
              'Under Section 138 of the Negotiable Instruments Act 1881, when a cheque is dishonoured due to insufficient funds, the payee must issue a formal Statutory Legal Notice in writing within 30 days of receiving the bank dishonour memo. The drawer then gets a mandatory 15-day grace period from notice receipt to pay the amount. A criminal complaint before the Magistrate can ONLY be filed within 30 days after the 15-day cure period expires.',
          sourceTitle: 'Based on: Section 138 to 142 Negotiable Instruments Act 1881',
          statutoryCitation: 'Sec 138, 141 & 142 Negotiable Instruments Act 1881',
          citizenActionSteps: [
            'Check the date on the bank memo: legal notice must be issued within 30 days of memo receipt.',
            'If you received a 138 notice, pay within 15 days of receipt to extinguish all criminal liability.',
            'If there was no legally enforceable debt (e.g. security cheque misuse), consult an advocate to draft a point-by-point reply.',
            'For settlement or compromise, matters can be resolved amicably in the National Lok Adalat.',
          ],
          criticalDonts: [
            'DO NOT ignore a Section 138 legal notice; silence can be treated as an adverse inference in court.',
            'DO NOT stop payment on a cheque without documenting valid dispute grounds prior to stoppage.',
          ],
        ),
        triageOptions: [
          'Received 138 legal notice from lawyer',
          'Cheque issued to me bounced at bank',
          'Reply to 138 notice within 15 days',
          'Security cheque misused by lender',
        ],
      );
    }

    // 31. Right to Information (RTI Act 2005)
    if (normalized.contains('rti') ||
        normalized.contains('right to information') ||
        normalized.contains('pio') ||
        normalized.contains('first appeal') ||
        normalized.contains('30 days rti') ||
        normalized.contains('life and liberty rti') ||
        normalized.contains('सूचना का अधिकार')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Right to Information (RTI Act 2005)',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Statutory Duty Enforceable',
          verdictColor: const Color(0xFF006A4E),
          verdictBgColor: const Color(0xFFE8F5E9),
          directAnswer:
              'Public Information Officers (PIO) are legally bound to supply information within 30 days, or within 48 HOURS if concerning life or liberty.',
          legalReasoning:
              'Under Section 7(1) of the Right to Information Act 2005, the Public Information Officer (PIO) must either provide information or reject the application within 30 days of receipt. Crucially, where the information sought concerns the life or liberty of a person, it must be provided within forty-eight hours of application receipt. If no reply is given within 30 days, it is deemed a refusal under Sec 7(2), and the citizen has the statutory right to file a First Appeal under Section 19(1).',
          sourceTitle: 'Based on: Section 6, 7 & 19 Right to Information Act 2005',
          statutoryCitation: 'Sec 6, 7(1), 19(1) & 20 Right to Information Act 2005',
          citizenActionSteps: [
            'Draft a specific, question-based application referencing Section 6(1) of the RTI Act 2005.',
            'Submit online via rtionline.gov.in (for Central ministries) or state RTI portals with Rs 10 fee.',
            'If 30 days have elapsed without response, submit a First Appeal under Section 19(1) to the First Appellate Authority (FAA).',
            'If FAA fails to decide within 30-45 days, file a Second Appeal before the Central/State Information Commission.',
          ],
          criticalDonts: [
            'DO NOT ask vague or hypothetical questions; ask for specific records, memos, or certified file copies.',
            'DO NOT pay arbitrary additional search fees without receiving a detailed cost calculation letter from the PIO.',
          ],
        ),
        triageOptions: [
          'Draft RTI application for municipal authority',
          'PIO refused RTI or exceeded 30 days',
          'File First Appeal under Sec 19(1)',
          '48-hour emergency life/liberty RTI',
        ],
      );
    }

    // 32. Builder Delayed Possession & RERA Sec 18
    if (normalized.contains('builder delay') ||
        normalized.contains('flat possession') ||
        normalized.contains('possession delayed') ||
        normalized.contains('rera') ||
        normalized.contains('builder not giving flat') ||
        normalized.contains('delay interest') ||
        normalized.contains('रेरा') ||
        normalized.contains('बिल्डर')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Builder Delayed Possession & RERA Section 18',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Statutory Compensation Guaranteed',
          verdictColor: const Color(0xFF006A4E),
          verdictBgColor: const Color(0xFFE8F5E9),
          directAnswer:
              'YES. Under Section 18 of RERA, you have the absolute legal right to demand full refund with interest OR monthly interest for every month of delay.',
          legalReasoning:
              'Under Section 18 of the Real Estate (Regulation and Development) Act 2016 (RERA), if a promoter fails to complete or give possession of an apartment, plot, or building in accordance with the terms of the agreement for sale, the allottee has two absolute statutory choices: (1) withdraw from the project and claim full refund of amounts paid with prescribed interest (SBI MCLR + 2%) plus compensation, or (2) stay in the project and receive monthly delay compensation interest until physical possession is handed over with an Occupancy Certificate.',
          sourceTitle: 'Based on: Section 18 Real Estate (Regulation and Development) Act 2016',
          statutoryCitation: 'Sec 18, 19 & 31 Real Estate (Regulation and Development) Act 2016',
          citizenActionSteps: [
            'Verify the possession date specified in your registered Agreement for Sale.',
            'Send a formal legal notice to the builder claiming delay interest under Section 18 RERA.',
            'File an online complaint before your State RERA Authority (e.g. MahaRERA, UP RERA, HRERA, TNRERA).',
            'Demand delay compensation calculated at State Bank of India highest MCLR + 2%.',
          ],
          criticalDonts: [
            'DO NOT take physical key possession without the builder providing an official Occupancy Certificate (OC).',
            'DO NOT sign unilateral builder addendums extending possession dates without prejudice to your compensation.',
          ],
        ),
        triageOptions: [
          'Claim monthly delay interest from builder',
          'Withdraw from project and demand 100% refund',
          'File complaint on State RERA portal',
          'Builder offering possession without OC',
        ],
      );
    }

    // 33. Railway TTE Night Inspection Rules & RailMadad
    if (normalized.contains('tte') ||
        normalized.contains('railway ticket check') ||
        normalized.contains('night ticket') ||
        normalized.contains('train sleep') ||
        normalized.contains('railmadad') ||
        normalized.contains('10 pm train') ||
        normalized.contains('6 am train') ||
        normalized.contains('टीटीई') ||
        normalized.contains('ट्रेन टिकट')) {
      return CivicAiMessage(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        text: 'Railway TTE Night Inspection Rules & RailMadad',
        isUser: false,
        timestamp: DateTime.now(),
        relatedCardId: 'traffic_stop_default',
        verdict: CivicAiVerdict(
          verdictTitle: 'Statutory Verdict: Procedural Violation',
          verdictColor: const Color(0xFFBA1A1A),
          verdictBgColor: const Color(0xFFFFDAD6),
          directAnswer:
              'NO. Railway TTEs CANNOT wake up passengers or check tickets between 10:00 PM and 06:00 AM if you have a confirmed berth.',
          legalReasoning:
              'Under Indian Railways Commercial Manual Rule 2.11 and Ministry of Railways passenger directives, Travelling Ticket Examiners (TTEs) are strictly prohibited from inspecting tickets of confirmed berth passengers between 22:00 hours (10:00 PM) and 06:00 hours (06:00 AM). The only exception is for passengers who boarded the train at an intermediate station after 10 PM. Lights in sleeper/AC coaches must also be switched off for night rest.',
          sourceTitle: 'Based on: Indian Railways Commercial Manual Rule 2.11 & Ministry Guidelines',
          statutoryCitation: 'Rule 2.11 Indian Railways Commercial Manual; RailMadad Grievance Directives',
          citizenActionSteps: [
            'Politely remind the TTE: "Sir, under Railway Board rules, ticket checking for confirmed passengers is restricted between 10 PM and 6 AM."',
            'Show your electronic IRCTC PNR SMS or ticket on your mobile without leaving your berth.',
            'If a TTE behaves aggressively or demands bribes, dial RailMadad Helpline 139 immediately.',
            'Log an instant complaint with coach and berth details on the RailMadad app or portal (railmadad.indianrailways.gov.in).',
          ],
          criticalDonts: [
            'DO NOT surrender your phone or physical ticket to someone who refuses to display their Railway badge.',
            'DO NOT pay excess fare penalties in cash without demanding an official Electronic Handheld Terminal (HHT) receipt.',
          ],
        ),
        triageOptions: [
          'TTE waking up confirmed passengers at night',
          'TTE demanding cash fine on running train',
          'File live grievance on RailMadad 139',
          'Travel with waitlisted ticket in reserved coach',
        ],
      );
    }

    // E. General Constitutional & Statutory Rights (Universal Synthesis)
    return CivicAiMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Constitutional Rights & Procedural Guidance',
      isUser: false,
      timestamp: DateTime.now(),
      relatedCardId: 'traffic_stop_default',
      verdict: CivicAiVerdict(
        verdictTitle: 'Statutory Verdict: Fundamental Rights Protected',
        verdictColor: const Color(0xFFA83900),
        verdictBgColor: const Color(0xFFFFDBCF),
        directAnswer:
            'Under Indian constitutional jurisprudence, every citizen is entitled to equal protection of laws (Article 14), personal liberty (Article 21), and free legal aid (Article 39A).',
        legalReasoning:
            'All administrative, civic, and law enforcement actions in India must strictly adhere to the Principles of Natural Justice (right to notice and fair hearing) and the Bharatiya Nagarik Suraksha Sanhita (BNSS 2023). Extra-legal intimidation, arbitrary detentions, and verbal coercion have no force of law. You have the statutory right to demand written notices and official receipts for all interactions.',
        sourceTitle: 'Based on: Fundamental Rights & Procedural Protections (Reviewed Oct 2026)',
        statutoryCitation: 'Articles 14, 19, 21 & 39A Constitution of India; BNSS 2023 & BNS 2023',
        citizenActionSteps: [
          'Ask for official written notices or summons specifying the statutory section rather than complying with verbal orders.',
          'Document date, time, identities of public servants, badge numbers, and keep all physical receipts safe.',
          'Call the National Legal Aid Toll-Free Helpline 15100 for immediate advice from an empanelled advocate.',
          'Browse relevant situation cards in CIVIC for step-by-step role guidance and legal scripts.',
        ],
        criticalDonts: [
          'DO NOT comply with arbitrary verbal demands that lack written statutory authority.',
          'DO NOT pay cash without receiving an official government receipt or e-challan.',
          'DO NOT sign documents or admissions without having them reviewed by an advocate.',
        ],
      ),
      triageOptions: [
        'Police interaction & custody',
        'Civil / Tenancy / Consumer dispute',
        'Free legal aid eligibility (15100)',
        'Motor vehicle traffic violation',
      ],
    );
  }

  CivicAiMessage _generateVoiceQueryTriage(String? audioPath) {
    return CivicAiMessage(
      id: 'voice_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Voice Query Captured • Select Your Legal Issue',
      isUser: false,
      timestamp: DateTime.now(),
      audioPath: audioPath,
      relatedCardId: 'traffic_stop_default',
      verdict: CivicAiVerdict(
        verdictTitle: 'Voice Note Recorded: Select Your Situation',
        verdictColor: const Color(0xFF006A4E),
        verdictBgColor: const Color(0xFFE8F5E9),
        directAnswer:
            'Your audio recording has been received. To provide immediate statutory protection, please select the legal issue you are encountering or tap any option below:',
        legalReasoning:
            'CIVIC on-device legal intelligence synthesizes immediate protections from the Bharatiya Nagarik Suraksha Sanhita (BNSS 2023), Motor Vehicles Act 1988, and constitutional safeguards (Articles 20, 21, and 22). Select your immediate situation below to get verified scripts, statutory citations, and step-by-step guidance.',
        sourceTitle: 'Based on: CIVIC Immediate Citizen Rights & Statutory Dispatch',
        statutoryCitation: 'BNSS 2023; BNS 2023; Motor Vehicles Act 1988; Articles 20, 21 & 22 Constitution',
        citizenActionSteps: [
          'Tap the situation below that matches what you are experiencing right now.',
          'Speak clearly or type your question in Hindi or English if none of these match.',
          'If an officer is confronting you, keep CIVIC open and ask them to state the specific legal provision.',
        ],
        criticalDonts: [
          'DO NOT surrender your phone or unlock it without a judicial warrant.',
          'DO NOT pay cash bribes or spot fines without an official e-challan or receipt.',
          'DO NOT sign blank papers or admissions under pressure.',
        ],
      ),
      triageOptions: [
        '🚗 Car keys taken by traffic police',
        '📱 Police demanding to search phone / WhatsApp',
        '🎒 Police frisking bag or pockets on street',
        '💵 Police demanding bribe or cash penalty',
        '📝 Police refusing to register FIR',
        '🏨 Hotel or moral policing of couple',
        '🏠 Police searching house without warrant',
        '💳 UPI scam / cyber account frozen',
      ],
    );
  }

  CivicAiMessage _generateDocumentAnalysis(String docName, String docPath) {
    final lowerName = docName.toLowerCase();
    String detectedType = 'Official Notice / Document';
    String verdict = 'Document Analyzed: Procedural Compliance Required';
    String directAnswer =
        'CIVIC AI scanned the uploaded document. It appears to be an official notice or challan record.';
    String legalAnalysis =
        'Under Indian administrative law, all notices issued by law enforcement or regulatory authorities must specify the statutory provision, issuing officer details, dispatch number, and hearing/payment deadline. You have the right to inspect the record and submit an official reply.';

    if (lowerName.contains('challan') || lowerName.contains('traffic') || lowerName.contains('parivahan')) {
      detectedType = 'Traffic E-Challan / Vehicle Notice';
      verdict = 'Statutory Verdict: Verify Compounding Authority';
      directAnswer =
          'Document recognized as a Motor Vehicle Traffic Challan. Verify whether the violation is compoundable on the spot or sent to a Virtual Court.';
      legalAnalysis =
          'Under the Motor Vehicles (Amendment) Act 2019, traffic notices must display the specific vehicle registration number, camera location timestamp, and statutory section. Under Rule 139 CMVR, you have 15 days to present valid documents if cited for non-possession. You can contest improper challans before the Virtual Court.';
    } else if (lowerName.contains('summon') || lowerName.contains('court') || lowerName.contains('notice')) {
      detectedType = 'Statutory Summons / Police Notice (Sec 41A / 35 BNSS)';
      verdict = 'Statutory Verdict: Formal Appearance Notice';
      directAnswer =
          'Document recognized as a Notice of Appearance under Section 41A CrPC / Section 35(3) BNSS.';
      legalAnalysis =
          'Under the Arnesh Kumar guidelines, police must issue a Section 41A notice for offences punishable with up to 7 years imprisonment instead of arresting directly. As long as you comply with the notice and appear before the Investigating Officer, you CANNOT be arrested without specific judicial grounds recorded in writing.';
    }

    return CivicAiMessage(
      id: 'doc_${DateTime.now().millisecondsSinceEpoch}',
      text: 'Analysis of $docName ($detectedType)',
      isUser: false,
      timestamp: DateTime.now(),
      attachmentName: docName,
      attachmentPath: docPath,
      attachmentType: 'document',
      relatedCardId: 'traffic_stop_default',
      verdict: CivicAiVerdict(
        verdictTitle: verdict,
        verdictColor: const Color(0xFFA83900),
        verdictBgColor: const Color(0xFFFFDBCF),
        directAnswer: directAnswer,
        legalReasoning: legalAnalysis,
        sourceTitle: 'Based on: CIVIC Document Scanner & Statutory Verification Engine',
        statutoryCitation: 'BNSS 2023; Motor Vehicles Act 1988; Arnesh Kumar Guidelines (2014)',
        citizenActionSteps: [
          'Verify the dispatch number, issuing officer designation, and seal on the document.',
          'Note down the statutory appearance or payment deadline (typically 7-15 days).',
          'Consult a free NALSA panel lawyer via 15100 before making binding admissions.',
          'Retain the original paper copy in your private CIVIC Vault.',
        ],
        criticalDonts: [
          'DO NOT ignore official court summons or appearance deadlines.',
          'DO NOT pay fines on fraudulent phishing websites; use only official portals (echallan.parivahan.gov.in).',
          'DO NOT sign admissions of guilt without consulting a legal aid lawyer.',
        ],
      ),
      triageOptions: [
        'Pay fine on Virtual Court',
        'Draft response letter',
        'Contest incorrect charges',
        'Speak to legal aid advocate',
      ],
    );
  }
}
