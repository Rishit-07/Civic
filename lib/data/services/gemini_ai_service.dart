import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'app_preferences.dart';
import 'civic_ai_service.dart';

/// Service connecting CIVIC to Google Gemini LLM for dynamic, real-time legal question answering.
/// Free tier supported via Google AI Studio API Keys.
class GeminiAiService {
  static final GeminiAiService instance = GeminiAiService._internal();
  GeminiAiService._internal();

  /// Analyzes a citizen question with Gemini LLM.
  /// Returns null if API key is not configured, network fails, or an error occurs,
  /// allowing seamless fallback to CIVIC's verified on-device legal rules engine.
  Future<CivicAiMessage?> generateLegalAnswer({
    required String query,
    String? audioPath,
  }) async {
    final apiKey = AppPreferences.geminiApiKey;
    if (apiKey.isEmpty) {
      return null;
    }

    final primaryModel = AppPreferences.geminiModel;
    final candidateModels = [
      primaryModel,
      if (primaryModel != 'gemini-3.8-flash') 'gemini-3.8-flash',
      if (primaryModel != 'gemini-3.6-flash') 'gemini-3.6-flash',
      if (primaryModel != 'gemini-flash-latest') 'gemini-flash-latest',
    ];

    final userJurisdiction = AppPreferences.selectedState;
    final systemInstruction = '''
You are CIVIC AI, an authoritative, objective Indian statutory law and citizen rights legal intelligence assistant.
Analyze citizen inquiries under current Indian legislation and judicial precedents, specifically:
- Bharatiya Nagarik Suraksha Sanhita 2023 (BNSS) & Code of Criminal Procedure 1973 (CrPC)
- Bharatiya Nyaya Sanhita 2023 (BNS) & Indian Penal Code 1860 (IPC)
- Motor Vehicles Act 1988 (as amended 2019) & Central Motor Vehicles Rules 1989 (Rule 139 DigiLocker/mParivahan acceptance; Sec 47 11-month out-of-state grace period; prohibition on towing occupied vehicles)
- Constitution of India (Articles 14, 19, 20(3), 21, 22, 32, 226)
- Information Technology Act 2000 & Consumer Protection Act 2019 (unfair trade practices, dark patterns, auto-debit rules)
- Right to Information Act 2005 (Sec 6 applications, Sec 7(1) 48-hour life/liberty mandate, Sec 19(1) First Appeal)
- Clinical Establishments (Registration and Regulation) Act 2010 & Supreme Court ruling in Parmanand Katara (unconditional emergency medical stabilization)
- Real Estate (Regulation and Development) Act 2016 (RERA Sec 18 delay interest and refund rights)
- RBI Fair Practices Code & Guidelines on Recovery Agents (8 AM to 7 PM only, ban on doorstep intimidation, abusive language, or contacting friends/family)
- Negotiable Instruments Act 1881 (Sec 138 cheque dishonour 15-day mandatory statutory notice)
- DGCA Passenger Charter (flight delay refreshments, alternate flights, cancellation refunds, boarding denial compensation)
- Indian Railways Act 1989 & TTE Night Inspection Rules (no ticket checks between 10 PM and 6 AM for confirmed passengers; RailMadad 139)
- State Police Acts, State Rent Control Acts, and Police Complaints Authority (PCA) mechanisms across Indian States.
- Landmark Supreme Court Precedents (D.K. Basu, Arnesh Kumar, Justice K.S. Puttaswamy, Lalita Kumari, Prem Shankar Shukla, Parmanand Katara).

You must respond strictly in JSON format matching this schema:
{
  "verdictTitle": "Statutory Verdict: Strictly Unlawful / Procedural Rules Apply / Constitutional Right Protected",
  "isUnlawful": true,
  "directAnswer": "Direct concise answer starting with YES, NO, or mandatory procedural rule.",
  "legalReasoning": "Detailed plain-language legal explanation citing the specific legislative provisions and rights.",
  "statutoryCitation": "Exact Acts and Sections (e.g. Sec 126 BNS 2023; Sec 100 CrPC / Sec 105 BNSS; Article 21 Constitution)",
  "citizenActionSteps": ["Immediate what to do step 1", "Immediate what to do step 2", "Immediate what to do step 3"],
  "criticalDonts": ["Critical mistake to avoid 1", "Critical mistake to avoid 2"],
  "triageOptions": ["Related situation clarification 1", "Related situation clarification 2", "Related situation clarification 3"]
}
''';

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemInstruction}
        ]
      },
      'contents': [
        {
          'parts': [
            {
              'text':
                  'Citizen Question: $query\nJurisdiction / State: $userJurisdiction (incorporate applicable state-specific laws if jurisdiction is not ALL).'
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'response_mime_type': 'application/json',
      }
    };

    for (final model in candidateModels) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
        );

        final response = await http
            .post(
              url,
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode(requestBody),
            )
            .timeout(const Duration(seconds: 25));

        if (response.statusCode != 200) {
          debugPrint('Gemini API ($model) returned status ${response.statusCode}: ${response.body}');
          // If server is experiencing high demand (503) or model unavailable, try fallback model
          if (response.statusCode == 503 || response.statusCode == 404) {
            continue;
          }
          return null;
        }

        final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
        final candidates = jsonMap['candidates'] as List<dynamic>?;
        if (candidates == null || candidates.isEmpty) continue;

        final content = candidates[0]['content'] as Map<String, dynamic>?;
        final parts = content?['parts'] as List<dynamic>?;
        if (parts == null || parts.isEmpty) continue;

        String? rawText;
        for (final part in parts) {
          if (part is Map<String, dynamic> && part.containsKey('text')) {
            final t = part['text'] as String?;
            if (t != null && t.trim().isNotEmpty) {
              rawText = t;
              break;
            }
          }
        }
        if (rawText == null || rawText.isEmpty) continue;

        String cleanJson = rawText.trim();
        if (cleanJson.startsWith('```json')) {
          cleanJson = cleanJson.substring(7);
        } else if (cleanJson.startsWith('```')) {
          cleanJson = cleanJson.substring(3);
        }
        if (cleanJson.endsWith('```')) {
          cleanJson = cleanJson.substring(0, cleanJson.length - 3);
        }
        cleanJson = cleanJson.trim();

        final parsed = jsonDecode(cleanJson) as Map<String, dynamic>;


      final isUnlawful = parsed['isUnlawful'] == true;
      final verdictTitle = parsed['verdictTitle'] as String? ?? 'Statutory Verdict: Procedural Rules Apply';
      final directAnswer = parsed['directAnswer'] as String? ?? 'Statutory guidelines apply to this interaction.';
      final legalReasoning = parsed['legalReasoning'] as String? ?? '';
      final statutoryCitation = parsed['statutoryCitation'] as String? ?? 'Constitution of India; BNSS 2023; BNS 2023';

      final actionSteps = (parsed['citizenActionSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'Ask the officer to state their rank, name, and statutory authority.',
            'Document date, time, and badge details.',
            'Call National Legal Aid Helpline 15100 or Emergency 112 if threatened.',
          ];

      final criticalDonts = (parsed['criticalDonts'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [
            'DO NOT argue aggressively or resist lawful inquiries physically.',
            'DO NOT pay unreceipted cash fines on the spot.',
          ];

      final triageOptions = (parsed['triageOptions'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList();

      final Color verdictColor = isUnlawful ? const Color(0xFFBA1A1A) : const Color(0xFF006A4E);
      final Color verdictBgColor = isUnlawful ? const Color(0xFFFFDAD6) : const Color(0xFFE8F5E9);

        return CivicAiMessage(
          id: 'gemini_${DateTime.now().millisecondsSinceEpoch}',
          text: 'Gemini AI Statutory Legal Analysis',
          isUser: false,
          timestamp: DateTime.now(),
          audioPath: audioPath,
          relatedCardId: 'traffic_stop_default',
          verdict: CivicAiVerdict(
            verdictTitle: verdictTitle,
            verdictColor: verdictColor,
            verdictBgColor: verdictBgColor,
            directAnswer: directAnswer,
            legalReasoning: legalReasoning,
            sourceTitle: 'Based on: Google Gemini LLM ($model) • Indian Statutory Synthesis',
            statutoryCitation: statutoryCitation,
            citizenActionSteps: actionSteps,
            criticalDonts: criticalDonts,
          ),
          triageOptions: triageOptions,
        );
      } catch (e) {
        debugPrint('GeminiAiService ($model) error: $e');
        continue;
      }
    }
    return null;
  }
}
