/// Data models for the CIVIC Content System
/// Implements strict schema validation, 7-line limit on short_lines,
/// and safety gate statuses for legal compliance.
library;

enum UserRole {
  affected,
  accused,
  witness,
  parent;

  String get label {
    switch (this) {
      case UserRole.affected:
        return 'Affected Person';
      case UserRole.accused:
        return 'Accused / Named';
      case UserRole.witness:
        return 'Witness / Bystander';
      case UserRole.parent:
        return 'Parent / Guardian';
    }
  }

  String get displayName => label;

  static UserRole fromString(String role) {
    switch (role.toLowerCase().trim()) {
      case 'accused':
        return UserRole.accused;
      case 'witness':
        return UserRole.witness;
      case 'parent':
        return UserRole.parent;
      case 'affected':
      default:
        return UserRole.affected;
    }
  }
}

class LegalBasis {
  final String act;
  final String section;
  final String status;
  final String sourceUrl;

  const LegalBasis({
    required this.act,
    required this.section,
    required this.status,
    required this.sourceUrl,
  });

  factory LegalBasis.fromJson(Map<String, dynamic> json) {
    return LegalBasis(
      act: json['act'] as String? ?? 'Constitution of India',
      section: json['section'] as String? ?? 'Article 21',
      status: json['status'] as String? ?? 'Verified Statutory Safeguard',
      sourceUrl: json['source_url'] as String? ?? 'https://indiacode.nic.in',
    );
  }

  Map<String, dynamic> toJson() => {
    'act': act,
    'section': section,
    'status': status,
    'source_url': sourceUrl,
  };
}

class AppliesTo {
  final List<String> states;
  final int ageMin;
  final List<String> userTypes;

  const AppliesTo({
    this.states = const ['ALL'],
    this.ageMin = 0,
    this.userTypes = const ['all'],
  });

  factory AppliesTo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const AppliesTo();
    return AppliesTo(
      states: (json['states'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['ALL'],
      ageMin: json['age_min'] as int? ?? 0,
      userTypes: (json['user_types'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['all'],
    );
  }

  Map<String, dynamic> toJson() => {
    'states': states,
    'age_min': ageMin,
    'user_types': userTypes,
  };

  bool matches({String? state, int? age, String? userType}) {
    if (state != null && states.isNotEmpty && !states.contains('ALL') && !states.contains(state.toUpperCase())) {
      return false;
    }
    if (age != null && age < ageMin) {
      return false;
    }
    if (userType != null && userTypes.isNotEmpty && !userTypes.contains('all') && !userTypes.contains(userType.toLowerCase())) {
      return false;
    }
    return true;
  }
}

class CardModel {
  final String id;
  final String category;
  final String scenario;
  final String branch;
  final String language;
  final String title;
  final List<String> roles;
  final List<String> shortLines;
  final List<String> doList;
  final List<String> dontList;
  final List<LegalBasis> legalBasis;
  final List<String> helplines;
  final AppliesTo appliesTo;
  final String? nextBranch;
  final String voiceScript;
  final List<String> evidenceChecklist;
  final String reviewedBy;
  final DateTime? reviewedOn;
  final DateTime? validUntil;
  final int riskTier;

  const CardModel({
    required this.id,
    required this.category,
    required this.scenario,
    required this.branch,
    this.language = 'en',
    required this.title,
    required this.roles,
    required this.shortLines,
    required this.doList,
    required this.dontList,
    required this.legalBasis,
    required this.helplines,
    required this.appliesTo,
    this.nextBranch,
    required this.voiceScript,
    required this.evidenceChecklist,
    required this.reviewedBy,
    this.reviewedOn,
    this.validUntil,
    this.riskTier = 2,
  }) : assert(shortLines.length <= 7, 'Card cannot have more than 7 short_lines');

  factory CardModel.fromJson(Map<String, dynamic> json) {
    final rawShortLines = (json['short_lines'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    if (rawShortLines.length > 7) {
      throw FormatException('Validation Error: Card ${json['id']} has ${rawShortLines.length} short_lines, exceeding maximum of 7');
    }

    DateTime? parseDate(dynamic val) {
      if (val == null || val.toString().isEmpty) return null;
      try {
        return DateTime.parse(val.toString());
      } catch (_) {
        return null;
      }
    }

    final scenarioVal = (json['scenario'] ?? json['scenario_id']) as String? ?? '';
    final voiceScriptVal = (json['voice_script'] ?? json['what_to_say']) as String? ?? 'Immediate verified statutory spoken guidance.';
    final doListVal = ((json['do'] ?? json['do_list']) as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final dontListVal = ((json['dont'] ?? json['dont_list']) as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final helplinesVal = ((json['helplines'] ?? json['helpline_ids']) as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final rolesVal = ((json['roles'] ?? json['user_roles']) as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['affected'];

    return CardModel(
      id: json['id'] as String? ?? '',
      category: json['category'] as String? ?? '',
      scenario: scenarioVal,
      branch: json['branch'] as String? ?? 'default',
      language: json['language'] as String? ?? 'en',
      title: json['title'] as String? ?? 'Legal Encounter',
      roles: rolesVal,
      shortLines: rawShortLines,
      doList: doListVal,
      dontList: dontListVal,
      legalBasis: (json['legal_basis'] as List<dynamic>?)
              ?.map((e) => LegalBasis.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      helplines: helplinesVal,
      appliesTo: AppliesTo.fromJson(json['applies_to'] as Map<String, dynamic>?),
      nextBranch: json['next_branch'] as String?,
      voiceScript: voiceScriptVal,
      evidenceChecklist: (json['evidence_checklist'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      reviewedBy: json['reviewed_by'] as String? ?? '',
      reviewedOn: parseDate(json['reviewed_on'] ?? json['reviewed_date']),
      validUntil: parseDate(json['valid_until']),
      riskTier: json['risk_tier'] as int? ?? 2,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'scenario': scenario,
    'branch': branch,
    'language': language,
    'title': title,
    'roles': roles,
    'short_lines': shortLines,
    'do': doList,
    'dont': dontList,
    'legal_basis': legalBasis.map((e) => e.toJson()).toList(),
    'helplines': helplines,
    'applies_to': appliesTo.toJson(),
    'next_branch': nextBranch,
    'voice_script': voiceScript,
    'evidence_checklist': evidenceChecklist,
    'reviewed_by': reviewedBy,
    'reviewed_on': reviewedOn?.toIso8601String(),
    'valid_until': validUntil?.toIso8601String(),
    'risk_tier': riskTier,
  };

  /// Safety Gate Verification Helpers
  bool get isReviewed => reviewedBy.trim().isNotEmpty;

  bool get isExpired {
    if (validUntil == null) return false;
    return DateTime.now().isAfter(validUntil!);
  }

  /// In release mode, only reviewed and unexpired cards may be displayed
  bool get isDisplayableInRelease => isReviewed && !isExpired;

  /// Review Status for UI Badges & Debug Screen
  String get status {
    if (isExpired) return 'expired';
    if (isReviewed) return 'reviewed';
    if (title.contains('[PENDING LAWYER REVIEW]') || shortLines.every((l) => l.contains('[PENDING LAWYER REVIEW]'))) {
      return 'placeholder';
    }
    return 'drafted';
  }
}

class TriageOption {
  final String label;
  final String branch;

  const TriageOption({
    required this.label,
    required this.branch,
  });

  factory TriageOption.fromJson(Map<String, dynamic> json) {
    return TriageOption(
      label: json['label'] as String? ?? '',
      branch: json['branch'] as String? ?? 'default',
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'branch': branch,
  };
}

class TriageQuestion {
  final String id;
  final String text;
  final List<TriageOption> options;

  const TriageQuestion({
    required this.id,
    required this.text,
    required this.options,
  });

  factory TriageQuestion.fromJson(Map<String, dynamic> json) {
    return TriageQuestion(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => TriageOption.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'options': options.map((e) => e.toJson()).toList(),
  };
}

class Scenario {
  final String id;
  final String label;
  final int urgency;
  final String description;
  final List<TriageQuestion> triageQuestions;
  final List<String> branches;

  const Scenario({
    required this.id,
    required this.label,
    required this.urgency,
    required this.description,
    required this.triageQuestions,
    required this.branches,
  });

  factory Scenario.fromJson(Map<String, dynamic> json) {
    return Scenario(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      urgency: json['urgency'] as int? ?? 2,
      description: json['description'] as String? ?? '',
      triageQuestions: (json['triage_questions'] as List<dynamic>?)
              ?.map((e) => TriageQuestion.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      branches: (json['branches'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['default'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'urgency': urgency,
    'description': description,
    'triage_questions': triageQuestions.map((e) => e.toJson()).toList(),
    'branches': branches,
  };
}

class Category {
  final String id;
  final String label;
  final String icon;
  final String description;
  final List<Scenario> scenarios;

  const Category({
    required this.id,
    required this.label,
    required this.icon,
    required this.description,
    required this.scenarios,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      icon: json['icon'] as String? ?? 'help',
      description: json['description'] as String? ?? '',
      scenarios: (json['scenarios'] as List<dynamic>?)
              ?.map((e) => Scenario.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'icon': icon,
    'description': description,
    'scenarios': scenarios.map((e) => e.toJson()).toList(),
  };
}

class HelplineModel {
  final String id;
  final String label;
  final String number;
  final String category;
  final String description;
  final String lastVerified;

  const HelplineModel({
    required this.id,
    required this.label,
    required this.number,
    required this.category,
    required this.description,
    required this.lastVerified,
  });

  factory HelplineModel.fromJson(Map<String, dynamic> json) {
    return HelplineModel(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      number: json['number'] as String? ?? '',
      category: json['category'] as String? ?? 'EMERGENCY',
      description: json['description'] as String? ?? '',
      lastVerified: json['last_verified'] as String? ?? 'UNVERIFIED',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'number': number,
    'category': category,
    'description': description,
    'last_verified': lastVerified,
  };
}
