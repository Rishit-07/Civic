import 'dart:convert';
import 'package:flutter/services.dart';

/// Content loader to parse mock JSON assets
class ContentLoader {
  ContentLoader._();

  static Future<List<Map<String, dynamic>>> loadOnboardingSlides() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/content/onboarding_slides.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } catch (e) {
      // Fallback mock data in case asset load is interrupted
      return [
        {
          "id": "know",
          "stepNumber": "01",
          "badge": "STEP 01 // KNOWLEDGE",
          "title": "KNOW",
          "headline": "KNOW YOUR CITIZEN RIGHTS",
          "description": "Clear statutory protocols and fundamental rights organized for immediate recall during everyday encounters.",
          "themeTag": "FOUNDATIONAL_AWARENESS",
          "icon": "balance"
        },
        {
          "id": "prepare",
          "stepNumber": "02",
          "badge": "STEP 02 // READINESS",
          "title": "PREPARE",
          "headline": "PREPARE WITH STRUCTURE",
          "description": "Essential emergency checklists, verified contacts, and procedural safeguards ready when seconds matter.",
          "themeTag": "PROCEDURAL_SAFETY",
          "icon": "shield"
        },
        {
          "id": "act",
          "stepNumber": "03",
          "badge": "STEP 03 // AGENCY",
          "title": "ACT",
          "headline": "ACT WITH CONFIDENCE",
          "description": "Document encounters securely, access legal assistance channels, and exercise constitutional remedies calmly.",
          "themeTag": "CONSTITUTIONAL_REMEDY",
          "icon": "gavel"
        }
      ];
    }
  }

  static Future<Map<String, dynamic>> loadSampleContent() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/content/sample_content.json');
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return {};
    }
  }
}
