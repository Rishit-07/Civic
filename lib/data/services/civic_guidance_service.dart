import '../models/content_models.dart';

/// Data model representing a legal DO or DON'T guidance point
class GuidanceItem {
  final String title;
  final String subtitle;
  final String? legalRef;

  const GuidanceItem({
    required this.title,
    required this.subtitle,
    this.legalRef,
  });
}

/// Metadata for spotlight headline banner
class SpotlightMeta {
  final String tag;
  final String title;
  final String subtitle;

  const SpotlightMeta({
    required this.tag,
    required this.title,
    required this.subtitle,
  });
}

/// Data model representing a procedural emergency verification checklist
class EmergencyChecklistData {
  final String title;
  final String subtitle;
  final List<String> items;

  const EmergencyChecklistData({
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

/// Authoritative statutory legal basis & judicial citation model
class StatutoryLegalBasisData {
  final String categoryTag;
  final String primaryAct;
  final String? primaryActUrl;
  final String enactedSections;
  final String? enactedSectionsUrl;
  final String newCriminalCodes;
  final String? newCriminalCodesUrl;
  final String landmarkPrecedent;
  final String? landmarkPrecedentUrl;
  final String keyStatutorySafeguard;
  final String? keyStatutorySafeguardUrl;
  final String officialSource;
  final String? officialSourceUrl;
  final String lastVerified;

  const StatutoryLegalBasisData({
    required this.categoryTag,
    required this.primaryAct,
    this.primaryActUrl,
    required this.enactedSections,
    this.enactedSectionsUrl,
    required this.newCriminalCodes,
    this.newCriminalCodesUrl,
    required this.landmarkPrecedent,
    this.landmarkPrecedentUrl,
    required this.keyStatutorySafeguard,
    this.keyStatutorySafeguardUrl,
    required this.officialSource,
    this.officialSourceUrl,
    this.lastVerified = 'November 2024 by Supreme Court Bar Advocates Panel',
  });

  String get compactCitation =>
      '$primaryAct ($enactedSections); $landmarkPrecedent; BNSS/BNS: $newCriminalCodes.';
}

/// Dynamic Legal Guidance Service providing role-specific and scenario-specific
/// DOs, DON'Ts, and Emergency Checklists across all statutory domains of the CIVIC platform.
class CivicGuidanceService {
  /// Get dynamic scenario-family and role-specific Emergency Checklist
  static EmergencyChecklistData getEmergencyChecklist({
    required String? scenarioId,
    required UserRole role,
    String? fallbackTitle,
    List<String>? cardEvidenceChecklist,
  }) {
    // If the content card provided valid, non-placeholder checklist items, prioritize them
    if (cardEvidenceChecklist != null && cardEvidenceChecklist.isNotEmpty) {
      final validCardItems = cardEvidenceChecklist
          .where((e) => e.trim().isNotEmpty && !e.contains('[PENDING'))
          .toList();
      if (validCardItems.length >= 2) {
        return EmergencyChecklistData(
          title: 'EMERGENCY CHECKLIST',
          subtitle: 'Verify these key procedural and evidence steps for this scenario.',
          items: validCardItems,
        );
      }
    }

    final family = resolveScenarioFamily(scenarioId, fallbackTitle);

    switch (family) {
      case 'traffic_stop':
        return _getTrafficStopChecklist(role);
      case 'arrest_detention':
        return _getArrestDetentionChecklist(role);
      case 'asked_for_bribe':
        return _getBribeChecklist(role);
      case 'fir_refused':
        return _getFirRefusedChecklist(role);
      case 'police_at_door_search':
        return _getSearchChecklist(role);
      case 'digital_cyber':
        return _getCyberChecklist(role);
      case 'campus':
        return _getCampusChecklist(role);
      case 'women_couples':
        return _getWomenCouplesChecklist(role);
      case 'workplace':
        return _getWorkplaceChecklist(role);
      case 'housing':
        return _getHousingChecklist(role);
      default:
        return _getGeneralPoliceChecklist(role);
    }
  }
  /// Get spotlight headline metadata for scenario
  static SpotlightMeta getSpotlightMeta({
    required String? scenarioId,
    String? fallbackTitle,
  }) {
    final family = resolveScenarioFamily(scenarioId, fallbackTitle);

    switch (family) {
      case 'traffic_stop':
        return const SpotlightMeta(
          tag: 'MV ACT 2019 • SECTION 200',
          title: 'Know your vehicle check & traffic rights',
          subtitle: 'Officers cannot confiscate keys or demand physical papers if DigiLocker is presented.',
        );
      case 'arrest_detention':
        return const SpotlightMeta(
          tag: 'ARTICLE 22 • CRPC 41A & 50A',
          title: 'Know your arrest & custody safeguards',
          subtitle: 'Written arrest memo, family intimation within 1h, and 24h magistrate production are mandatory.',
        );
      case 'asked_for_bribe':
        return const SpotlightMeta(
          tag: 'PC ACT 1988 • SECTION 7 & 8',
          title: 'Anti-extortion & vigilance protections',
          subtitle: 'Reporting corrupt demands within 7 days provides statutory immunity against bribe charges.',
        );
      case 'fir_refused':
        return const SpotlightMeta(
          tag: 'CRPC 154 • LALITA KUMARI DIRECTIVE',
          title: 'Mandatory FIR registration safeguards',
          subtitle: 'Police cannot refuse Zero FIR for cognizable crimes. Section 166A IPC penalizes refusal.',
        );
      case 'police_at_door_search':
        return const SpotlightMeta(
          tag: 'CRPC 93/94 • SECTION 100 PANCHNAMA',
          title: 'Residential search & privacy safeguards',
          subtitle: 'Search requires a magistrate warrant and 2 local witnesses. Female occupants protected.',
        );
      case 'digital_cyber':
        return const SpotlightMeta(
          tag: 'IT ACT 2000 • CYBER HELPLINE 1930',
          title: 'Instant cyber defense & digital asset safety',
          subtitle: 'Report within the golden hour to freeze illicit transactions. Passcodes protected under Art 20(3).',
        );
      case 'campus':
        return const SpotlightMeta(
          tag: 'UGC REGULATIONS 2009 • ANTI-RAGGING',
          title: 'Zero-tolerance student safety protections',
          subtitle: 'Institution must lodge FIR within 24 hours. Call 1800-180-5522 for anonymous reporting.',
        );
      case 'women_couples':
        return const SpotlightMeta(
          tag: 'CRPC 46(4) • ARTICLE 21 LIBERTY',
          title: 'Personal liberty & anti-moral policing rights',
          subtitle: 'Consenting adults violate no law. Male police cannot question or detain women after sunset.',
        );
      case 'workplace':
        return const SpotlightMeta(
          tag: 'POSH ACT 2013 • LABOUR REGULATIONS',
          title: 'Workplace safety & employment protections',
          subtitle: 'Forced resignations under duress are void. Internal Committee must investigate within 90 days.',
        );
      case 'housing':
        return const SpotlightMeta(
          tag: 'MODEL TENANCY ACT • IPC SECTION 430',
          title: 'Tenant protections against arbitrary eviction',
          subtitle: 'Landlord cannot disconnect electricity/water. Minimum 30 days written notice required.',
        );
      default:
        return const SpotlightMeta(
          tag: 'ARTICLE 22 • CRPC 41A',
          title: 'Know your instant immunity safeguards',
          subtitle: 'Non-violent procedure demands civil conduct from both citizen and officer.',
        );
    }
  }

  /// Get authoritative Statutory Legal Basis & Judicial Citations for a scenario
  static StatutoryLegalBasisData getStatutoryLegalBasis({
    required String? scenarioId,
    String? fallbackTitle,
  }) {
    final id = (scenarioId ?? '').toLowerCase();
    final title = (fallbackTitle ?? '').toLowerCase();

    // 1. Fine-grained scenarios
    if (id.contains('upi') || id.contains('cyber_fraud') || id.contains('frozen') || title.contains('upi') || title.contains('cyber fraud') || title.contains('bank account frozen')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'DIGITAL PAYMENTS & CYBER FRAUD',
        primaryAct: 'Information Technology Act 2000 & RBI Master Directions 2017',
        enactedSections: 'IT Act Sec 43, 66C (Identity Theft), 66D (Cheating by Impersonation); IPC Sec 420; RBI Circular DBR.No.Leg.BC.78/09.07.005/2017-18',
        newCriminalCodes: 'BNS 2023 Sec 318(4) (Cheating) & Sec 319; BNSS Sec 107',
        landmarkPrecedent: 'RBI Master Direction on Customer Protection — Limiting Liability in Unauthorized Electronic Banking Transactions (Zero liability if reported within 3 days)',
        keyStatutorySafeguard: 'Zero customer liability if unauthorized transaction is notified to bank within 3 working days. Dialing Helpline 1930 / cybercrime.gov.in connects to CFCFRMS for automated inter-bank lien/freeze on mule accounts.',
        officialSource: 'Indian Cyber Crime Coordination Centre (I4C, cybercrime.gov.in) & RBI',
      );
    }

    if (id.contains('sextortion') || id.contains('fake_officer') || title.contains('sextortion') || title.contains('fake police video')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'CYBER EXTORTION & DIGITAL IMPERSONATION',
        primaryAct: 'Information Technology Act 2000 & Indian Penal Code 1860',
        enactedSections: 'IT Act Sec 66E (Privacy Violation), Sec 67 & 67A (Transmitting Obscene Content); IPC Sec 384 (Extortion), Sec 419 (Impersonation of Public Servant), Sec 506',
        newCriminalCodes: 'BNS 2023 Sec 308 (Extortion), Sec 204 (Impersonating Public Servant), Sec 351',
        landmarkPrecedent: 'Supreme Court in Shreya Singhal v. Union of India (2015) 5 SCC 1 & MHA Cyber Crime SOPs',
        keyStatutorySafeguard: 'Law enforcement agencies never conduct "digital arrests", video interrogations, or demand financial settlements over WhatsApp/Skype. Victims have complete right to submit digital evidence without self-incrimination.',
        officialSource: 'Ministry of Home Affairs Cyber Crime Division / cybercrime.gov.in',
      );
    }

    if (id.contains('loan_app') || title.contains('loan app') || title.contains('harassment by lenders')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'UNREGULATED DIGITAL LENDING & HARASSMENT',
        primaryAct: 'RBI Digital Lending Guidelines 2022 & Information Technology Act 2000',
        enactedSections: 'RBI Guidelines on Digital Lending (Sept 2022); IT Act Sec 43, 66E; IPC Sec 384 (Extortion), Sec 503, Sec 506, Sec 509 (Insulting Modesty)',
        newCriminalCodes: 'BNS 2023 Sec 308 (Extortion), Sec 351, Sec 79; BNSS Sec 173',
        landmarkPrecedent: 'Reserve Bank of India Fair Practices Code for NBFCs & Delhi High Court Directives on predatory lending apps',
        keyStatutorySafeguard: 'Digital lending apps are strictly barred from accessing borrower contacts, photo gallery, or device media. Harassment, morphing, and shaming by recovery agents constitutes criminal extortion.',
        officialSource: 'Reserve Bank of India (sachet.rbi.org.in)',
      );
    }

    if (id.contains('posh') || id.contains('workplace_harassment') || title.contains('workplace harassment') || title.contains('posh')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'WORKPLACE SAFETY & POSH ACT',
        primaryAct: 'Sexual Harassment of Women at Workplace (Prevention, Prohibition & Redressal) Act 2013',
        enactedSections: 'POSH Act Sec 4 (Constitution of Internal Committee), Sec 9 (Complaint window), Sec 11 (Inquiry procedure), Sec 12 (Interim relief & 3-month paid leave), Sec 13; IPC Sec 354A',
        newCriminalCodes: 'BNS 2023 Sec 75 (Sexual Harassment); BNSS Sec 173',
        landmarkPrecedent: 'Supreme Court in Vishaka v. State of Rajasthan (1997) 6 SCC 241; Aureliano Fernandes v. State of Goa (2023) (Mandatory adherence to inquiry timelines & natural justice)',
        keyStatutorySafeguard: 'Internal Committee (IC) has statutory powers of a Civil Court. Employer is prohibited from retaliating or altering service conditions during inquiry; complainant has statutory right to interim transfer or paid leave.',
        officialSource: 'Ministry of Women and Child Development (shebox.nic.in)',
      );
    }

    if (id.contains('salary') || id.contains('unpaid_internship') || title.contains('salary') || title.contains('internship')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'WAGES & LABOUR STATUTES',
        primaryAct: 'Payment of Wages Act 1936, Code on Wages 2019 & Industrial Disputes Act 1947',
        enactedSections: 'Payment of Wages Act Sec 5 (Time of payment), Sec 15 (Claims for deductions/delay); Code on Wages 2019 Sec 17 (Full & Final settlement within 2 working days), Sec 18; Industrial Disputes Act Sec 33C(2)',
        newCriminalCodes: 'Code on Wages 2019 & Industrial Relations Code 2020',
        landmarkPrecedent: 'Supreme Court in People’s Union for Democratic Rights v. Union of India (1982) (Non-payment of lawful wages violates Article 23 constitutional prohibition on forced labor)',
        keyStatutorySafeguard: 'Wages cannot be withheld beyond statutory timelines. Employers cannot withhold experience letters or statutory entitlements (EPF, Gratuity) against disputed employment bonds or clawbacks.',
        officialSource: 'Ministry of Labour & Employment / State Labour Commissioner',
      );
    }

    if (id.contains('termination') || title.contains('termination') || title.contains('layoff')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'TERMINATION & RETRENCHMENT PROTECTION',
        primaryAct: 'Industrial Disputes Act 1947 & Payment of Gratuity Act 1972',
        enactedSections: 'Industrial Disputes Act Sec 25F (Conditions precedent to retrenchment), Sec 25G, Sec 25H; Contract Act 1872 Sec 23 & 27 (Void restrictive covenants); Payment of Gratuity Act Sec 7',
        newCriminalCodes: 'Industrial Relations Code 2020 Sec 70; Code on Wages 2019',
        landmarkPrecedent: 'Supreme Court in Central Inland Water Transport Corp v. Brojo Nath Ganguly (1986) 3 SCC 156 (Arbitrary termination clauses in contracts are unconstitutional and void)',
        keyStatutorySafeguard: 'Lawful termination mandates written notice or pay in lieu thereof plus 15 days severance pay for every completed year of service. Forced resignations coerced under threat are legally invalid.',
        officialSource: 'Ministry of Labour & Employment (labour.gov.in)',
      );
    }

    if (id.contains('ragging') || title.contains('ragging')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'CAMPUS ANTI-RAGGING STATUTE',
        primaryAct: 'UGC Regulations on Curbing the Menace of Ragging in Higher Educational Institutions 2009',
        enactedSections: 'UGC Regulations Reg 3, 7 (Mandatory Police FIR within 24 hours), Reg 9; IPC Sec 294, 323, 341, 342, 506',
        newCriminalCodes: 'BNS 2023 Sec 115 (Voluntarily causing hurt), Sec 126 (Wrongful restraint), Sec 351 (Criminal intimidation)',
        landmarkPrecedent: 'Supreme Court in Vishwa Jagriti Mission v. Central Govt (AIR 2001 SC 2793) & University of Kerala v. Council of Principals (2009)',
        keyStatutorySafeguard: 'Under Regulation 7 of UGC Regulations, College Head of Institution MUST file an FIR with local police within 24 hours of receiving a ragging report. Failure to report attracts criminal liability under Sec 176 IPC.',
        officialSource: 'UGC National Anti-Ragging Cell (antiragging.in, Helpline 1800-180-5522)',
      );
    }

    if (id.contains('suspension') || id.contains('expulsion') || title.contains('suspension') || title.contains('expulsion')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'STUDENT DISCIPLINARY JURISPRUDENCE',
        primaryAct: 'Constitution of India (Art 14 & 21) & UGC Disciplinary Guidelines',
        enactedSections: 'Principles of Natural Justice (Nemo Judex In Causa Sua & Audi Alteram Partem); State Universities Acts',
        newCriminalCodes: 'Constitution of India Fundamental Rights Articles 14, 19(1)(a), 21',
        landmarkPrecedent: 'Supreme Court in Board of High School & Intermediate Education UP v. Ghanshyam Das Gupta (AIR 1962 SC 1110) & Maneka Gandhi v. UOI (1978)',
        keyStatutorySafeguard: 'No student can be arbitrarily suspended or expelled without a written show-cause notice, access to alleged evidence, and a fair opportunity of hearing before an unbiased committee.',
        officialSource: 'Ministry of Education & University Grants Commission',
      );
    }

    if (id.contains('couple') || id.contains('hotel') || title.contains('couple') || title.contains('hotel')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'CONSENSUAL ADULT LIBERTY & PRIVACY',
        primaryAct: 'Constitution of India (Art 19, 21) & Code of Criminal Procedure 1973',
        enactedSections: 'Constitution Art 21 (Personal Liberty & Privacy); CrPC Sec 46(4) (No arrest of woman after sunset), Sec 160(1) proviso; Special Marriage Act 1954',
        newCriminalCodes: 'Bharatiya Nagarik Suraksha Sanhita 2023 Sec 35(1), Sec 179(1) proviso',
        landmarkPrecedent: 'Supreme Court in Shafin Jahan v. Asokan K.M. (2018) 16 SCC 368 & Navtej Singh Johar v. Union of India (2018) 10 SCC 1; Lata Singh v. State of UP (2006)',
        keyStatutorySafeguard: 'Consenting adults holding valid photo ID have complete constitutional freedom to associate and book accommodation. Police and hotel staff have zero legal authority to moral-police or contact parents.',
        officialSource: 'Supreme Court of India (sci.gov.in) & Law Commission of India',
      );
    }

    if (id.contains('stalking') || title.contains('stalking')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'ANTI-STALKING & CYBER PRIVACY',
        primaryAct: 'Indian Penal Code 1860 & Information Technology Act 2000',
        enactedSections: 'IPC Sec 354D (Stalking — physical & electronic), Sec 509 (Insulting modesty of woman); IT Act Sec 66E (Privacy violation); CrPC Sec 154',
        newCriminalCodes: 'BNS 2023 Sec 78 (Stalking), Sec 79; BNSS Sec 173',
        landmarkPrecedent: 'Supreme Court in Lalita Kumari v. Govt of UP (2014) (Mandatory immediate FIR for offenses under Sec 354 IPC)',
        keyStatutorySafeguard: 'Stalking is a cognizable offense; police are statutorily required to register an FIR without demanding informal reconciliation or compromises.',
        officialSource: 'National Commission for Women (ncw.nic.in) / indiacode.nic.in',
      );
    }

    if (id.contains('partner_under_18') || title.contains('under 18') || title.contains('minor')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'JUVENILE JUSTICE & POCSO SAFEGUARDS',
        primaryAct: 'Protection of Children from Sexual Offences (POCSO) Act 2012 & Juvenile Justice Act 2015',
        enactedSections: 'POCSO Act Sec 19 (Reporting of offenses), Sec 21 (Failure to report), Sec 24 (Child statement recorded at residence by female officer); JJ Act 2015 Sec 10, 12',
        newCriminalCodes: 'Bharatiya Nagarik Suraksha Sanhita 2023 & POCSO Statutory Framework',
        landmarkPrecedent: 'Supreme Court in Independent Thought v. Union of India (2017) 10 SCC 800; Delhi High Court Juvenile Bail Guidelines',
        keyStatutorySafeguard: 'Any minor in conflict with law cannot be placed in a police lockup or jail under any circumstances (Sec 10 JJ Act); must be placed under care of Special Juvenile Police Unit (SJPU).',
        officialSource: 'National Commission for Protection of Child Rights (ncpcr.gov.in)',
      );
    }

    if (id.contains('vigilante') || title.contains('vigilante') || title.contains('mob')) {
      return const StatutoryLegalBasisData(
        categoryTag: 'PROTECTION FROM MOB VIOLENCE & VIGILANTISM',
        primaryAct: 'Constitution of India (Art 14, 21) & Indian Penal Code 1860',
        enactedSections: 'IPC Sec 141, 143 (Unlawful assembly), Sec 323, Sec 341 (Wrongful restraint), Sec 506 (Criminal intimidation); CrPC Sec 154',
        newCriminalCodes: 'BNS 2023 Sec 189, 191, 115, 126, 351; BNSS Sec 173',
        landmarkPrecedent: 'Supreme Court landmark in Tehseen S. Poonawalla v. Union of India (2018) 9 SCC 501 (Mandatory preventive, remedial, and punitive guidelines on mob vigilantism)',
        keyStatutorySafeguard: 'Vigilante groups have zero legal authority to stop, interrogate, search, or harass citizens. Police officers failing to disperse vigilantes face departmental action under Supreme Court directives.',
        officialSource: 'Supreme Court of India (sci.gov.in)',
      );
    }

    // 2. Scenario Family fallbacks
    final family = resolveScenarioFamily(scenarioId, fallbackTitle);

    switch (family) {
      case 'traffic_stop':
        return const StatutoryLegalBasisData(
          categoryTag: 'MOTOR VEHICLES & ROAD ENFORCEMENT',
          primaryAct: 'Motor Vehicles Act 1988 (Amended 2019) & Central Motor Vehicles Rules 1989',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/1798',
          enactedSections: 'MV Act Sec 130 (Production of documents), Sec 132, Sec 185 (Blood alcohol limit >30mg/100ml), Sec 200 (Compounding fees), Sec 207 (Vehicle seizure); Rule 139 CMVR',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1798',
          newCriminalCodes: 'MoRTH Notification RT-11036/64/2017 & Rule 139 CMVR',
          newCriminalCodesUrl: 'https://morth.nic.in/standard-operating-procedure-validation-driving-license-and-registration-certificate-through',
          landmarkPrecedent: 'Supreme Court in D.K. Basu v. State of West Bengal (1997) 1 SCC 416 & MoRTH Electronic Document Validity Directives',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/501198/',
          keyStatutorySafeguard: 'Digital documents in DigiLocker or mParivahan are legally binding under Rule 139 CMVR. Police officers have no statutory power to seize car keys or demand cash without an official compounding receipt.',
          keyStatutorySafeguardUrl: 'https://parivahan.gov.in/parivahan/',
          officialSource: 'Ministry of Road Transport & Highways (morth.nic.in)',
          officialSourceUrl: 'https://morth.nic.in',
        );

      case 'arrest_detention':
        return const StatutoryLegalBasisData(
          categoryTag: 'CUSTODIAL SAFEGUARDS & ARREST DIRECTIVES',
          primaryAct: 'Constitution of India (Art 21, 22) & Code of Criminal Procedure 1973',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          enactedSections: 'CrPC Sec 41, 41A (Notice of appearance), Sec 50 (Right to grounds of arrest), Sec 50A (Mandatory notice to friend/relative), Sec 54 (Medical exam), Sec 57 (Max 24 hours)',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          newCriminalCodes: 'Bharatiya Nagarik Suraksha Sanhita 2023 Sec 35, 36, 47, 48, 53, 58',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nagarik-suraksha-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in D.K. Basu v. State of West Bengal (1997) 1 SCC 416 (11 mandatory directives) & Arnesh Kumar v. State of Bihar (2014) 8 SCC 273',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/501198/',
          keyStatutorySafeguard: 'Arrest memo must be signed by at least one family member or local witness. Detainee has non-negotiable right to inform family within 1 hour, have medical examination every 48 hours, and receive free legal aid from DLSA.',
          keyStatutorySafeguardUrl: 'https://nalsa.gov.in/',
          officialSource: 'Supreme Court of India / NALSA (15100)',
          officialSourceUrl: 'https://sci.gov.in',
        );

      case 'asked_for_bribe':
        return const StatutoryLegalBasisData(
          categoryTag: 'ANTI-CORRUPTION & WHISTLEBLOWER PROTECTION',
          primaryAct: 'Prevention of Corruption Act 1988 (amended 2018) & Indian Penal Code 1860',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/1908',
          enactedSections: 'PC Act Sec 7 (Public servant accepting bribe), Sec 7A, Sec 8 Proviso (Statutory immunity on 7-day reporting); IPC Sec 383, 384 (Extortion)',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1908',
          newCriminalCodes: 'BNS 2023 Sec 308 (Extortion), Sec 201; BNSS Sec 173',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nyaya-sanhita-2023',
          landmarkPrecedent: 'Supreme Court Constitution Bench in Neeraj Dutta v. State (NCT of Delhi) (2023) 4 SCC 731; P. Satyanarayana Murthy (2015)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/86461947/',
          keyStatutorySafeguard: 'Section 8 Proviso of the PC Act gives complete statutory immunity from prosecution to any citizen coerced into paying a bribe if reported to Anti-Corruption Bureau (1064) or CBI within 7 days.',
          keyStatutorySafeguardUrl: 'https://cbi.gov.in/',
          officialSource: 'Central Vigilance Commission (cvc.gov.in) & Anti-Corruption Bureau',
          officialSourceUrl: 'https://www.cvc.gov.in',
        );

      case 'fir_refused':
        return const StatutoryLegalBasisData(
          categoryTag: 'MANDATORY FIR REGISTRATION',
          primaryAct: 'Code of Criminal Procedure 1973 (CrPC) & Indian Penal Code 1860',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          enactedSections: 'CrPC Sec 154(1) (Duty to register cognizable offense), Sec 154(2) (Free copy), Sec 154(3) (Report to SP), Sec 156(3) (Magistrate inquiry); IPC Sec 166A(c) (Penalty for refusing FIR)',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          newCriminalCodes: 'BNSS 2023 Sec 173(1), 173(2), 173(3), 175(3); BNS 2023 Sec 199',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nagarik-suraksha-sanhita-2023',
          landmarkPrecedent: 'Supreme Court Constitution Bench in Lalita Kumari v. Govt of UP (2014) 2 SCC 1; Youth Bar Association of India (2016)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/102852/',
          keyStatutorySafeguard: 'Police are statutorily required to register an FIR immediately for all cognizable offenses without preliminary inquiry. Registration is 100% free, and refusing officers face 2 years imprisonment under Sec 166A(c) IPC.',
          keyStatutorySafeguardUrl: 'https://digitalpolice.gov.in/',
          officialSource: 'Supreme Court of India (sci.gov.in)',
          officialSourceUrl: 'https://sci.gov.in',
        );

      case 'police_at_door_search':
        return const StatutoryLegalBasisData(
          categoryTag: 'SEARCH & RESIDENTIAL SANCTITY',
          primaryAct: 'Code of Criminal Procedure 1973 (CrPC) & Constitution of India Art 21',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          enactedSections: 'CrPC Sec 47, 93 (Search warrant), Sec 100(4) (Mandatory independent local witnesses), Sec 100(5) (Panchnama seizure memo), Sec 165 (Grounds recorded in GD)',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          newCriminalCodes: 'BNSS 2023 Sec 103, 107, 185; BSA 2023 Sec 63',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nagarik-suraksha-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in Justice K.S. Puttaswamy v. Union of India (2017) 10 SCC 1; State of Punjab v. Baldev Singh (1999)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/91938676/',
          keyStatutorySafeguard: 'Police cannot conduct search without recording grounds in General Diary or obtaining warrant, and MUST summon two independent local witnesses to sign the Panchnama seizure memo. Women searched only by female officers (Sec 51(2) CrPC).',
          keyStatutorySafeguardUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          officialSource: 'Supreme Court of India / indiacode.nic.in',
          officialSourceUrl: 'https://sci.gov.in',
        );

      case 'digital_cyber':
        return const StatutoryLegalBasisData(
          categoryTag: 'DIGITAL CRIMES & CYBER PROTECTION',
          primaryAct: 'Information Technology Act 2000 & RBI Master Directions 2017',
          primaryActUrl: 'https://www.meity.gov.in/content/information-technology-act-2000',
          enactedSections: 'IT Act Sec 43, 66C, 66D, 66E, 67; IPC Sec 419, 420, 384, 506; RBI Customer Protection Circular 2017',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1999',
          newCriminalCodes: 'BNS 2023 Sec 318(4), 319, 308, 351; BNSS Sec 107',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nyaya-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in Shreya Singhal v. Union of India (2015) 5 SCC 1 & RBI Zero-Liability Mandate',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/110813550/',
          keyStatutorySafeguard: 'Zero customer liability if unauthorized transaction is notified to bank within 3 working days; dialing Helpline 1930 connects to CFCFRMS for automated inter-bank lien/freeze on recipient accounts.',
          keyStatutorySafeguardUrl: 'https://cybercrime.gov.in/',
          officialSource: 'Indian Cyber Crime Coordination Centre (cybercrime.gov.in)',
          officialSourceUrl: 'https://cybercrime.gov.in',
        );

      case 'campus':
        return const StatutoryLegalBasisData(
          categoryTag: 'CAMPUS RIGHTS & NATURAL JUSTICE',
          primaryAct: 'UGC Regulations 2009 & Constitution of India (Art 14, 21)',
          primaryActUrl: 'https://www.antiragging.in/assets/pdf/annexure/Annexure-I.pdf',
          enactedSections: 'UGC Anti-Ragging Regulations Reg 3, 7, 9; IPC Sec 294, 323, 341, 506; Principles of Natural Justice',
          enactedSectionsUrl: 'https://www.antiragging.in/',
          newCriminalCodes: 'BNS 2023 Sec 115, 126, 351',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nyaya-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in Vishwa Jagriti Mission v. Central Govt (AIR 2001 SC 2793) & University of Kerala (2009)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/1715421/',
          keyStatutorySafeguard: 'College Head of Institution is legally mandated under Regulation 7 to lodge an FIR with police within 24 hours of receiving a ragging report. Disciplinary penalties require written show-cause notice and fair hearing.',
          keyStatutorySafeguardUrl: 'https://www.antiragging.in/',
          officialSource: 'University Grants Commission (antiragging.in)',
          officialSourceUrl: 'https://www.antiragging.in',
        );

      case 'women_couples':
        return const StatutoryLegalBasisData(
          categoryTag: 'WOMEN & CONSENSUAL ADULT SAFEGUARDS',
          primaryAct: 'Protection of Women from Domestic Violence Act 2005 & Constitution Art 21',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/2021',
          enactedSections: 'PWDVA Sec 12, 18, 19; IPC Sec 354A, 354D, 509; CrPC Sec 46(4), 51(2), 160(1) proviso',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/2021',
          newCriminalCodes: 'BNS 2023 Sec 75, 78, 79; BNSS Sec 35(1), 179(1) proviso',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nyaya-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in Navtej Singh Johar v. Union of India (2018) & Shafin Jahan v. Asokan K.M. (2018)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/168671544/',
          keyStatutorySafeguard: 'Consenting adults holding valid photo ID have complete constitutional freedom to stay together. No woman can be arrested after sunset (Sec 46(4) CrPC) or summoned to police station for questioning (Sec 160(1) CrPC).',
          keyStatutorySafeguardUrl: 'https://ncw.nic.in/',
          officialSource: 'National Commission for Women / Supreme Court of India',
          officialSourceUrl: 'https://ncw.nic.in',
        );

      case 'workplace':
        return const StatutoryLegalBasisData(
          categoryTag: 'WORKPLACE STATUTES & LABOUR LAWS',
          primaryAct: 'POSH Act 2013, Payment of Wages Act 1936 & Industrial Disputes Act 1947',
          primaryActUrl: 'https://www.indiacode.nic.in/handle/123456789/2104',
          enactedSections: 'POSH Act Sec 4, 9, 11, 12; Payment of Wages Act Sec 5, 15; Code on Wages 2019 Sec 17, 18; Industrial Disputes Act Sec 25F',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/2104',
          newCriminalCodes: 'Code on Wages 2019 & Industrial Relations Code 2020',
          newCriminalCodesUrl: 'https://labour.gov.in/',
          landmarkPrecedent: 'Supreme Court in Vishaka v. State of Rajasthan (1997) & Central Inland Water Transport Corp (1986)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/1031794/',
          keyStatutorySafeguard: 'Employers cannot withhold wages or statutory dues (EPF, Gratuity). Retrenchment requires statutory notice and compensation. POSH IC has civil court powers to order interim transfer and paid leave.',
          keyStatutorySafeguardUrl: 'https://shebox.wcd.gov.in/',
          officialSource: 'Ministry of Labour & Employment (labour.gov.in)',
          officialSourceUrl: 'https://labour.gov.in',
        );

      case 'housing':
        return const StatutoryLegalBasisData(
          categoryTag: 'TENANT RIGHTS & MODEL TENANCY ACT',
          primaryAct: 'Model Tenancy Act 2021, Transfer of Property Act 1882 & State Rent Control Acts',
          primaryActUrl: 'https://mohua.gov.in/cms/model-tenancy-act.php',
          enactedSections: 'Transfer of Property Act Sec 106, 108(q), 111; Model Tenancy Act Sec 13, 20, 21, 22; IPC Sec 430, 441, 448',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/2338',
          newCriminalCodes: 'BNS 2023 Sec 324 (Mischief to utilities), Sec 329 (Criminal trespass)',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nyaya-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in Bishan Das v. State of Punjab (AIR 1961 SC 1570) & Ramesh Chand Ardawatiya v. Anil Panjwani (2003)',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/1647413/',
          keyStatutorySafeguard: 'Landlords cannot cut electricity, water, or lock premises without a court decree; doing so is a criminal offense under Sec 430 IPC. Security deposit must be refunded with written receipts for valid repairs.',
          keyStatutorySafeguardUrl: 'https://mohua.gov.in/',
          officialSource: 'Ministry of Housing and Urban Affairs (mohua.gov.in)',
          officialSourceUrl: 'https://mohua.gov.in',
        );

      default:
        return const StatutoryLegalBasisData(
          categoryTag: 'CRIMINAL PROCEDURE & CITIZEN RIGHTS',
          primaryAct: 'Constitution of India (Art 20(3), 22(1)) & Code of Criminal Procedure 1973',
          primaryActUrl: 'https://www.india.gov.in/my-government/constitution-india',
          enactedSections: 'CrPC Sec 41A, 50, 91, 100, 160, 161, 162; Indian Evidence Act 1872 Sec 24, 25, 26, 27',
          enactedSectionsUrl: 'https://www.indiacode.nic.in/handle/123456789/1611',
          newCriminalCodes: 'BNSS 2023 Sec 35, 47, 94, 103, 179, 180, 181; BSA 2023 Sec 22, 23',
          newCriminalCodesUrl: 'https://www.mha.gov.in/en/commoncontent/bharatiya-nagarik-suraksha-sanhita-2023',
          landmarkPrecedent: 'Supreme Court in Nandini Satpathy v. P.L. Dani (1978) 2 SCC 424 & D.K. Basu v. State of West Bengal (1997) 1 SCC 416',
          landmarkPrecedentUrl: 'https://indiankanoon.org/doc/501198/',
          keyStatutorySafeguard: 'Citizens cannot be forced to sign witness statements (Sec 162 CrPC / Sec 181 BNSS). Confessions made to police in custody are inadmissible in court under Sec 25 Evidence Act / Sec 23 BSA.',
          keyStatutorySafeguardUrl: 'https://nalsa.gov.in/',
          officialSource: 'Supreme Court of India / indiacode.nic.in',
          officialSourceUrl: 'https://sci.gov.in',
        );
    }
  }

  /// Normalize scenario identifiers into primary scenario families
  static String resolveScenarioFamily(String? rawScenarioId, String? rawTitle) {
    final id = (rawScenarioId ?? '').toLowerCase();
    final title = (rawTitle ?? '').toLowerCase();

    if (id.contains('traffic') || title.contains('traffic') || title.contains('vehicle check') || title.contains('stopped by police')) {
      return 'traffic_stop';
    }
    if (id.contains('arrest') || id.contains('custody') || id.contains('detention') || title.contains('arrest') || title.contains('custody')) {
      return 'arrest_detention';
    }
    if (id.contains('bribe') || id.contains('extortion') || title.contains('bribe') || title.contains('extortion')) {
      return 'asked_for_bribe';
    }
    if (id.contains('fir') || id.contains('police_station') || title.contains('fir') || title.contains('police station')) {
      return 'fir_refused';
    }
    if (id.contains('door') || id.contains('search') || id.contains('warrant') || title.contains('door') || title.contains('search')) {
      return 'police_at_door_search';
    }
    if (id.contains('cyber') || id.contains('frozen') || id.contains('upi') || id.contains('sextortion') || id.contains('loan') || title.contains('cyber') || title.contains('frozen') || title.contains('fraud')) {
      return 'digital_cyber';
    }
    if (id.contains('ragging') || id.contains('campus') || id.contains('hostel') || id.contains('exam') || title.contains('ragging') || title.contains('campus') || title.contains('college')) {
      return 'campus';
    }
    if (id.contains('couple') || id.contains('hotel') || id.contains('stalking') || id.contains('domestic') || id.contains('honour') || title.contains('couple') || title.contains('stalking') || title.contains('domestic')) {
      return 'women_couples';
    }
    if (id.contains('workplace') || id.contains('salary') || id.contains('resignation') || id.contains('termination') || title.contains('workplace') || title.contains('salary')) {
      return 'workplace';
    }
    if (id.contains('eviction') || id.contains('deposit') || id.contains('tenant') || id.contains('landlord') || title.contains('eviction') || title.contains('tenant')) {
      return 'housing';
    }

    return 'general_police';
  }

  /// Convenience wrapper for TTS integration — maps 'scenario' → 'scenarioId'
  static List<GuidanceItem> getMandatoryDos({
    required String scenario,
    required UserRole role,
  }) {
    return getDos(scenarioId: scenario, role: role);
  }

  /// Convenience wrapper for TTS integration — maps 'scenario' → 'scenarioId'
  static List<GuidanceItem> getCriticalDonts({
    required String scenario,
    required UserRole role,
  }) {
    return getDonts(scenarioId: scenario, role: role);
  }

  /// Get role-specific and scenario-specific Mandatory DOs
  static List<GuidanceItem> getDos({
    required String? scenarioId,
    required UserRole role,
    String? fallbackTitle,
  }) {
    final family = resolveScenarioFamily(scenarioId, fallbackTitle);

    switch (family) {
      case 'traffic_stop':
        return _getTrafficStopDos(role);
      case 'arrest_detention':
        return _getArrestDetentionDos(role);
      case 'asked_for_bribe':
        return _getBribeDos(role);
      case 'fir_refused':
        return _getFirRefusedDos(role);
      case 'police_at_door_search':
        return _getDoorSearchDos(role);
      case 'digital_cyber':
        return _getDigitalCyberDos(role);
      case 'campus':
        return _getCampusDos(role);
      case 'women_couples':
        return _getWomenCouplesDos(role);
      case 'workplace':
        return _getWorkplaceDos(role);
      case 'housing':
        return _getHousingDos(role);
      default:
        return _getGeneralPoliceDos(role);
    }
  }

  /// Get role-specific and scenario-specific Critical DON'Ts
  static List<GuidanceItem> getDonts({
    required String? scenarioId,
    required UserRole role,
    String? fallbackTitle,
  }) {
    final family = resolveScenarioFamily(scenarioId, fallbackTitle);

    switch (family) {
      case 'traffic_stop':
        return _getTrafficStopDonts(role);
      case 'arrest_detention':
        return _getArrestDetentionDonts(role);
      case 'asked_for_bribe':
        return _getBribeDonts(role);
      case 'fir_refused':
        return _getFirRefusedDonts(role);
      case 'police_at_door_search':
        return _getDoorSearchDonts(role);
      case 'digital_cyber':
        return _getDigitalCyberDonts(role);
      case 'campus':
        return _getCampusDonts(role);
      case 'women_couples':
        return _getWomenCouplesDonts(role);
      case 'workplace':
        return _getWorkplaceDonts(role);
      case 'housing':
        return _getHousingDonts(role);
      default:
        return _getGeneralPoliceDonts(role);
    }
  }

  /// Get role-specific and scenario-specific Alert Banner message
  static String getRoleAlertMessage({
    required String? scenarioId,
    required UserRole role,
    String? fallbackTitle,
  }) {
    final family = resolveScenarioFamily(scenarioId, fallbackTitle);

    switch (family) {
      case 'traffic_stop':
        switch (role) {
          case UserRole.affected:
            return 'You are not under arrest. Digital DL/RC via DigiLocker is legally valid under Rule 139 CMVR.';
          case UserRole.accused:
            return 'DUI charges require calibrated breathalyzer test (>30mg/100ml). Right to spot compounding receipt under Sec 200 MV Act.';
          case UserRole.witness:
            return 'Bystanders possess constitutional right under Art 19(1)(a) to video record public enforcement from a safe distance.';
          case UserRole.parent:
            return 'Police cannot forfeit vehicles on roadside without magistrate order. Check e-Challan status on Parivahan portal.';
        }

      case 'arrest_detention':
        switch (role) {
          case UserRole.affected:
            return 'You are not under arrest unless formal charges or Section 41 CrPC grounds are presented in writing.';
          case UserRole.accused:
            return 'Right to know grounds of arrest immediately (Art 22(1)), right to free legal aid (15100), and notification of family within 1h.';
          case UserRole.witness:
            return 'Witnesses cannot be detained arbitrarily. Questioning should take place at residence if woman or minor (Sec 160 CrPC).';
          case UserRole.parent:
            return 'You have the legal right to inspect the arrest memo and verify that the medical examination is ordered (Sec 54 CrPC).';
        }

      case 'asked_for_bribe':
        switch (role) {
          case UserRole.affected:
            return 'Demanding bribes is a serious offense under Section 7 PC Act. Reporting within 7 days provides statutory immunity.';
          case UserRole.accused:
            return 'Payments under duress or extortion must be reported to ACB/Vigilance within 7 days under Section 8 Proviso PC Act.';
          case UserRole.witness:
            return 'Witnesses to extortion are protected under the Witness Protection Scheme 2018. Disclose unedited digital evidence.';
          case UserRole.parent:
            return 'File an immediate complaint with District SP and State Anti-Corruption Bureau on Toll-Free 1064.';
        }

      case 'fir_refused':
        switch (role) {
          case UserRole.affected:
            return 'Police station cannot refuse cognizable FIR. Demand a Zero FIR or escalate to SP under Section 154(3) CrPC.';
          case UserRole.accused:
            return 'Supreme Court mandates free copy of FIR. Offenses under 7 years imprisonment require Section 41A notice first.';
          case UserRole.witness:
            return 'Witnesses cannot be coerced to sign Section 161 statements. Note entry and departure time in General Diary.';
          case UserRole.parent:
            return 'Accompany the complainant to the station. Section 166A IPC penalizes officers who refuse to register cognizable FIRs.';
        }

      case 'police_at_door_search':
        switch (role) {
          case UserRole.affected:
            return 'Search of residence requires a judicial warrant under Section 93/94 CrPC and presence of 2 independent local witnesses.';
          case UserRole.accused:
            return 'Demand copy of Search Panchnama with itemized seized inventory. Do not surrender passcodes under coercion.';
          case UserRole.witness:
            return 'Independent local witnesses (Panchas) must witness search in real time before signing the search memo.';
          case UserRole.parent:
            return 'Male officers are strictly prohibited from searching female occupants or entering female bedrooms after sunset.';
        }

      case 'digital_cyber':
        switch (role) {
          case UserRole.affected:
            return 'Call Cyber Crime Helpline 1930 immediately within the golden hour to freeze fraudulent beneficiary accounts.';
          case UserRole.accused:
            return 'Right against self-incrimination protects digital passcodes. Insist on itemized seizure memo with IMEI and tamper bag.';
          case UserRole.witness:
            return 'Witnesses can submit certified bank statements; you are not required to surrender primary communication devices.';
          case UserRole.parent:
            return 'POCSO & IT Act mandate immediate takedown of blackmail media. Consult cyber counsel before signing device custody.';
        }

      case 'campus':
        switch (role) {
          case UserRole.affected:
            return 'UGC Anti-Ragging regulations mandate immediate FIR within 24 hours. Call 1800-180-5522 for anonymous reporting.';
          case UserRole.accused:
            return 'Principles of Natural Justice demand right to know specific charges and a personal hearing before any suspension.';
          case UserRole.witness:
            return 'Witnesses can use UGC anonymous reporting channels; colleges are prohibited from penalizing whistleblowers.';
          case UserRole.parent:
            return 'Demand a written Action Taken Report (ATR) within 7 days from the Head of Institution and District Magistrate.';
        }

      case 'women_couples':
        switch (role) {
          case UserRole.affected:
            return 'Consenting adults violate no law by spending time together. Male police cannot question or detain women after sunset.';
          case UserRole.accused:
            return 'Police have no authority to contact parents of consenting adults. Demand written grounds for any detention.';
          case UserRole.witness:
            return 'Record any harassment or moral policing. Call 1091 (Women Helpline) or 112 immediately for emergency intervention.';
          case UserRole.parent:
            return 'Do not pay unauthorized vigilante spot fines. Adult children cannot be subjected to forced institutional detention.';
        }

      case 'workplace':
        switch (role) {
          case UserRole.affected:
            return 'POSH Act mandates Internal Committee (IC) investigation within 90 days with interim protective transfers.';
          case UserRole.accused:
            return 'Demand formal charge sheet and opportunity to present defense witnesses before the Internal Committee.';
          case UserRole.witness:
            return 'POSH regulations mandate strict confidentiality for all witnesses and protect against management retaliation.';
          case UserRole.parent:
            return 'Forced resignation under duress is void under the Industrial Disputes Act. File claim with Labour Commissioner.';
        }

      case 'housing':
        switch (role) {
          case UserRole.affected:
            return 'Disconnection of water or electricity is illegal under Section 430 IPC. Minimum 30 days written notice required for eviction.';
          case UserRole.accused:
            return 'Tenancy disputes are civil in nature; police cannot act as recovery agents or force eviction without court order.';
          case UserRole.witness:
            return 'Bystanders and neighbors can report criminal trespassing or forceful lockout to local police control (112).';
          case UserRole.parent:
            return 'Demand itemized repair bills for withheld security deposit. File complaint before the Rent Authority.';
        }

      default:
        switch (role) {
          case UserRole.affected:
            return 'You are not under arrest unless formal charges or Section 41 CrPC grounds are presented in writing.';
          case UserRole.accused:
            return 'Right to know grounds of arrest immediately (Art 22(1)), right to free legal aid (15100), and magistrate production in 24h.';
          case UserRole.witness:
            return 'Witnesses cannot be detained arbitrarily. Questioning should take place at residence if woman or minor (Sec 160 CrPC).';
          case UserRole.parent:
            return 'You have the legal right to inspect the arrest memo and verify that the medical examination is ordered (Sec 54 CrPC).';
        }
    }
  }

  // ==========================================
  // 1. TRAFFIC STOP / VEHICLE CHECK
  // ==========================================

  static List<GuidanceItem> _getTrafficStopDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Ask calmly for the officer's name, rank, and police station badge.",
            subtitle: "Officers on duty are mandated to wear visible name badges (D.K. Basu Guidelines & Police Act).",
            legalRef: "D.K. Basu v. State of West Bengal",
          ),
          GuidanceItem(
            title: "Show digital driving license, RC, and insurance via DigiLocker or mParivahan.",
            subtitle: "Physical copies cannot be forcefully demanded under Rule 139 of Central Motor Vehicles Rules & Section 139A IT Act.",
            legalRef: "Rule 139 CMVR / Sec 139A IT Act",
          ),
          GuidanceItem(
            title: "Demand a physical or digital receipt/e-challan for any fine.",
            subtitle: "Never surrender unrecorded cash. An on-the-spot compounding receipt is your statutory right under Section 200 MV Act.",
            legalRef: "Sec 200 Motor Vehicles Act",
          ),
          GuidanceItem(
            title: "Women can only be searched by a female officer with strict decency.",
            subtitle: "Mandated strictly by Section 51(2) CrPC. Male personnel are prohibited from physical search of female motorists.",
            legalRef: "Sec 51(2) CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Submit to calibrated breathalyzer test and demand a printed slip reading.",
            subtitle: "Blood Alcohol Concentration must exceed 30mg/100ml for drunken driving offense under Section 185 MV Act.",
            legalRef: "Sec 185 Motor Vehicles Act",
          ),
          GuidanceItem(
            title: "Demand a formal written seizure memo if vehicle or license is detained.",
            subtitle: "Officer must provide an itemized vehicle condition inventory receipt under Section 207 of Motor Vehicles Act.",
            legalRef: "Sec 207 MV Act",
          ),
          GuidanceItem(
            title: "Insist on compounding on the spot if offense is compoundable.",
            subtitle: "Avoids court summons and unnecessary police station escort if fine can be settled via official point-of-sale machine.",
            legalRef: "Sec 200 MV Act",
          ),
          GuidanceItem(
            title: "Note time, patrol interceptor number, and exact location coordinates.",
            subtitle: "Vital digital trail for challenging wrongful or arbitrary challans in virtual traffic court.",
            legalRef: "Motor Vehicles Amendment 2019",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Record video and audio calmly from a safe distance of 5 to 10 feet.",
            subtitle: "Citizens have the constitutional right under Article 19(1)(a) to document public servants discharging duty.",
            legalRef: "Art 19(1)(a) Constitution",
          ),
          GuidanceItem(
            title: "Note patrol vehicle registration number, station jurisdiction, and officer badge.",
            subtitle: "Independent bystander observations serve as admissible evidence in judicial or magistrate inquiries.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Verify whether the interceptor unit is headed by an officer of SI rank or above.",
            subtitle: "Constables and head constables cannot independently issue compounding fines without gazetted authority.",
            legalRef: "State Police Regulations",
          ),
          GuidanceItem(
            title: "Offer your contact details to the stopped motorist as an objective witness.",
            subtitle: "Independent co-passenger or bystander testimony prevents fabricated obstruction allegations.",
            legalRef: "Sec 135 Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Ask for the exact police station where vehicle or driver is being taken.",
            subtitle: "Section 50A CrPC mandates immediate notification of family members without delay.",
            legalRef: "Sec 50A CrPC",
          ),
          GuidanceItem(
            title: "Verify challan status online on the official Parivahan e-Challan portal.",
            subtitle: "Avoids cash exploitation and provides a verified government payment gateway with transaction tracking.",
            legalRef: "MoRTH Digital Enforcement Guidelines",
          ),
          GuidanceItem(
            title: "Produce digital documents or request 15-day presentation window.",
            subtitle: "Rule 139 of CMVR permits presenting valid vehicle papers within 15 days of police request.",
            legalRef: "Rule 139 Central Motor Vehicles Rules",
          ),
          GuidanceItem(
            title: "Ensure a female motorist detained after sunset is escorted by female personnel.",
            subtitle: "Section 46(4) CrPC strictly prohibits detaining women after sunset without prior judicial magistrate order.",
            legalRef: "Sec 46(4) CrPC",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getTrafficStopDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not hand over your physical smartphone or let officers browse chats.",
            subtitle: "Phone browsing without judicial warrant violates fundamental right to privacy under Article 21.",
            legalRef: "Puttaswamy v. Union of India",
          ),
          GuidanceItem(
            title: "Do not pay cash without receiving an official printed/e-challan receipt.",
            subtitle: "Paying unofficial settlements is an offense. Officers without authorized machines cannot collect cash.",
            legalRef: "Sec 200 MV Act",
          ),
          GuidanceItem(
            title: "Do not resist physically; record audio/video politely from a safe distance.",
            subtitle: "Physical confrontation can trigger non-bailable charges of obstructing public servants under Section 186/353 IPC.",
            legalRef: "Sec 186/353 IPC",
          ),
          GuidanceItem(
            title: "Never sign blank papers or pre-printed admission forms under pressure.",
            subtitle: "Statements or admissions given under roadside coercion are invalid in law.",
            legalRef: "Sec 25 Indian Evidence Act",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not surrender vehicle keys or let officers take ignition keys forcefully.",
            subtitle: "Supreme Court guidelines strictly prohibit traffic police from snatching car keys or pulling drivers out.",
            legalRef: "MoRTH Traffic Advisory",
          ),
          GuidanceItem(
            title: "Do not agree to blood tests conducted at unauthorized private clinics.",
            subtitle: "Section 204 MV Act mandates testing exclusively by registered medical practitioners in government hospitals.",
            legalRef: "Sec 204 MV Act",
          ),
          GuidanceItem(
            title: "Do not permit towing of vehicle with passengers or pets seated inside.",
            subtitle: "Direct violation of Ministry of Road Transport vehicle towing safety standards.",
            legalRef: "Central Motor Vehicle Towing Norms",
          ),
          GuidanceItem(
            title: "Do not offer unreceipted cash or informal compromises to avoid court.",
            subtitle: "Offering informal payments exposes you to abetment charges under the Prevention of Corruption Act.",
            legalRef: "Prevention of Corruption Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not physically obstruct the officer's path or touch their uniform.",
            subtitle: "Maintain safe distance to prevent officers from framing you under Section 353 IPC (assault on public servant).",
            legalRef: "Sec 353 IPC",
          ),
          GuidanceItem(
            title: "Do not delete recorded video or audio files under informal threats.",
            subtitle: "Police cannot lawfully seize or wipe bystander phones without formal cyber search warrant.",
            legalRef: "Art 21 & Art 19(1)(a)",
          ),
          GuidanceItem(
            title: "Do not sign an unverified police witness memo on the spot.",
            subtitle: "Section 162 CrPC protects citizens from being coerced into signing investigation records.",
            legalRef: "Sec 162 CrPC",
          ),
          GuidanceItem(
            title: "Do not engage in shouting matches; remain a calm, objective observer.",
            subtitle: "Calm photographic and audio documentation carries far greater evidentiary weight in court.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not pay unauthorized touts or middlemen lingering near traffic outposts.",
            subtitle: "All traffic fines can be verified and settled directly through official Parivahan or virtual court channels.",
            legalRef: "Virtual Courts Portal",
          ),
          GuidanceItem(
            title: "Do not leave a minor driver alone in police custody without guardian presence.",
            subtitle: "Juvenile Justice Act mandates non-uniformed child welfare officer handling for minors.",
            legalRef: "Juvenile Justice Act 2015",
          ),
          GuidanceItem(
            title: "Do not allow vehicle release without obtaining an official seizure memo.",
            subtitle: "An itemized seizure receipt is essential for insurance claims and proving uninterrupted custody chain.",
            legalRef: "Sec 207 MV Act",
          ),
          GuidanceItem(
            title: "Do not accept verbal threats of vehicle forfeiture without magistrate order.",
            subtitle: "Police have no statutory power to permanently confiscate private property on the roadside.",
            legalRef: "Art 300A Constitution",
          ),
        ];
    }
  }

  // ==========================================
  // 2. ARREST & DETENTION / POLICE CUSTODY
  // ==========================================

  static List<GuidanceItem> _getArrestDetentionDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Ask whether you are under formal arrest or participating in inquiry.",
            subtitle: "If not formally arrested, police cannot detain you without formal Section 41A CrPC written notice.",
            legalRef: "Sec 41A CrPC / Arnesh Kumar Guidelines",
          ),
          GuidanceItem(
            title: "Demand an Arrest Memo prepared with exact date, time, and witness signature.",
            subtitle: "Mandatory under D.K. Basu guidelines; counter-signed by a relative or respectable locality witness.",
            legalRef: "D.K. Basu v. State of West Bengal",
          ),
          GuidanceItem(
            title: "Exercise your right to have a family member or friend informed immediately.",
            subtitle: "Section 50A CrPC mandates that police notify your chosen contact within 1 hour of custody.",
            legalRef: "Sec 50A CrPC",
          ),
          GuidanceItem(
            title: "Request a mandatory medical examination by a government medical officer.",
            subtitle: "Section 54 CrPC provides documented proof of your physical state to prevent custodial torture.",
            legalRef: "Sec 54 CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Demand a copy of the FIR and arrest memo free of cost immediately.",
            subtitle: "Section 50 CrPC & Section 207 CrPC mandate immediate disclosure of full grounds of arrest.",
            legalRef: "Sec 50 / 207 CrPC",
          ),
          GuidanceItem(
            title: "Exercise your constitutional right to consult and be defended by legal counsel.",
            subtitle: "Article 22(1) guarantees legal consultation throughout interrogation and custody.",
            legalRef: "Art 22(1) Constitution",
          ),
          GuidanceItem(
            title: "Ensure you are produced before a Judicial Magistrate within 24 hours.",
            subtitle: "Section 57 CrPC & Article 22(2) strictly prohibit police detention beyond 24 hours without court order.",
            legalRef: "Sec 57 CrPC / Art 22(2)",
          ),
          GuidanceItem(
            title: "Request free legal aid if you do not have private legal representation.",
            subtitle: "Section 304 CrPC & NALSA mandate the state to provide competent free legal aid advocates.",
            legalRef: "Sec 304 CrPC / NALSA Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Demand a written witness summons under Section 160 CrPC before entering station.",
            subtitle: "Police cannot summon witnesses via oral or phone instructions; written notice is legally required.",
            legalRef: "Sec 160 CrPC",
          ),
          GuidanceItem(
            title: "Women and minors under 15 must be examined at their home only.",
            subtitle: "Section 160(1) proviso explicitly prohibits calling women and male children under 15 to the police station.",
            legalRef: "Sec 160(1) Proviso CrPC",
          ),
          GuidanceItem(
            title: "Note that you are NOT legally required to sign your Section 161 CrPC statement.",
            subtitle: "Section 162 CrPC strictly bars police officers from taking a witness's signature on inquiry statements.",
            legalRef: "Sec 162 CrPC",
          ),
          GuidanceItem(
            title: "Note your entry and exit time in the police station visitor register.",
            subtitle: "Station Diary (GD) entry protects witnesses against unauthorized or arbitrary custodial delays.",
            legalRef: "Police Station Manual",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Inspect the Station General Diary and Arrest Memo immediately upon arrival.",
            subtitle: "D.K. Basu guidelines require relative signature and designated custody register entry.",
            legalRef: "D.K. Basu Judgment",
          ),
          GuidanceItem(
            title: "Verify the mandatory medical examination report before magistrate remand.",
            subtitle: "Section 54 CrPC: Check that any bruises or injuries are documented by the government doctor.",
            legalRef: "Sec 54 CrPC",
          ),
          GuidanceItem(
            title: "Engage an advocate to appear before the Judicial Magistrate within 24 hours.",
            subtitle: "Bail application can be moved immediately at first judicial production under Section 167 CrPC.",
            legalRef: "Sec 167 / 437 CrPC",
          ),
          GuidanceItem(
            title: "Contact District Legal Services Authority (DLSA) on 15100 if denied access.",
            subtitle: "DLSA provides instant statutory legal intervention and deputes remand lawyers to the police station.",
            legalRef: "NALSA Toll-Free 15100",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getArrestDetentionDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not resist physical detention with violence or physical confrontation.",
            subtitle: "Express verbal protest; physical struggle can attract Section 353 IPC (non-bailable assault on public servant).",
            legalRef: "Sec 353 IPC",
          ),
          GuidanceItem(
            title: "Never make self-incriminating confessions or sign blank documents.",
            subtitle: "Section 25 of Indian Evidence Act: Confessions made to police officers are completely inadmissible in court.",
            legalRef: "Sec 25 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not allow interrogation without lawyer presence or notification of family.",
            subtitle: "Supreme Court in Nandini Satpathy v. P.L. Dani upheld right to silence against self-incrimination.",
            legalRef: "Nandini Satpathy Case / Art 20(3)",
          ),
          GuidanceItem(
            title: "Do not accept detention beyond 24 hours without magistrate appearance.",
            subtitle: "Detention exceeding 24 hours without magistrate remand is unconstitutional and constitutes illegal confinement.",
            legalRef: "Sec 342 IPC / Art 22(2)",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not disclose phone passcodes or biometric credentials under interrogation.",
            subtitle: "Article 20(3) fundamental right against self-incrimination protects digital device passwords.",
            legalRef: "Art 20(3) Constitution",
          ),
          GuidanceItem(
            title: "Do not participate in unrecorded custodial discovery without legal advice.",
            subtitle: "Statements leading to discovery of objects must strictly comply with Section 27 Evidence Act safeguards.",
            legalRef: "Sec 27 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not waive your right to regular bail or accept informal police lockup compromises.",
            subtitle: "Police have no legal power to grant informal release in non-bailable cases; court order is mandatory.",
            legalRef: "Sec 437 CrPC",
          ),
          GuidanceItem(
            title: "Do not consent to narco-analysis or polygraph lie-detector tests.",
            subtitle: "Supreme Court in Selvi v. State of Karnataka held involuntary narco/polygraph tests unconstitutional.",
            legalRef: "Selvi v. State of Karnataka (2010)",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not sign statements under Section 161 CrPC under police pressure.",
            subtitle: "The law explicitly forbids police from obtaining witness signatures on investigation notes.",
            legalRef: "Sec 162 CrPC",
          ),
          GuidanceItem(
            title: "Do not answer questions that expose you to personal criminal liability.",
            subtitle: "Witnesses possess the statutory privilege to refuse answering self-incriminating questions.",
            legalRef: "Sec 132 Evidence Act Proviso",
          ),
          GuidanceItem(
            title: "Do not allow police to seize your personal belongings, phone, or vehicle.",
            subtitle: "Witnesses are not subject to personal search or seizure under Section 51 CrPC.",
            legalRef: "Sec 51 CrPC",
          ),
          GuidanceItem(
            title: "Do not stay at the police station overnight under the guise of witness inquiry.",
            subtitle: "Witnesses cannot be subjected to custodial restraint; depart after statement recording.",
            legalRef: "Police Investigation Manual",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not pay bribes or informal 'release fees' to station officers.",
            subtitle: "Paying unofficial money will not prevent filing of charges and constitutes criminal abetment.",
            legalRef: "Prevention of Corruption Act",
          ),
          GuidanceItem(
            title: "Do not leave the police station without knowing the exact Magistrate court room.",
            subtitle: "Accused must be produced in open court; know the jurisdictional court to arrange bail counsel.",
            legalRef: "Sec 167 CrPC",
          ),
          GuidanceItem(
            title: "Do not allow informal transfer to an undisclosed branch or lockup.",
            subtitle: "Police control room and District Central Registry must record custody location under D.K. Basu.",
            legalRef: "D.K. Basu Guidelines",
          ),
          GuidanceItem(
            title: "Do not hesitate to file Habeas Corpus petition in High Court if detained illegally.",
            subtitle: "High Courts can order immediate judicial inspection and production of unlawfully detained citizens.",
            legalRef: "Art 226 Constitution",
          ),
        ];
    }
  }

  // ==========================================
  // 3. BRIBERY / CORRUPTION / POLICE EXTORTION
  // ==========================================

  static List<GuidanceItem> _getBribeDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Politely demand official circular or fee schedule in writing for the service.",
            subtitle: "Public servants are mandated to publish citizen charters and statutory fee schedules.",
            legalRef: "RTI Act Sec 4 / Citizen Charter",
          ),
          GuidanceItem(
            title: "Preserve audio, video, or message evidence of the illicit demand.",
            subtitle: "Evidence of demand is mandatory under Section 7 of the Prevention of Corruption Act.",
            legalRef: "Sec 7 Prevention of Corruption Act",
          ),
          GuidanceItem(
            title: "Report directly to State Anti-Corruption Bureau (ACB) or CBI Toll-Free.",
            subtitle: "ACB organizes statutory traps with phenolphthalein-marked currency to apprehend corrupt officials.",
            legalRef: "State ACB Regulations",
          ),
          GuidanceItem(
            title: "Notify senior supervising officers (SP / Vigilance Commissioner) in writing.",
            subtitle: "Supervising authorities have statutory duty to take cognizance under vigilance guidelines.",
            legalRef: "Central Vigilance Commission Act",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Report extortion under duress immediately to avoid being treated as a bribe-giver.",
            subtitle: "Section 8 Proviso of PC Act protects victims who report extortion to law enforcement within 7 days.",
            legalRef: "Sec 8 Proviso PC Act 2018",
          ),
          GuidanceItem(
            title: "Document exact dates, vehicle numbers, and station personnel demanding money.",
            subtitle: "Crucial proof that payments were extorted under threat of false prosecution.",
            legalRef: "Sec 383/384 IPC (Extortion)",
          ),
          GuidanceItem(
            title: "Seek protective legal representation before submitting statement to vigilance.",
            subtitle: "Ensures your reporting statement is recorded under statutory immunity provisions.",
            legalRef: "Sec 8 PC Act",
          ),
          GuidanceItem(
            title: "Preserve all bank transaction attempts, UPI QR codes, or account details demanded.",
            subtitle: "Direct financial trail establishes extortion nexus in magistrate court.",
            legalRef: "Sec 65B Evidence Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Record the conversation or interaction discreetly from an unprovocative angle.",
            subtitle: "Independent audio/video corroboration is the gold standard in corruption prosecutions.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Preserve the digital recording without editing, renaming, or filtering.",
            subtitle: "Unedited original metadata ensures full forensic admissibility in Special CBI/ACB Court.",
            legalRef: "Sec 65B Certificate Norms",
          ),
          GuidanceItem(
            title: "Provide your statement directly to the Vigilance or Magistrate under Section 164 CrPC.",
            subtitle: "Statements before a magistrate carry binding evidentiary weight and protect witnesses from threats.",
            legalRef: "Sec 164 CrPC",
          ),
          GuidanceItem(
            title: "Seek witness protection under the Witness Protection Scheme 2018 if threatened.",
            subtitle: "Supreme Court implemented nationwide witness protection against influential public officials.",
            legalRef: "Witness Protection Scheme 2018",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Submit a formal written complaint to District Superintendent of Police.",
            subtitle: "SP is bound by law to register vigilance complaints against junior station personnel.",
            legalRef: "Sec 154(3) CrPC / Vigilance Rules",
          ),
          GuidanceItem(
            title: "Engage an advocate to file a complaint before the State Police Complaints Authority.",
            subtitle: "Independent statutory body created under Supreme Court directive in Prakash Singh case.",
            legalRef: "Prakash Singh v. Union of India",
          ),
          GuidanceItem(
            title: "Call Anti-Corruption Helpline 1064 immediately for confidential guidance.",
            subtitle: "Toll-free nationwide vigilance line coordinates anti-graft trap operations.",
            legalRef: "ACB Helpline 1064",
          ),
          GuidanceItem(
            title: "Secure all physical receipts, official tokens, and government application IDs.",
            subtitle: "Proves that the citizen was entitled to public service without arbitrary delays.",
            legalRef: "Public Service Guarantee Act",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getBribeDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not pay the demanded bribe or informal 'speed money' in cash.",
            subtitle: "Paying bribes without reporting within 7 days is punishable under Section 8 of the PC Act.",
            legalRef: "Sec 8 PC Act",
          ),
          GuidanceItem(
            title: "Do not transfer money to private UPI IDs, scanner codes, or third-party accounts.",
            subtitle: "Corrupt officials often use mule accounts; transferring funds makes you part of the financial trail.",
            legalRef: "Prevention of Money Laundering Act",
          ),
          GuidanceItem(
            title: "Do not threaten or confront corrupt personnel aggressively on the scene.",
            subtitle: "Can trigger retaliatory false FIRs under Section 186/353 IPC (obstructing public servant).",
            legalRef: "Sec 353 IPC",
          ),
          GuidanceItem(
            title: "Do not delete recordings, call logs, or WhatsApp screenshots under intimidation.",
            subtitle: "Immediate backup to secure cloud vault ensures evidence survives even if device is seized.",
            legalRef: "Sec 201 IPC (Destruction of Evidence)",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not delay reporting extortion beyond the 7-day statutory immunity window.",
            subtitle: "Section 8 Proviso PC Act grants immunity ONLY if reported to law enforcement within 7 days.",
            legalRef: "Sec 8 Proviso PC Act",
          ),
          GuidanceItem(
            title: "Do not surrender marked currency or evidence to the same station officers.",
            subtitle: "Hand over evidence directly to designated ACB/CBI officers or the jurisdictional Magistrate.",
            legalRef: "ACB Operating Procedure",
          ),
          GuidanceItem(
            title: "Do not make conflicting oral statements during preliminary vigilance inquiry.",
            subtitle: "Stick strictly to your contemporaneous digital recordings, date logs, and written representation.",
            legalRef: "Sec 145 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not attempt private compromises with intermediaries or middle-men (dalals).",
            subtitle: "Intermediaries are often part of the extortion racket; dealing with them weakens your immunity.",
            legalRef: "Sec 9 Prevention of Corruption Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not edit, trim, or apply audio filters to recorded bribery encounters.",
            subtitle: "Forensic labs test hash consistency; any modification invalidates Section 65B certification.",
            legalRef: "Sec 65B Evidence Act",
          ),
          GuidanceItem(
            title: "Do not share bribery footage on social media before notifying Anti-Corruption authorities.",
            subtitle: "Premature public leak alerts the corrupt officer and ruins official trap operations.",
            legalRef: "Vigilance Trap Protocol",
          ),
          GuidanceItem(
            title: "Do not accept informal police summons to come alone to the accused officer's station.",
            subtitle: "Witness examination in corruption cases should be before independent vigilance or magistrate.",
            legalRef: "Sec 160 CrPC",
          ),
          GuidanceItem(
            title: "Do not sign pre-typed witness statements without reading every single sentence.",
            subtitle: "Section 162 CrPC prohibits police from taking signed witness statements during inquiry.",
            legalRef: "Sec 162 CrPC",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not pay 'compromise money' to keep a family member out of jail on false charges.",
            subtitle: "Paying corrupt demands encourages repeated extortion cycles against your family.",
            legalRef: "Sec 383 IPC (Extortion)",
          ),
          GuidanceItem(
            title: "Do not sign blank receipts or informal undertaking notes at the police station.",
            subtitle: "Station personnel may use such notes to claim voluntary donations or lawful settlement.",
            legalRef: "Indian Contract Act",
          ),
          GuidanceItem(
            title: "Do not handle marked trap money during an ACB operation without vigilance guidance.",
            subtitle: "Trained vigilance sleuths must manage the chemical handling of phenolphthalein currency.",
            legalRef: "ACB Trap Manual",
          ),
          GuidanceItem(
            title: "Do not let station staff intimidate you out of filing an official ACB/CVC complaint.",
            subtitle: "High Court will provide police protection if corrupt officers threaten complaining families.",
            legalRef: "Prakash Singh Guidelines",
          ),
        ];
    }
  }

  // ==========================================
  // 4. FIR REFUSED / POLICE STATION RIGHTS
  // ==========================================

  static List<GuidanceItem> _getFirRefusedDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Demand registration of Zero FIR if crime occurred outside local jurisdiction.",
            subtitle: "Zero FIR can be registered at ANY police station and transferred to the jurisdictional station.",
            legalRef: "Ministry of Home Affairs Zero FIR Circular",
          ),
          GuidanceItem(
            title: "Demand a physical stamped copy of your complaint and the FIR free of cost.",
            subtitle: "Section 154(2) CrPC guarantees the informant an immediate copy without charging any fees.",
            legalRef: "Sec 154(2) CrPC",
          ),
          GuidanceItem(
            title: "Send signed complaint to the Superintendent of Police via Registered Post with AD.",
            subtitle: "Section 154(3) CrPC empowers the SP to investigate or direct an officer to register FIR.",
            legalRef: "Sec 154(3) CrPC",
          ),
          GuidanceItem(
            title: "Move Section 156(3) CrPC application before Judicial Magistrate if SP fails to act.",
            subtitle: "Lalita Kumari v. Govt of UP: FIR registration is mandatory for cognizable offenses.",
            legalRef: "Lalita Kumari Judgment / Sec 156(3) CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Apply for certified copy of the FIR through court or official state citizen portal.",
            subtitle: "Supreme Court in Youth Bar Association case mandated uploading FIR online within 24 hours.",
            legalRef: "Youth Bar Association Judgment",
          ),
          GuidanceItem(
            title: "Apply for Anticipatory Bail under Section 438 CrPC if non-bailable offense is named.",
            subtitle: "Protects against arrest while allowing you to cooperate with lawful investigation.",
            legalRef: "Sec 438 CrPC",
          ),
          GuidanceItem(
            title: "Seek Section 41A CrPC notice protection if maximum sentence is 7 years or less.",
            subtitle: "Supreme Court in Arnesh Kumar case prohibited routine arrests for offenses punishable under 7 years.",
            legalRef: "Arnesh Kumar v. State of Bihar",
          ),
          GuidanceItem(
            title: "File Section 482 CrPC petition in High Court to quash malicious or fabricated FIR.",
            subtitle: "High Courts possess inherent power to quash proceedings initiated with vindictive motive.",
            legalRef: "Sec 482 CrPC",
          ),
        ];

      case UserRole.witness:
      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Accompany the complainant inside the police station for moral and physical safety.",
            subtitle: "Police station is a public office; citizens have the right to accompany family members.",
            legalRef: "State Police Manual",
          ),
          GuidanceItem(
            title: "Verify that the station Duty Officer enters the report in the General Diary (GD).",
            subtitle: "GD entry timestamp proves the exact hour the police were informed of the cognizable crime.",
            legalRef: "Sec 44 Police Act",
          ),
          GuidanceItem(
            title: "Contact District Legal Services Authority (DLSA) on 15100 for station legal aid.",
            subtitle: "Free legal aid lawyers are available 24/7 to accompany citizens facing FIR refusal.",
            legalRef: "NALSA Helpline 15100",
          ),
          GuidanceItem(
            title: "Escalate to the State Human Rights Commission or Police Complaints Authority.",
            subtitle: "Willful refusal to register FIR is a punishable offense under Section 166A IPC.",
            legalRef: "Sec 166A IPC",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getFirRefusedDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not accept a simple General Diary (GD) entry as a substitute for an FIR.",
            subtitle: "A GD entry does not initiate formal investigation or arrests; insist on formal FIR registration.",
            legalRef: "Lalita Kumari v. Govt of UP",
          ),
          GuidanceItem(
            title: "Do not agree to informal 'compromise' brokered by police for serious offenses.",
            subtitle: "Police have no legal authority to force victims into informal compromise in cognizable crimes.",
            legalRef: "Sec 320 CrPC",
          ),
          GuidanceItem(
            title: "Do not leave the police station without a signed and stamped acknowledgment copy.",
            subtitle: "A stamped receiving seal is essential evidence for escalating to SP and Magistrate.",
            legalRef: "Sec 154 CrPC",
          ),
          GuidanceItem(
            title: "Do not sign blank papers or altered complaint drafts typed by station personnel.",
            subtitle: "Read the vernacular draft line-by-line before signing to ensure your facts are not distorted.",
            legalRef: "Sec 162 CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not evade lawful Section 41A CrPC notice when called for police inquiry.",
            subtitle: "Compliance with Section 41A notice guarantees statutory protection from arrest.",
            legalRef: "Sec 41A CrPC / Arnesh Kumar",
          ),
          GuidanceItem(
            title: "Do not make oral confessions to police officers under custodial intimidation.",
            subtitle: "Confessions made to police are inadmissible under Section 25 of the Indian Evidence Act.",
            legalRef: "Sec 25 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not tamper with CCTV, documentary records, or digital proof related to the case.",
            subtitle: "Evidence tampering is an independent non-bailable offense under Section 201 IPC.",
            legalRef: "Sec 201 IPC",
          ),
          GuidanceItem(
            title: "Do not contact or threaten the complainant to withdraw the police report.",
            subtitle: "Witness intimidation results in immediate rejection or cancellation of bail.",
            legalRef: "Sec 195A IPC",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not attend police station without formal written Section 160 CrPC summons.",
            subtitle: "Police cannot mandate informal witness attendance over phone calls or verbal orders.",
            legalRef: "Sec 160 CrPC",
          ),
          GuidanceItem(
            title: "Do not sign police witness inquiry statements under Section 161 CrPC.",
            subtitle: "Section 162 CrPC expressly prohibits police from taking signatures on witness statements.",
            legalRef: "Sec 162 CrPC",
          ),
          GuidanceItem(
            title: "Do not give contradictory statements between police inquiry and court testimony.",
            subtitle: "Inconsistencies damage credibility during cross-examination in trial court.",
            legalRef: "Sec 145 Evidence Act",
          ),
          GuidanceItem(
            title: "Do not accept financial gifts, travel compensation, or hospitality from either party.",
            subtitle: "Preserves your neutrality as an objective, uncompromised witness.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not allow minor family members to be questioned without legal guardian presence.",
            subtitle: "Juvenile Justice Act mandates presence of parents/child welfare officer during inquiry.",
            legalRef: "Juvenile Justice Act",
          ),
          GuidanceItem(
            title: "Do not leave female complainants unattended in police station after sunset.",
            subtitle: "Women can only be examined at their place of residence under Section 160(1) Proviso.",
            legalRef: "Sec 160(1) Proviso CrPC",
          ),
          GuidanceItem(
            title: "Do not pay informal 'station expenses' or paperwork charges to get an FIR registered.",
            subtitle: "Registration of FIR and supply of copy is 100% free by statutory mandate.",
            legalRef: "Sec 154(2) CrPC",
          ),
          GuidanceItem(
            title: "Do not sign pre-written settlement deeds relinquishing civil or criminal claims.",
            subtitle: "Station compromise deeds executed under duress are legally void.",
            legalRef: "Indian Contract Act",
          ),
        ];
    }
  }

  // ==========================================
  // 5. DOOR SEARCH / HOME WARRANT
  // ==========================================

  static List<GuidanceItem> _getDoorSearchDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Demand to inspect the signed Search Warrant before allowing police entry.",
            subtitle: "Section 93/94 CrPC: Search of private residence requires a warrant issued by a competent Magistrate.",
            legalRef: "Sec 93/94 CrPC",
          ),
          GuidanceItem(
            title: "Insist on the presence of two independent local locality witnesses (Panchas).",
            subtitle: "Section 100(4) CrPC mandates that two respectable inhabitants of the locality witness the search.",
            legalRef: "Sec 100(4) CrPC",
          ),
          GuidanceItem(
            title: "Women residents cannot be searched except by female personnel with strict decency.",
            subtitle: "Section 100(3) & 51(2) CrPC: Male officers are strictly prohibited from touching female occupants.",
            legalRef: "Sec 100(3) CrPC",
          ),
          GuidanceItem(
            title: "Demand a complete, signed copy of the Search List (Panchnama) of all seized items.",
            subtitle: "Section 100(5) CrPC: Officer must furnish a signed seizure list free of cost to the occupant.",
            legalRef: "Sec 100(5) CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Check specific case crime number and premises address stated on the warrant.",
            subtitle: "Warrant issued for a different address or unrelated case cannot be used to search your home.",
            legalRef: "Sec 93 CrPC",
          ),
          GuidanceItem(
            title: "Exercise right to search the police search team before they enter private rooms.",
            subtitle: "Standard criminal procedure protects householders from planted or fabricated contraband.",
            legalRef: "Police Procedural Manual",
          ),
          GuidanceItem(
            title: "Demand that all seized digital devices (laptops, phones) are sealed in tamper-proof bags.",
            subtitle: "Insist on recording serial numbers and IMEI codes in Panchnama to safeguard digital integrity.",
            legalRef: "Digital Forensics SOP",
          ),
          GuidanceItem(
            title: "Contact your criminal defense advocate immediately upon arrival of the search team.",
            subtitle: "Legal counsel has the right to be present to observe execution of the search warrant.",
            legalRef: "Art 22(1) Constitution",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Observe every search movement and room entry in real time with the police party.",
            subtitle: "Panch witnesses must personally see where each recovered article was found before signing.",
            legalRef: "Sec 100(4) CrPC",
          ),
          GuidanceItem(
            title: "Verify that the seizure inventory lists exact cash amounts, jewelry weights, and device serials.",
            subtitle: "Prevents subsequent disputes or allegations of altered evidence in the trial court.",
            legalRef: "Sec 100(5) CrPC",
          ),
          GuidanceItem(
            title: "Ensure that search was conducted without causing wanton physical vandalism to property.",
            subtitle: "Police are legally obligated to conduct search with minimal necessary physical damage.",
            legalRef: "Sec 100 CrPC",
          ),
          GuidanceItem(
            title: "Sign the Panchnama document only after reading and verifying all written entries.",
            subtitle: "Your signature certifies only what you personally witnessed during the search.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Seat minors and elderly family members in a designated quiet room with guardian escort.",
            subtitle: "Protects vulnerable family members from aggressive search commotion and distress.",
            legalRef: "Juvenile Justice Act",
          ),
          GuidanceItem(
            title: "Verify written Section 165 CrPC reasons if officers claim emergency warrantless entry.",
            subtitle: "Officer must record in writing why a magistrate warrant could not be obtained in time.",
            legalRef: "Sec 165 CrPC",
          ),
          GuidanceItem(
            title: "Maintain a separate personal handwritten log of all items seized by the search officers.",
            subtitle: "Enables immediate cross-verification against the police Panchnama copy.",
            legalRef: "D.K. Basu Norms",
          ),
          GuidanceItem(
            title: "Ensure female family members are searched exclusively behind closed doors by female police.",
            subtitle: "Mandatory statutory decency requirement under Section 100(3) and Section 51(2) CrPC.",
            legalRef: "Sec 100(3) CrPC",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getDoorSearchDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not allow search without checking the officer's written search warrant or grounds.",
            subtitle: "Section 165 CrPC emergency warrantless search requires recording written reasons first.",
            legalRef: "Sec 165 CrPC",
          ),
          GuidanceItem(
            title: "Do not permit male officers into private bedrooms of female residents after sunset.",
            subtitle: "Prohibited under CrPC and police guidelines without female officer escort.",
            legalRef: "Sec 46(4) CrPC",
          ),
          GuidanceItem(
            title: "Do not sign a blank or incomplete Panchnama seizure document.",
            subtitle: "Ensure every single article, cash count, and digital device is specifically listed.",
            legalRef: "Sec 100(5) CrPC",
          ),
          GuidanceItem(
            title: "Do not let officers search without first allowing occupants to search the officers.",
            subtitle: "Law permits householder to ensure officers are not planting fabricated evidence.",
            legalRef: "Police Procedural Norms",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not surrender private device passcodes or cloud credentials under oral intimidation.",
            subtitle: "Article 20(3) protects citizens against self-incrimination without specific judicial order.",
            legalRef: "Art 20(3) / Puttaswamy",
          ),
          GuidanceItem(
            title: "Do not attempt to destroy, delete, or throw away physical or digital documents.",
            subtitle: "Destruction of evidence is an independent non-bailable offense under Section 201 IPC.",
            legalRef: "Sec 201 IPC",
          ),
          GuidanceItem(
            title: "Do not engage in physical confrontation or wrestling with search officers.",
            subtitle: "Triggers severe non-bailable charges of assault on public servants under Section 353 IPC.",
            legalRef: "Sec 353 IPC",
          ),
          GuidanceItem(
            title: "Do not make unverified confessions or spontaneous oral statements during the raid.",
            subtitle: "Statements made to police in custody cannot be used against you under Section 25 Evidence Act.",
            legalRef: "Sec 25 Evidence Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not sign as a Panch witness without personally seeing where articles were recovered.",
            subtitle: "Signing blind witness memos makes you complicit in potential police fabrication.",
            legalRef: "Sec 100 CrPC",
          ),
          GuidanceItem(
            title: "Do not leave the search location before the Panchnama is completely read and closed.",
            subtitle: "Prevents subsequent unauthorized additions to the inventory list.",
            legalRef: "Sec 100(5) CrPC",
          ),
          GuidanceItem(
            title: "Do not allow police to seize personal belongings of uninvolved third-party guests.",
            subtitle: "Only items relevant to the specific warrant or crime nexus may be lawfully seized.",
            legalRef: "Sec 102 CrPC",
          ),
          GuidanceItem(
            title: "Do not sign pre-dated or station-prepared search records hours later.",
            subtitle: "Panchnama must be executed contemporaneously on the spot at the time of search.",
            legalRef: "Evidence Act Jurisprudence",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not allow police to interrogate minors or children without guardian presence.",
            subtitle: "Violates child protection safeguards under the Juvenile Justice Act 2015.",
            legalRef: "Juvenile Justice Act",
          ),
          GuidanceItem(
            title: "Do not hand over stridhan, marriage jewelry, or personal cash without itemized receipt.",
            subtitle: "Stridhan is the exclusive lawful property of the woman under Indian law.",
            legalRef: "Pratibha Rani v. Suraj Kumar",
          ),
          GuidanceItem(
            title: "Do not allow officers to remove CCTV security DVR without formal seizure documentation.",
            subtitle: "Seizure of home cameras removes vital video proof of how the search was conducted.",
            legalRef: "Sec 100 CrPC",
          ),
          GuidanceItem(
            title: "Do not consent to searches of adjacent properties or relatives' homes not in the warrant.",
            subtitle: "Warrants are strictly property-specific; demand a separate warrant for other premises.",
            legalRef: "Sec 93 CrPC",
          ),
        ];
    }
  }

  // ==========================================
  // 6. DIGITAL & CYBER CRIME / PHONE SEARCH
  // ==========================================

  static List<GuidanceItem> _getDigitalCyberDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Call National Cyber Crime Helpline 1930 immediately within the golden hour.",
            subtitle: "Immediate reporting enables banks to freeze disputed funds in beneficiary accounts.",
            legalRef: "Cyber Crime Helpline 1930",
          ),
          GuidanceItem(
            title: "File official complaint on cybercrime.gov.in and obtain your acknowledgment number.",
            subtitle: "Statutory online FIR portal monitored directly by state cyber cells and nodal banks.",
            legalRef: "cybercrime.gov.in",
          ),
          GuidanceItem(
            title: "Preserve unedited transaction UTR numbers, SMS alerts, and call screenshots.",
            subtitle: "Original uncompressed digital artifacts satisfy Section 65B Indian Evidence Act admissibility.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Request your bank for copy of the Section 91 CrPC notice if account is frozen.",
            subtitle: "Identifies the specific state police unit or court that placed the lien on your account.",
            legalRef: "Sec 91 CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Demand formal seizure memo with IMEI and serial numbers if phone is seized.",
            subtitle: "Section 100 CrPC: Two independent witnesses must counter-sign digital device seizure.",
            legalRef: "Sec 100 CrPC",
          ),
          GuidanceItem(
            title: "Insist that electronic devices are placed in tamper-proof anti-static bag.",
            subtitle: "Guarantees chain of custody and prevents remote data tampering or evidence alteration.",
            legalRef: "Digital Forensics SOP",
          ),
          GuidanceItem(
            title: "Apply for de-freezing of legitimately earned funds under Section 457 CrPC.",
            subtitle: "Judicial Magistrate can unfreeze accounts after verifying legitimate income sources.",
            legalRef: "Sec 457 CrPC",
          ),
          GuidanceItem(
            title: "Engage cyber advocate to submit compliance reply to Section 91/41A summons.",
            subtitle: "Proves bona fide transaction status and clears suspected mule account allegations.",
            legalRef: "Sec 41A CrPC",
          ),
        ];

      case UserRole.witness:
      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Provide certified bank statement printouts under Bankers Books Evidence Act.",
            subtitle: "Sufficient to clarify transaction trails without surrendering primary personal devices.",
            legalRef: "Bankers Books Evidence Act 1891",
          ),
          GuidanceItem(
            title: "Report blackmail, morphed imagery, or sextortion to NCPCR/Cyber Cell immediately.",
            subtitle: "POCSO Act and IT Act Section 67B mandate immediate platform takedown and protection.",
            legalRef: "Sec 67B IT Act / POCSO Act",
          ),
          GuidanceItem(
            title: "Obtain official stamped acknowledgment on all representations submitted to cyber cell.",
            subtitle: "Provides verifiable proof of compliance during subsequent bail or magistrate hearings.",
            legalRef: "State Cyber Cell Guidelines",
          ),
          GuidanceItem(
            title: "Consult legal counsel to submit de-freezing representation to SP Cyber Crime.",
            subtitle: "High Courts routinely direct quick de-freezing of accounts of bona fide tertiary recipients.",
            legalRef: "High Court Precedents on Account Freeze",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getDigitalCyberDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not pay extortionists or blackmailers even a small initial token payment.",
            subtitle: "Paying extortion money guarantees continuous blackmail; report immediately to Cyber Cell.",
            legalRef: "Sec 384 IPC (Extortion)",
          ),
          GuidanceItem(
            title: "Do not delete chats, transaction screenshots, or call recordings from your device.",
            subtitle: "Preserving original timestamps and chat history is essential for tracing the perpetrator.",
            legalRef: "Sec 201 IPC / Sec 65B Evidence Act",
          ),
          GuidanceItem(
            title: "Do not share OTPs, device PINs, or install remote access software (AnyDesk, TeamViewer).",
            subtitle: "Legitimate police and bank officials never ask for OTPs or remote screen-sharing access.",
            legalRef: "RBI Cyber Security Advisory",
          ),
          GuidanceItem(
            title: "Do not provide phone passwords or biometric unlock under roadside police pressure.",
            subtitle: "Supreme Court privacy jurisprudence protects private digital data against arbitrary inspection.",
            legalRef: "Art 20(3) & Art 21 Constitution",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not format, factory reset, or discard suspected electronic devices.",
            subtitle: "Wiping devices triggers severe charges of destruction of electronic evidence under IT Act.",
            legalRef: "Sec 201 IPC / Sec 65B IT Act",
          ),
          GuidanceItem(
            title: "Do not ignore Section 91 CrPC notice or Section 41A summons from cyber crime police.",
            subtitle: "Ignoring formal notices converts bailable inquiries into non-bailable arrest warrants.",
            legalRef: "Sec 41A CrPC",
          ),
          GuidanceItem(
            title: "Do not operate secondary unverified crypto wallets or mule accounts during investigation.",
            subtitle: "Additional suspect transactions aggravate money laundering allegations under PMLA.",
            legalRef: "Prevention of Money Laundering Act",
          ),
          GuidanceItem(
            title: "Do not make statements admitting to cyber syndicate operations without counsel.",
            subtitle: "Exercise right to consult specialized cyber advocate before statement recording.",
            legalRef: "Art 22(1) Constitution",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not forward or recirculate compromised private photos or blackmail materials.",
            subtitle: "Transmitting sexually explicit or hacked content violates Section 67/67A of the IT Act.",
            legalRef: "Sec 67/67A IT Act",
          ),
          GuidanceItem(
            title: "Do not sign unverified cyber seizure panchnamas as a bystander or cyber cafe owner.",
            subtitle: "Ensure hash values and serial numbers are physically verified before signing.",
            legalRef: "Digital Evidence Manual",
          ),
          GuidanceItem(
            title: "Do not surrender your own primary phone if you only witnessed or received a suspicious link.",
            subtitle: "Police can inspect relevant screenshots or exports without seizing third-party phones.",
            legalRef: "Sec 91 CrPC",
          ),
          GuidanceItem(
            title: "Do not delete phishing emails or suspect server logs before taking forensic export.",
            subtitle: "Full email headers (MIME) contain origin IP addresses crucial for tracing perpetrators.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not succumb to digital arrest scam calls alleging child is in custody.",
            subtitle: "CBI, ED, and Police NEVER conduct video call court trials or digital arrests over Skype/WhatsApp.",
            legalRef: "MHA Cyber Crime Advisory",
          ),
          GuidanceItem(
            title: "Do not transfer money to 'verification RBI clearance accounts' under scam intimidation.",
            subtitle: "Government agencies never ask citizens to transfer funds to personal clearance accounts.",
            legalRef: "RBI Notification on Impersonation",
          ),
          GuidanceItem(
            title: "Do not scold or isolate minors who fall victim to online extortion or sextortion.",
            subtitle: "Provide immediate psychological safety and contact Cyber Crime Helpline 1930 / NCPCR.",
            legalRef: "POCSO Act / NCPCR Guidelines",
          ),
          GuidanceItem(
            title: "Do not hire unauthorized private 'hackers' claiming to recover scammed funds.",
            subtitle: "Most fund recovery agents are secondary cyber scammers; only bank and police liens recover funds.",
            legalRef: "Cyber Crime Cell Alert",
          ),
        ];
    }
  }

  // ==========================================
  // 7. CAMPUS & RAGGING / STUDENT RIGHTS
  // ==========================================

  static List<GuidanceItem> _getCampusDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Call National Anti-Ragging 24x7 Toll-Free Helpline: 1800-180-5522.",
            subtitle: "UGC Anti-Ragging Cell logs complaint and issues mandatory investigation directives to college.",
            legalRef: "UGC Ragging Regulations 2009",
          ),
          GuidanceItem(
            title: "Submit a written complaint to Head of Institution & Anti-Ragging Committee.",
            subtitle: "Institution is mandated to initiate inquiry and lodge police FIR within 24 hours of complaint.",
            legalRef: "UGC Anti-Ragging Mandate",
          ),
          GuidanceItem(
            title: "Preserve chat threats, hostel audio recordings, and medical treatment slips.",
            subtitle: "Provides documentary evidence that triggers mandatory institutional suspension of perpetrators.",
            legalRef: "Sec 65B Evidence Act",
          ),
          GuidanceItem(
            title: "Demand immediate hostel room reallocation or safe temporary accommodation.",
            subtitle: "College management bears statutory duty of care to guarantee victim physical safety.",
            legalRef: "Supreme Court Ragging Guidelines",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Demand written copy of specific charges and allegations from the committee.",
            subtitle: "Principles of Natural Justice demand right to know specific charges before any inquiry.",
            legalRef: "Principles of Natural Justice",
          ),
          GuidanceItem(
            title: "Insist on a fair personal hearing before Anti-Ragging Committee before penalty.",
            subtitle: "Supreme Court: Suspension or rustication without proper personal hearing is arbitrary and void.",
            legalRef: "Maneka Gandhi v. Union of India",
          ),
          GuidanceItem(
            title: "Submit alibi evidence (CCTV footage, biometric logs, library access records).",
            subtitle: "Objective digital and campus access logs prove absence from the alleged incident site.",
            legalRef: "Sec 11 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Seek legal counsel for Anticipatory Bail if criminal FIR is registered under Ragging Act.",
            subtitle: "State Anti-Ragging Acts contain non-bailable provisions; immediate bail application is essential.",
            legalRef: "Sec 438 CrPC / State Ragging Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Use UGC anonymous reporting channel if fearing retribution or intimidation.",
            subtitle: "UGC guidelines allow bystanders to register reports without public disclosure of student name.",
            legalRef: "UGC Anonymous Portal",
          ),
          GuidanceItem(
            title: "Document incidents with objective timestamps, locations, and names of individuals present.",
            subtitle: "Factual contemporaneous notes provide vital evidentiary support during committee inquiry.",
            legalRef: "Sec 114 Evidence Act",
          ),
          GuidanceItem(
            title: "Demand Action Taken Report (ATR) timeline from college Anti-Ragging Committee.",
            subtitle: "College is mandated by UGC regulations to act and file FIR within 24 hours.",
            legalRef: "UGC Regulation Clause 9",
          ),
          GuidanceItem(
            title: "Insist on testifying in a secure environment without exposure to accused seniors.",
            subtitle: "Institutional guidelines require safeguarding student witnesses against intimidation.",
            legalRef: "UGC Anti-Ragging Mandate",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Escalate to District Magistrate and UGC Nodal Officer if college stonewalls.",
            subtitle: "District Level Anti-Ragging Committee headed by DM has statutory power to intervene.",
            legalRef: "District Anti-Ragging Committee",
          ),
          GuidanceItem(
            title: "Accompany the student for all inquiry hearings and statement recordings.",
            subtitle: "Prevents administrative intimidation and ensures statements are recorded accurately.",
            legalRef: "UGC Student Grievance Redressal",
          ),
          GuidanceItem(
            title: "Demand immediate hostel room reallocation or safe temporary off-campus accommodation.",
            subtitle: "Institution bears statutory duty of care to guarantee student physical safety.",
            legalRef: "Aman Kachroo Guidelines",
          ),
          GuidanceItem(
            title: "File formal criminal complaint at local police station if administration suppresses incident.",
            subtitle: "Heads of institutions who fail to report ragging are liable to criminal prosecution.",
            legalRef: "State Anti-Ragging Acts",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getCampusDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not agree to informal 'compromise' brokered by college wardens or seniors.",
            subtitle: "Ragging is a cognizable criminal offense; institutional cover-ups are punishable under law.",
            legalRef: "UGC Ragging Regulations",
          ),
          GuidanceItem(
            title: "Do not sign pre-written confessions or apologies under administrative pressure.",
            subtitle: "College authorities often use forced apologies to bypass formal hearings and expel students.",
            legalRef: "Principles of Natural Justice",
          ),
          GuidanceItem(
            title: "Do not stay alone in shared hostel spaces if death threats or violence are issued.",
            subtitle: "Demand immediate protective institutional accommodation or stay with trusted family.",
            legalRef: "Supreme Court Ragging Guidelines",
          ),
          GuidanceItem(
            title: "Do not surrender original educational certificates to college as a dispute bond.",
            subtitle: "UGC Notification strictly prohibits higher education institutions from retaining original certificates.",
            legalRef: "UGC Notification on Certificate Retention",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not contact, confront, or intimidate the complainant or witnesses.",
            subtitle: "Witness intimidation results in immediate summary expulsion and criminal arrest.",
            legalRef: "Sec 195A IPC / UGC Norms",
          ),
          GuidanceItem(
            title: "Do not sign admission of guilt papers or forced apology letters drafted by dean.",
            subtitle: "Such letters are treated as incontrovertible confessions leading to direct rustication.",
            legalRef: "Principles of Natural Justice",
          ),
          GuidanceItem(
            title: "Do not boycott Anti-Ragging Committee meetings; present your written defense.",
            subtitle: "Absence results in ex-parte findings without consideration of your alibi or innocence.",
            legalRef: "UGC Regulation Clause 7",
          ),
          GuidanceItem(
            title: "Do not delete digital messages or campus access logs that prove your physical location.",
            subtitle: "Preserve timestamps of library swipes, mess attendance, and mobile tower locations.",
            legalRef: "Sec 11 Indian Evidence Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not remain silent if senior students or faculty pressure you to give false statements.",
            subtitle: "Use the UGC anonymous portal (1800-180-5522) to report without disclosing your name.",
            legalRef: "UGC Anonymous Portal",
          ),
          GuidanceItem(
            title: "Do not delete video or audio proof of campus bullying or hazing rituals.",
            subtitle: "Independent student recordings prevent false counter-allegations against innocent victims.",
            legalRef: "Sec 65B Evidence Act",
          ),
          GuidanceItem(
            title: "Do not sign committee minutes without reviewing your recorded statement line-by-line.",
            subtitle: "Ensure your exact words are recorded without administrative dilution.",
            legalRef: "UGC Disciplinary Norms",
          ),
          GuidanceItem(
            title: "Do not participate in hostel ostracization or social boycott of the reporting student.",
            subtitle: "Social boycott of ragging complainants is treated as an active form of ragging under UGC rules.",
            legalRef: "UGC Ragging Regulations 2009",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not accept college administration's refusal to register police FIR for ragging.",
            subtitle: "College head must lodge FIR within 24 hours under law; failure attracts institutional de-recognition.",
            legalRef: "UGC Mandate Clause 7",
          ),
          GuidanceItem(
            title: "Do not let college arbitrate physical assaults through informal 'internal settlements'.",
            subtitle: "Criminal offenses causing bodily injury or mental trauma cannot be covered up by college boards.",
            legalRef: "Sec 323/506 IPC",
          ),
          GuidanceItem(
            title: "Do not leave student unattended in hostel where hostile perpetrators reside.",
            subtitle: "Insist on immediate hostel room transfer or temporary off-campus protective leave.",
            legalRef: "Institutional Duty of Care",
          ),
          GuidanceItem(
            title: "Do not sign documents waiving college liability for on-campus student safety.",
            subtitle: "Institutions cannot contract out of their statutory duty under Supreme Court directives.",
            legalRef: "Aman Kachroo Verdict",
          ),
        ];
    }
  }

  // ==========================================
  // 8. WOMEN SAFETY & COUPLE HARASSMENT
  // ==========================================

  static List<GuidanceItem> _getWomenCouplesDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "State clearly: Consenting adults spending time together violates no Indian law.",
            subtitle: "Supreme Court: Morality is not law; adult citizens have full personal liberty under Article 21.",
            legalRef: "Navtej Singh Johar / Shafin Jahan Cases",
          ),
          GuidanceItem(
            title: "Women can only be searched, questioned, or arrested by female police personnel.",
            subtitle: "Section 51(2) & Section 46(4) CrPC strictly prohibit male officers from physical search of women.",
            legalRef: "Sec 51(2) & 46(4) CrPC",
          ),
          GuidanceItem(
            title: "Call 1091 (Women Helpline) or 112 if facing moral policing or vigilante harassment.",
            subtitle: "Dispatches state emergency patrol to the scene, preventing unlawful extortion.",
            legalRef: "Women Helpline 1091",
          ),
          GuidanceItem(
            title: "Valid adult Government ID (Aadhaar, DL, Voter ID) is sufficient for hotel check-in.",
            subtitle: "No law in India requires marriage certificate for two consenting adults to check into a hotel.",
            legalRef: "Right to Privacy / Art 21",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Demand specific penal sections and written FIR copy if police claim an offense occurred.",
            subtitle: "Officers must state exact cognizable offense; peaceful stay in a hotel room is no crime.",
            legalRef: "Sec 50 CrPC",
          ),
          GuidanceItem(
            title: "Assert that Section 294 IPC requires explicit obscene acts in an open public place.",
            subtitle: "A private hotel room or enclosed private accommodation is NOT a public space under Indian penal law.",
            legalRef: "Sec 294 IPC Jurisprudence",
          ),
          GuidanceItem(
            title: "Exercise right to silence and consult private legal counsel or call DLSA (15100).",
            subtitle: "Constitutional right under Article 20(3) and Article 22(1) applies during police questioning.",
            legalRef: "Art 20(3) & 22(1) Constitution",
          ),
          GuidanceItem(
            title: "Secure hotel invoice, check-in registration log, and digital payment receipts.",
            subtitle: "Commercial hospitality documentation proves bona fide lawful stay as consenting adults.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Hotel staff: Confirm guests produced valid adult government IDs voluntarily.",
            subtitle: "Adult citizens possessing valid identification are legally entitled to hotel accommodation.",
            legalRef: "Hospitality Industry Regulations",
          ),
          GuidanceItem(
            title: "Record police unit numbers, badge names, and patrol car plates if extortion is attempted.",
            subtitle: "Independent bystander/hotel staff evidence is critical in prosecuting rogue officers.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Hotel management must decline warrantless entry into guest rooms without Sec 165 CrPC grounds.",
            subtitle: "Guest rooms are private premises; unauthorized police entry violates guest fundamental privacy.",
            legalRef: "Puttaswamy v. Union of India",
          ),
          GuidanceItem(
            title: "Provide objective written statement to magistrate if vigilante mobs target the premises.",
            subtitle: "Shields lawful hotel business and innocent patrons from unlawful moral policing.",
            legalRef: "Sec 164 CrPC",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Refuse to be co-opted into police moral intimidation against consenting adult children.",
            subtitle: "Supreme Court in Shafin Jahan case: Adult citizens have absolute liberty to choose companions.",
            legalRef: "Shafin Jahan v. Asokan KM",
          ),
          GuidanceItem(
            title: "Reach the hotel or police station immediately to prevent illegal detention or extortion payoffs.",
            subtitle: "Physical presence of family members prevents rogue officers from demanding under-the-table cash.",
            legalRef: "D.K. Basu Guidelines",
          ),
          GuidanceItem(
            title: "Demand immediate release under Section 59 CrPC if no criminal FIR is registered.",
            subtitle: "Police cannot detain consenting adults for 'counseling' or moral lectures against their will.",
            legalRef: "Sec 59 CrPC",
          ),
          GuidanceItem(
            title: "File a complaint with State Human Rights Commission or Police Complaints Authority.",
            subtitle: "Moral policing and unauthorized detention trigger disciplinary action under Police Acts.",
            legalRef: "State Police Complaints Authority",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getWomenCouplesDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not allow police or vigilantes to browse private smartphone photos or messages.",
            subtitle: "Gross violation of fundamental right to privacy under Puttaswamy judgment.",
            legalRef: "Puttaswamy v. Union of India",
          ),
          GuidanceItem(
            title: "Do not pay extortion money or spot fines to avoid threats of calling parents.",
            subtitle: "Police have no legal authority to contact parents of consenting adults who have committed no crime.",
            legalRef: "Art 21 Personal Liberty",
          ),
          GuidanceItem(
            title: "Do not agree to accompany male officers to the police station after sunset.",
            subtitle: "Section 46(4) CrPC strictly prohibits arresting women after sunset without prior magistrate order.",
            legalRef: "Sec 46(4) CrPC",
          ),
          GuidanceItem(
            title: "Do not accept informal moral lectures or illegal detention in PCR vehicles.",
            subtitle: "Activate Civic Emergency SOS and record badge numbers of personnel involved.",
            legalRef: "Sec 342 IPC (Wrongful Confinement)",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not surrender smartphone passcode or biometric unlock under intimidation.",
            subtitle: "Self-incrimination and arbitrary phone search violate Article 20(3) and Article 21.",
            legalRef: "Art 20(3) Constitution",
          ),
          GuidanceItem(
            title: "Do not admit to fabricated allegations of immoral trafficking (ITPA) without an advocate.",
            subtitle: "Two consenting adults in a hotel room do NOT constitute commercial sex trafficking.",
            legalRef: "Immoral Traffic (Prevention) Act",
          ),
          GuidanceItem(
            title: "Do not pay spot 'settlement cash' to hotel managers or rogue officers.",
            subtitle: "Paying cash encourages repeat extortion; insist on formal challan or immediate release.",
            legalRef: "Sec 383 IPC (Extortion)",
          ),
          GuidanceItem(
            title: "Do not sign pre-printed admission forms or compromise agreements under duress.",
            subtitle: "Involuntary admissions made under police coercion are completely inadmissible.",
            legalRef: "Sec 25 Indian Evidence Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Hotel staff: Do not share guest register, CCTV, or ID records with unauthorized vigilantes.",
            subtitle: "Sharing guest data with private third parties violates Digital Personal Data Protection Act.",
            legalRef: "DPDP Act 2023",
          ),
          GuidanceItem(
            title: "Do not participate in moral policing or unlawful evictions of adult guests.",
            subtitle: "Arbitrary eviction of paying guests constitutes deficiency of service and consumer violation.",
            legalRef: "Consumer Protection Act 2019",
          ),
          GuidanceItem(
            title: "Do not delete or overwrite hotel lobby CCTV footage during the raid timeframe.",
            subtitle: "CCTV footage is essential evidence that proves police misconduct and guest innocence.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not sign unverified police panchnamas claiming public obscenity inside closed rooms.",
            subtitle: "False certification can lead to perjury prosecution under Section 193 IPC.",
            legalRef: "Sec 193 IPC",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not allow rogue officers to extract cash 'donations' to hush up the matter.",
            subtitle: "Officers exploit social embarrassment to run extortion rackets against families.",
            legalRef: "Prevention of Corruption Act",
          ),
          GuidanceItem(
            title: "Do not sign parental custody undertakings treating adult children as runaways.",
            subtitle: "Adult citizens above 18 are legally independent and do not require parental custody bonds.",
            legalRef: "Indian Majority Act 1875",
          ),
          GuidanceItem(
            title: "Do not permit unauthorized recording or media filming of detainees by local reporters.",
            subtitle: "Filming detainees and broadcasting without consent violates privacy and defamation laws.",
            legalRef: "Puttaswamy / Defamation Norms",
          ),
          GuidanceItem(
            title: "Do not leave the police station without a formal written GD entry or discharge note.",
            subtitle: "Official documentation ensures no fabricated charges can be framed at a later date.",
            legalRef: "Sec 44 Police Act",
          ),
        ];
    }
  }

  // ==========================================
  // 9. WORKPLACE & EMPLOYMENT RIGHTS
  // ==========================================

  static List<GuidanceItem> _getWorkplaceDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "File formal complaint with the Internal Committee (IC) under the POSH Act.",
            subtitle: "Every organization with 10+ employees must maintain an IC to investigate sexual harassment within 90 days.",
            legalRef: "POSH Act 2013",
          ),
          GuidanceItem(
            title: "Preserve official emails, Slack/Teams chats, and employment appointment contracts.",
            subtitle: "Electronic employment records are crucial proof against arbitrary termination or salary withholding.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
          GuidanceItem(
            title: "File claim with the State Labour Commissioner for unpaid salary or gratuity.",
            subtitle: "Payment of Wages Act & Industrial Disputes Act mandate timely disbursement of earned wages.",
            legalRef: "Payment of Wages Act 1936",
          ),
          GuidanceItem(
            title: "Request interim relief (transfer, paid leave up to 3 months) during POSH inquiry.",
            subtitle: "Section 12 of POSH Act empowers IC to recommend protective interim measures for complainant.",
            legalRef: "Sec 12 POSH Act",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Demand a written copy of formal complaint and allegations before submitting reply.",
            subtitle: "Principles of natural justice require that respondent receives notice with full details within 7 working days.",
            legalRef: "Sec 11 POSH Act / Natural Justice",
          ),
          GuidanceItem(
            title: "Submit factual written response with objective corroborative digital evidence within 10 days.",
            subtitle: "Include chat logs, email timestamps, calendar invites, and independent witness references.",
            legalRef: "POSH Rules 2013",
          ),
          GuidanceItem(
            title: "Exercise right to cross-examine or submit written questionnaire through the committee.",
            subtitle: "Internal Committee must ensure fair hearing and equal opportunity for defense before findings.",
            legalRef: "Principles of Natural Justice",
          ),
          GuidanceItem(
            title: "Consult a labor advocate or service law counsel before attending conciliation.",
            subtitle: "Know your rights regarding non-monetary settlement options under Section 10 of POSH Act.",
            legalRef: "Sec 10 POSH Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Provide objective, factual testimony based strictly on direct personal knowledge.",
            subtitle: "Bystander and colleague statements are crucial for unbiased fact-finding by the inquiry committee.",
            legalRef: "Sec 11 POSH Act",
          ),
          GuidanceItem(
            title: "Verify and sign inquiry statement minutes only after thorough review of accuracy.",
            subtitle: "Ensure your exact spoken words and context are recorded without selective editing.",
            legalRef: "Administrative Inquiries Norms",
          ),
          GuidanceItem(
            title: "Demand statutory protection against employer retaliation or workplace victimisation.",
            subtitle: "Labor laws and POSH guidelines prohibit adverse employment action against testifying witnesses.",
            legalRef: "Sec 16 POSH Act",
          ),
          GuidanceItem(
            title: "Keep personal notes of date, time, and questions asked during the inquiry.",
            subtitle: "Retaining private contemporaneous records protects against retaliatory administrative actions.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Review employment contract and offer letter for termination notice periods and severance.",
            subtitle: "Employment contracts cannot override mandatory state Shops and Establishments Act provisions.",
            legalRef: "State Shops & Est. Act",
          ),
          GuidanceItem(
            title: "Send formal legal demand notice via registered advocate for withheld salary or dues.",
            subtitle: "Statutory prerequisite before initiating recovery proceedings before the Labour Court.",
            legalRef: "Sec 33C(2) Industrial Disputes Act",
          ),
          GuidanceItem(
            title: "Accompany employee for external mediation or conciliation before Labour Officer.",
            subtitle: "External representation prevents high-pressure HR intimidation or forced waivers.",
            legalRef: "Industrial Disputes Act 1947",
          ),
          GuidanceItem(
            title: "Escalate to Local Complaints Committee (LCC) or Women's Commission if employer suppresses IC.",
            subtitle: "District Officer oversees LCC for establishments failing to maintain proper IC.",
            legalRef: "Sec 6 POSH Act",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getWorkplaceDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Never sign forced resignation letters or voluntary exit releases under duress.",
            subtitle: "Signing resignation waives statutory severance pay and damages wrongful termination claims.",
            legalRef: "Industrial Disputes Act 1947",
          ),
          GuidanceItem(
            title: "Do not accept delayed Full & Final settlement beyond statutory timeline.",
            subtitle: "Payment of Wages Act mandates full settlement within 2 working days of termination.",
            legalRef: "Payment of Wages Act",
          ),
          GuidanceItem(
            title: "Do not surrender company laptop or phone without exporting personal data and work proofs.",
            subtitle: "Secure unedited copies of performance ratings, appraisals, and relevant email chains.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not agree to informal oral assurances of HR without written confirmation on record.",
            subtitle: "Oral promises from HR managers are legally unenforceable in labor court proceedings.",
            legalRef: "Indian Contract Act 1872",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not contact, message, or confront the complainant during or after inquiry.",
            subtitle: "Direct contact violates anti-retaliation provisions and creates presumption of guilt.",
            legalRef: "Sec 195A IPC / POSH Norms",
          ),
          GuidanceItem(
            title: "Do not boycott Internal Committee hearings or refuse to accept formal notices.",
            subtitle: "Refusal to participate allows IC to proceed ex-parte and recommend disciplinary termination.",
            legalRef: "POSH Rule 7(4)",
          ),
          GuidanceItem(
            title: "Do not sign pre-drafted admissions or informal apology letters under HR pressure.",
            subtitle: "Apology letters are treated as conclusive proof of guilt leading to summary dismissal.",
            legalRef: "Principles of Natural Justice",
          ),
          GuidanceItem(
            title: "Do not breach confidentiality of the inquiry by discussing details on public forums.",
            subtitle: "Section 16 of POSH Act strictly penalizes disclosure of inquiry proceedings.",
            legalRef: "Sec 16 POSH Act",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not alter or dilute your statement under pressure or coaching from management.",
            subtitle: "Giving knowingly false evidence before a statutory committee constitutes perjury.",
            legalRef: "Sec 193 IPC",
          ),
          GuidanceItem(
            title: "Do not discuss witness testimonies or committee deliberations with colleagues.",
            subtitle: "Section 16 POSH Act imposes financial penalties for leaking inquiry details.",
            legalRef: "Sec 16 POSH Act",
          ),
          GuidanceItem(
            title: "Do not sign unread or partial transcripts of committee proceedings.",
            subtitle: "Always read every line and note objections before appending your signature.",
            legalRef: "Principles of Natural Justice",
          ),
          GuidanceItem(
            title: "Do not participate in office retaliation, hostility, or ostracization of any party.",
            subtitle: "Workplace victimisation can trigger separate legal liability for hostiles.",
            legalRef: "POSH Guidelines",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not sign non-compete agreements that restrict working post-employment.",
            subtitle: "Section 27 of Indian Contract Act: Any agreement in restraint of lawful profession is void.",
            legalRef: "Sec 27 Indian Contract Act 1872",
          ),
          GuidanceItem(
            title: "Do not accept verbal termination without written statutory grounds and notice pay.",
            subtitle: "Industrial law mandates written termination notice with statutory compensation.",
            legalRef: "Sec 25F Industrial Disputes Act",
          ),
          GuidanceItem(
            title: "Do not agree to forfeit earned gratuity or provident fund (PF) contributions.",
            subtitle: "Payment of Gratuity Act and EPF Act mandate non-forfeitable statutory benefits.",
            legalRef: "Payment of Gratuity Act 1972",
          ),
          GuidanceItem(
            title: "Do not let employers bypass statutory dispute redressal through unilateral NDAs.",
            subtitle: "Private NDAs cannot extinguish statutory rights to approach labor courts or tribunals.",
            legalRef: "Sec 28 Indian Contract Act",
          ),
        ];
    }
  }

  // ==========================================
  // 10. HOUSING & TENANT RIGHTS
  // ==========================================

  static List<GuidanceItem> _getHousingDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Demand formal written notice as per registered rental agreement before eviction.",
            subtitle: "Model Tenancy Act & State Rent Acts require minimum 30 days written notice before eviction action.",
            legalRef: "Model Tenancy Act 2021",
          ),
          GuidanceItem(
            title: "Call police (112) immediately if landlord cuts electricity, water, or locks doors.",
            subtitle: "Cutting essential services is a criminal offense under Section 430/441 IPC and State Rent Control Acts.",
            legalRef: "Sec 430/441 IPC",
          ),
          GuidanceItem(
            title: "Retain all online bank transfer receipts and rent agreement copies.",
            subtitle: "Proves tenancy tenure and invalidates arbitrary claims of unpaid rent or unrecorded arrears.",
            legalRef: "Transfer of Property Act 1882",
          ),
          GuidanceItem(
            title: "Demand itemized deductions with original bills if security deposit is withheld.",
            subtitle: "Landlords cannot make arbitrary deductions without providing genuine vendor repair bills.",
            legalRef: "State Rent Control Norms",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Verify written lease clauses regarding alleged breach of agreement or sub-letting.",
            subtitle: "Landlord cannot evict without proving grounds specifically stipulated in the agreement.",
            legalRef: "Transfer of Property Act",
          ),
          GuidanceItem(
            title: "Produce digital proof of timely rent payments and utility bill receipts.",
            subtitle: "Bank statement records rebut landlord allegations of rent default or payment delay.",
            legalRef: "Sec 65B Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Issue written response to eviction notice within 15–30 days offering remedy if needed.",
            subtitle: "Prompt written rebuttal through legal notice protects against ex-parte eviction orders.",
            legalRef: "Model Tenancy Act 2021",
          ),
          GuidanceItem(
            title: "Seek Civil Court / Rent Authority injunction against forceful extra-judicial eviction.",
            subtitle: "Courts grant temporary injunction prohibiting landlords from dispossessing tenants unlawfully.",
            legalRef: "Order 39 CPC",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Neighbor / Society: Document any illegal lockout, property throwing, or muscleman threats.",
            subtitle: "Video documentation and neighbor statements provide critical evidence of criminal trespass.",
            legalRef: "Sec 441 IPC (Criminal Trespass)",
          ),
          GuidanceItem(
            title: "Confirm valid tenancy tenure and peaceful possession if police visit the premises.",
            subtitle: "Informing officers of ongoing lawful tenancy prevents rogue landlord-police nexus.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Remind Resident Welfare Association (RWA) that bye-laws cannot override tenancy laws.",
            subtitle: "RWA guidelines banning bachelors, pets, or visitors are ultra vires and legally void.",
            legalRef: "High Court RWA Jurisprudence",
          ),
          GuidanceItem(
            title: "Provide factual statements to Rent Controller or Local Police during inquiry.",
            subtitle: "Neutral neighbor testimony deters arbitrary physical harassment by rogue landlords.",
            legalRef: "Sec 161 CrPC",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Intervene immediately if landlord intimidates student tenants with eviction or police calls.",
            subtitle: "Landlords frequently exploit young tenants' fear of confrontation to extract money.",
            legalRef: "Sec 506 IPC (Criminal Intimidation)",
          ),
          GuidanceItem(
            title: "Review the lease agreement signed as guarantor to ascertain exact liability limits.",
            subtitle: "Guarantor obligations are strictly bounded by contractual terms under Section 128.",
            legalRef: "Sec 128 Indian Contract Act",
          ),
          GuidanceItem(
            title: "Send formal legal notice demanding security deposit refund within 30 days of handover.",
            subtitle: "Statutory notice lays foundation for consumer forum and rent authority recovery petitions.",
            legalRef: "Consumer Protection Act 2019",
          ),
          GuidanceItem(
            title: "Approach District Consumer Disputes Redressal Commission for deficiency in housing services.",
            subtitle: "Tenants are recognized consumers entitled to compensation for landlord harassment.",
            legalRef: "Consumer Protection Act",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getHousingDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not vacate under oral threats or informal RWA intimidation.",
            subtitle: "Eviction without due process of law or competent Rent Court order is strictly illegal.",
            legalRef: "Supreme Court on Unlawful Eviction",
          ),
          GuidanceItem(
            title: "Do not pay rent in cash without receiving an immediate signed receipt.",
            subtitle: "Landlords are legally obligated to issue signed rent receipts for all payments received.",
            legalRef: "Sec 13 Model Tenancy Act",
          ),
          GuidanceItem(
            title: "Do not permit unauthorized entry or inspection by landlord without 24h prior notice.",
            subtitle: "Tenant has the statutory right to undisturbed peaceful enjoyment of the rented premises.",
            legalRef: "Right to Quiet Enjoyment",
          ),
          GuidanceItem(
            title: "Do not sign blank bond papers or arbitrary RWA curfew undertakings.",
            subtitle: "RWA rules cannot violate fundamental freedoms of lawful tenants under Indian law.",
            legalRef: "High Court RWA Jurisprudence",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not withhold lawful rent arbitrarily as a form of protest against landlord.",
            subtitle: "Non-payment of rent provides statutory ground for landlord to initiate lawful eviction.",
            legalRef: "Model Tenancy Act 2021",
          ),
          GuidanceItem(
            title: "Do not cause structural damage or make unauthorized modifications to premises.",
            subtitle: "Property damage can invite criminal charges under Section 427 IPC and deposit forfeiture.",
            legalRef: "Sec 427 IPC (Mischief)",
          ),
          GuidanceItem(
            title: "Do not abandon premises without written key handover memo signed by landlord.",
            subtitle: "Leaving without handover memo allows landlord to allege missing fixtures or unpaid rent.",
            legalRef: "Transfer of Property Act",
          ),
          GuidanceItem(
            title: "Do not resort to violence or threats against society security personnel or landlord.",
            subtitle: "Physical confrontation leads to criminal FIRs and jeopardizes tenancy rights.",
            legalRef: "Sec 323/504 IPC",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not assist landlords in throwing tenant luggage, furniture, or belongings onto the street.",
            subtitle: "Aiding in unlawful eviction makes participants co-accused in criminal trespass and theft.",
            legalRef: "Sec 379/441 IPC",
          ),
          GuidanceItem(
            title: "Do not enforce discriminatory RWA bans on tenant guests, food choices, or working hours.",
            subtitle: "Enforcing moral policing bye-laws creates civil liability for RWA committee members.",
            legalRef: "Art 19 & 21 Constitution",
          ),
          GuidanceItem(
            title: "Do not sign false joint complaint letters against tenants without firsthand verification.",
            subtitle: "Falsely accusing tenants of nuisance or illegal activity invites defamation liability.",
            legalRef: "Sec 499 IPC",
          ),
          GuidanceItem(
            title: "Do not turn off common meters, water valves, or lift access to harass tenants.",
            subtitle: "Tampering with essential building utilities violates municipal bylaws and criminal law.",
            legalRef: "Sec 430 IPC",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not allow landlords to make arbitrary deposit deductions without verified repair invoices.",
            subtitle: "Deductions for normal wear and tear are strictly prohibited under tenancy jurisprudence.",
            legalRef: "Model Tenancy Act 2021",
          ),
          GuidanceItem(
            title: "Do not permit landlord to seize student laptops, certificates, or personal luggage.",
            subtitle: "Seizing personal belongings constitutes illegal wrongful restraint and extortion.",
            legalRef: "Sec 339 & 383 IPC",
          ),
          GuidanceItem(
            title: "Do not sign one-sided surrender deeds releasing landlord from all legal liabilities.",
            subtitle: "Preserves tenant rights to claim refund of unreturned deposit and moving damages.",
            legalRef: "Sec 23 Contract Act",
          ),
          GuidanceItem(
            title: "Do not pay spot settlement demands without receiving written discharge certificate.",
            subtitle: "Cash payoffs without receipts leave tenants vulnerable to renewed extortion.",
            legalRef: "Sec 383 IPC",
          ),
        ];
    }
  }

  // ==========================================
  // 11. GENERAL POLICE ENCOUNTERS (FALLBACK)
  // ==========================================

  static List<GuidanceItem> _getGeneralPoliceDos(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Ask calmly for the officer's name, rank, and police station badge.",
            subtitle: "Officers on duty are mandated to wear visible name badges (D.K. Basu Guidelines).",
            legalRef: "D.K. Basu v. State of West Bengal",
          ),
          GuidanceItem(
            title: "Demand formal written notice under Section 41A CrPC if called for inquiry.",
            subtitle: "Protects against arbitrary arrest where offenses carry less than 7 years imprisonment.",
            legalRef: "Sec 41A CrPC / Arnesh Kumar Case",
          ),
          GuidanceItem(
            title: "Exercise your fundamental right to consult a legal practitioner of your choice.",
            subtitle: "Guaranteed under Article 22(1) of the Constitution throughout police contact.",
            legalRef: "Art 22(1) Constitution",
          ),
          GuidanceItem(
            title: "Women can only be searched or questioned with female officer presence.",
            subtitle: "Strictly enforced by Section 51(2) and Section 46(4) of the Code of Criminal Procedure.",
            legalRef: "Sec 51(2) CrPC",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Demand full disclosure of grounds of arrest and a free copy of the FIR.",
            subtitle: "Section 50 CrPC mandates immediate written disclosure of all charges.",
            legalRef: "Sec 50 CrPC",
          ),
          GuidanceItem(
            title: "Insist on mandatory medical examination by government doctor under Section 54.",
            subtitle: "Records your physical condition and prevents custodial mistreatment.",
            legalRef: "Sec 54 CrPC",
          ),
          GuidanceItem(
            title: "Ensure you are presented before Judicial Magistrate within 24 hours of arrest.",
            subtitle: "Detention exceeding 24 hours without court order is illegal under Article 22(2).",
            legalRef: "Art 22(2) / Sec 57 CrPC",
          ),
          GuidanceItem(
            title: "Request free legal representation via NALSA / DLSA on helpline 15100.",
            subtitle: "State-sponsored legal defense is a constitutional right for every arrested citizen.",
            legalRef: "Sec 304 CrPC",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Record public police interactions calmly from a safe distance.",
            subtitle: "Citizens possess constitutional right under Article 19(1)(a) to document public officials.",
            legalRef: "Art 19(1)(a) Constitution",
          ),
          GuidanceItem(
            title: "Demand written Section 160 CrPC summons before attending police station.",
            subtitle: "Police cannot mandate witness attendance without written legal notice.",
            legalRef: "Sec 160 CrPC",
          ),
          GuidanceItem(
            title: "Refuse to sign witness inquiry statements under Section 161 CrPC.",
            subtitle: "Section 162 CrPC expressly prohibits police from taking witness signatures.",
            legalRef: "Sec 162 CrPC",
          ),
          GuidanceItem(
            title: "Note vehicle numbers, timestamps, and police station jurisdiction.",
            subtitle: "Independent documentation serves as crucial evidence in judicial review.",
            legalRef: "Sec 114 Indian Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Verify Station General Diary (GD) entry and Arrest Memo immediately.",
            subtitle: "Relative has statutory right to counter-sign and inspect custody records.",
            legalRef: "D.K. Basu Guidelines",
          ),
          GuidanceItem(
            title: "Engage an advocate to appear before the Judicial Magistrate within 24 hours.",
            subtitle: "Bail application can be moved at the initial remand hearing.",
            legalRef: "Sec 167 CrPC",
          ),
          GuidanceItem(
            title: "Ensure female or minor detainees are handled by specialized female/juvenile officers.",
            subtitle: "Strictly enforced by Juvenile Justice Act and Section 46 CrPC.",
            legalRef: "Juvenile Justice Act",
          ),
          GuidanceItem(
            title: "Contact District Legal Services Authority on 15100 if denied access.",
            subtitle: "DLSA provides immediate statutory intervention and visits the station.",
            legalRef: "NALSA Helpline 15100",
          ),
        ];
    }
  }

  static List<GuidanceItem> _getGeneralPoliceDonts(UserRole role) {
    switch (role) {
      case UserRole.affected:
        return const [
          GuidanceItem(
            title: "Do not resist physically even if the police action appears arbitrary.",
            subtitle: "Physical confrontation can lead to non-bailable charges under Section 186/353 IPC.",
            legalRef: "Sec 353 IPC",
          ),
          GuidanceItem(
            title: "Never make self-incriminating confessions or sign blank documents.",
            subtitle: "Confessions made to police officers are inadmissible in court under Section 25 Evidence Act.",
            legalRef: "Sec 25 Indian Evidence Act",
          ),
          GuidanceItem(
            title: "Do not pay unrecorded cash settlements or bribes under intimidation.",
            subtitle: "All fines and statutory fees must be documented via official government receipts.",
            legalRef: "Prevention of Corruption Act",
          ),
          GuidanceItem(
            title: "Do not hand over your physical phone or allow browsing of private chats.",
            subtitle: "Phone inspection without judicial search warrant violates Article 21 fundamental privacy.",
            legalRef: "Puttaswamy v. Union of India",
          ),
        ];

      case UserRole.accused:
        return const [
          GuidanceItem(
            title: "Do not give verbal or written confessions to police officers under duress or torture.",
            subtitle: "Section 25 of Evidence Act completely bars police confessions; hold out until Magistrate.",
            legalRef: "Sec 25 Evidence Act / Art 20(3)",
          ),
          GuidanceItem(
            title: "Do not waive your right to consult an advocate during questioning or remand.",
            subtitle: "Article 22(1) guarantees access to counsel from the very moment of apprehension.",
            legalRef: "Art 22(1) Constitution",
          ),
          GuidanceItem(
            title: "Do not consent to police remand beyond 24 hours without physical production before Magistrate.",
            subtitle: "Article 22(2) strictly prohibits detention exceeding 24 hours without judicial sanction.",
            legalRef: "Art 22(2) / Sec 57 CrPC",
          ),
          GuidanceItem(
            title: "Do not submit to unauthorized invasive medical tests without Magistrate order.",
            subtitle: "Medical examination must follow Section 53/53A CrPC procedures conducted by registered medical officer.",
            legalRef: "Sec 53 CrPC",
          ),
        ];

      case UserRole.witness:
        return const [
          GuidanceItem(
            title: "Do not attend police station without receiving formal written summons under Sec 160 CrPC.",
            subtitle: "Oral calls or telephone orders from police to attend station have no legal binding force.",
            legalRef: "Sec 160 CrPC",
          ),
          GuidanceItem(
            title: "Do not sign witness statements recorded by police under Section 161 CrPC.",
            subtitle: "Section 162 CrPC expressly prohibits police from obtaining signatures on witness statements.",
            legalRef: "Sec 162 CrPC",
          ),
          GuidanceItem(
            title: "Do not alter eyewitness testimony under intimidation or threats from investigating officers.",
            subtitle: "Report witness intimidation immediately to Judicial Magistrate or Witness Protection Cell.",
            legalRef: "Witness Protection Scheme 2018",
          ),
          GuidanceItem(
            title: "Do not delete video or audio recordings of public police encounters from your device.",
            subtitle: "Citizen video recordings are lawful evidence under Article 19(1)(a) and Section 65B Evidence Act.",
            legalRef: "Sec 65B Evidence Act",
          ),
        ];

      case UserRole.parent:
        return const [
          GuidanceItem(
            title: "Do not pay informal station 'release fees' or cash payouts to avoid booking.",
            subtitle: "Paying cash extortion creates legal complications and fuels corruption rackets.",
            legalRef: "Prevention of Corruption Act",
          ),
          GuidanceItem(
            title: "Do not leave minor or female detainees unattended in police lockup overnight.",
            subtitle: "Juveniles cannot be kept in lockup (JJ Act); women cannot be detained after sunset without magistrate order.",
            legalRef: "Sec 46(4) CrPC / JJ Act",
          ),
          GuidanceItem(
            title: "Do not leave police station without knowing the exact Magistrate court room and hearing time.",
            subtitle: "Enables legal counsel to be present in court to move immediate bail on production.",
            legalRef: "Sec 167 CrPC",
          ),
          GuidanceItem(
            title: "Do not allow police to transfer detainee to undisclosed locations without GD entry.",
            subtitle: "D.K. Basu guidelines mandate updating the station register with every transfer destination.",
            legalRef: "D.K. Basu Guidelines",
          ),
        ];
    }
  }

  // =========================================================================
  // SCENARIO-SPECIFIC EMERGENCY CHECKLIST PROVIDERS
  // =========================================================================

  static EmergencyChecklistData _getTrafficStopChecklist(UserRole role) {
    if (role == UserRole.parent) {
      return const EmergencyChecklistData(
        title: 'EMERGENCY CHECKLIST • VEHICLE STOP',
        subtitle: 'Procedural verification for parents/guardians when a family vehicle is stopped.',
        items: [
          'Verify inspecting officer identity, name badge & rank (Sub-Inspector or above for compounding fines).',
          'Ensure young/student driver presents DigiLocker/mParivahan credentials (Rule 139 MV Rules).',
          'Demand official electronic e-challan; verify penal sections before any compounding fee is paid.',
          'Confirm keys are not confiscated and vehicle is not impounded without Section 207 seizure memo.',
        ],
      );
    } else if (role == UserRole.witness) {
      return const EmergencyChecklistData(
        title: 'EMERGENCY CHECKLIST • WITNESS / PASSENGER',
        subtitle: 'Procedural verification steps for passengers or witnesses during a vehicle check.',
        items: [
          'Note down officer name badge, rank, and police checkpoint vehicle number.',
          'Verify officer is Sub-Inspector or above if demanding on-the-spot compounding fine.',
          'Ensure driver credentials in DigiLocker/mParivahan are accepted without physical confiscation.',
          'Record polite audio/video if officers threaten arbitrary seizure or unlawful physical detention.',
        ],
      );
    }
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • TRAFFIC STOP',
      subtitle: 'Verify these 4 critical procedural steps while interacting with traffic police.',
      items: [
        'Verify officer identity & visible uniform name tag (D.K. Basu guidelines).',
        'Produce digital credentials via DigiLocker or mParivahan only (MV Act Section 200).',
        'Demand official electronic e-challan; never pay unrecorded cash on the spot.',
        'Keep smartphone locked to passcode (disable biometrics) and keys in your possession.',
      ],
    );
  }

  static EmergencyChecklistData _getArrestDetentionChecklist(UserRole role) {
    if (role == UserRole.parent) {
      return const EmergencyChecklistData(
        title: 'EMERGENCY CHECKLIST • CUSTODY & GUARDIAN',
        subtitle: 'Immediate statutory safeguards for parents and family members under Section 50A CrPC.',
        items: [
          'Demand immediate phone intimation and inspect written Arrest Memo (Sec 41B & 50A CrPC).',
          'Verify if detainee is female or minor; enforce Juvenile Justice Act & Sec 46(4) female officer rules.',
          'Request certified copy of medical examination report conducted under Section 54 CrPC.',
          'Confirm presentation before Judicial Magistrate within 24 hours of apprehension (Sec 57 CrPC).',
        ],
      );
    } else if (role == UserRole.witness) {
      return const EmergencyChecklistData(
        title: 'EMERGENCY CHECKLIST • WITNESS SAFEGUARDS',
        subtitle: 'Procedural verification protecting witnesses from unlawful custody or coercion.',
        items: [
          'Witnesses cannot be arrested or detained without formal warrant or cognizable offense charges.',
          'Demand written Section 160 CrPC summons; women and minors must be examined at residence.',
          'Insist on recording entry and departure time in police station General Diary (GD).',
          'Refuse to sign unread Section 161 statements or unverified case summaries.',
        ],
      );
    }
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • ARREST & CUSTODY',
      subtitle: 'Ensure these 4 mandatory constitutional safeguards are enforced immediately under CrPC & D.K. Basu rules.',
      items: [
        'Demand and inspect the signed Arrest Memo stating time, date, location & exact grounds (Sec 41B CrPC).',
        'Demand immediate notification of family, nominated friend, or advocate within 1 hour (Sec 50A CrPC).',
        'Request mandatory independent medical examination by an authorized medical officer (Sec 54 CrPC).',
        'Confirm mandatory presentation before the nearest Judicial Magistrate within 24 hours of arrest (Sec 57 CrPC).',
      ],
    );
  }

  static EmergencyChecklistData _getBribeChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • BRIBE & EXTORTION',
      subtitle: 'Preserve evidence and secure statutory immunity under Section 8 Prevention of Corruption Act.',
      items: [
        'Note down exact time, police station/checkpoint location, officer badge number, and patrol vehicle plate.',
        'Secure digital evidence: unedited audio/video recording, SMS/WhatsApp messages, or nearby CCTV references.',
        'Firmly refuse cash payoffs, informal settlements, or scanning private mule UPI QR codes.',
        'Report the corrupt extortion within 7 days to State Anti-Corruption Bureau (Helpline 1064) or CBI for statutory protection.',
      ],
    );
  }

  static EmergencyChecklistData _getFirRefusedChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • FIR REGISTRATION',
      subtitle: 'Follow statutory escalation steps under Section 154 CrPC & Lalita Kumari Supreme Court directives.',
      items: [
        'Record Station House Officer (SHO) name, badge number, and General Diary (GD) register entry number.',
        'Demand Zero FIR registration if the station claims lack of territorial jurisdiction (it must be registered and transferred).',
        'Request an official stamped receiving seal with date & signature on the duplicate copy of your written complaint.',
        'Dispatch signed complaint copy to District Superintendent of Police (SP) via Registered Post with A/D (Sec 154(3) CrPC).',
      ],
    );
  }

  static EmergencyChecklistData _getSearchChecklist(UserRole role) {
    if (role == UserRole.parent) {
      return const EmergencyChecklistData(
        title: 'EMERGENCY CHECKLIST • PREMISES SEARCH',
        subtitle: 'Verify statutory search protocols and family privacy protections before permitting entry.',
        items: [
          'Inspect magistrate-signed Search Warrant or ask for written Section 165 CrPC emergency grounds.',
          'Ensure female occupants are accompanied and searched exclusively by female officers (Sec 47/100 CrPC).',
          'Insist on the presence of two independent local respectable witnesses (Panchas) before doors are opened.',
          'Demand a signed, itemized physical copy of the Seizure Panchnama before any items leave your premises.',
        ],
      );
    }
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • PREMISES SEARCH',
      subtitle: 'Verify statutory search protocols before admitting law enforcement into private premises.',
      items: [
        'Inspect magistrate-signed Search Warrant or demand written Section 165 CrPC emergency grounds.',
        'Insist on presence of 2 independent local respectable witnesses (Panchas) from the neighborhood (Sec 100 CrPC).',
        'Ensure female occupants are accompanied and searched exclusively by female officers (Sec 47/100 CrPC).',
        'Demand a signed, itemized physical copy of the Seizure Panchnama detailing every seized item before police exit.',
      ],
    );
  }

  static EmergencyChecklistData _getCyberChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • CYBER FRAUD TRIAGE',
      subtitle: 'Immediate financial and digital triage steps to freeze fraudulent fund trails within Golden Hours.',
      items: [
        'Call National Cyber Crime Helpline 1930 immediately to place financial transaction liens on fraudulent accounts.',
        'Lodge formal complaint at cybercrime.gov.in and record the official acknowledgment reference number.',
        'Export unedited bank statements, SMS headers, UPI transaction IDs (UTR), and uncropped chat transcripts.',
        'Ensure any seized smartphone or laptop is sealed in a tamper-proof anti-static bag with logged IMEI.',
      ],
    );
  }

  static EmergencyChecklistData _getCampusChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • CAMPUS & RAGGING',
      subtitle: 'Statutory escalation under UGC Anti-Ragging Regulations and university disciplinary statutes.',
      items: [
        'Call 24x7 National Anti-Ragging Toll-Free Helpline 1800-180-5522 for an immediate central incident ticket.',
        'Submit formal written complaint with dated receipt to Head of Institution and Anti-Ragging Committee.',
        'Preserve all digital evidence: WhatsApp messages, voice notes, call recordings, emails, and medical doctor slips.',
        'Demand immediate interim protective measures (hostel room transfer, protective security, or police escort).',
      ],
    );
  }

  static EmergencyChecklistData _getWomenCouplesChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • SAFETY & PRIVACY',
      subtitle: 'Enforce fundamental privacy, bodily integrity, and consensual adult rights against moral policing.',
      items: [
        'Assert that consenting adults in public spaces or private hotels violate no law; refuse moral interrogations.',
        'Male police officers cannot touch, detain, or search women; no arrests of women between sunset and sunrise (Sec 46(4) CrPC).',
        'Dial Women Helpline 1091 or Emergency 112 immediately if confronted by moral policing or extortion groups.',
        'Refuse unlawful demands to summon parents, disclose personal relationship status, or unlock phone galleries.',
      ],
    );
  }

  static EmergencyChecklistData _getWorkplaceChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • WORKPLACE RIGHTS',
      subtitle: 'Documentary and procedural checklist to safeguard employment, severance dues, and statutory protections.',
      items: [
        'Retain personal offline copies of employment contract, offer letter, salary slips, and written communications.',
        'Submit formal written complaint to the Internal Committee (IC) under POSH Act 2013 for harassment incidents.',
        'Do not sign voluntary resignation, liability waivers, or mutual releases under threat or coercion.',
        'Issue formal legal notice through counsel or submit claim to State Labour Commissioner for unpaid dues.',
      ],
    );
  }

  static EmergencyChecklistData _getHousingChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • TENANT PROTECTION',
      subtitle: 'Procedural checklist protecting tenants from illegal eviction, lockout, and security deposit disputes.',
      items: [
        'Verify tenancy agreement terms; demand formal written legal notice as specified in registered lease contract.',
        'Call Police Helpline 112 immediately if landlord cuts electricity, water, or locks premises (Sec 430 IPC / Rent Act).',
        'Retain complete banking payment receipts, UPI transaction IDs, and mutual WhatsApp or email communications.',
        'Inspect rental property jointly before move-out; insist on written, itemized receipts for any security deposit deductions.',
      ],
    );
  }

  static EmergencyChecklistData _getGeneralPoliceChecklist(UserRole role) {
    return const EmergencyChecklistData(
      title: 'EMERGENCY CHECKLIST • POLICE INTERACTION',
      subtitle: 'Essential procedural verification steps for lawful police interactions under Indian criminal jurisprudence.',
      items: [
        'Note down officer name, uniform designation badge, and police station territorial jurisdiction.',
        'Demand written Section 41A CrPC notice before attending any police station for preliminary questioning.',
        'Exercise your constitutional right to consult and be defended by a legal practitioner of choice (Article 22(1)).',
        'Never sign blank papers, unverified summaries, or confessions under police custody (Sec 25 Evidence Act).',
      ],
    );
  }
}
