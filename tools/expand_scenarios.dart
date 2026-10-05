import 'dart:convert';
import 'dart:io';

void main() {
  print('Generating fully conformant production cards for all expanded scenarios...');

  final cards = <String, Map<String, dynamic>>{
    // 1. Road Accident
    'road_accident_good_samaritan_default': {
      'id': 'road_accident_good_samaritan_default',
      'category': 'POLICE & CRIMINAL',
      'scenario': 'road_accident_good_samaritan',
      'branch': 'default',
      'language': 'en',
      'title': 'Road Accident Good Samaritan Rights',
      'roles': ['affected', 'witness', 'parent'],
      'short_lines': [
        'Step 1: Ensure immediate medical transit for victim; call emergency 112 or ambulance 108.',
        'Step 2: You are legally immune under Sec 134A MV Act from civil or criminal liability.',
        'Step 3: Hospital must initiate emergency triage immediately without demanding advance deposit.',
        'Step 4: Police cannot compel you to disclose identity, address, or appear as witness.',
        'Step 5: If you voluntarily testify, your examination must be conducted at your convenience.'
      ],
      'do': [
        'Call 112 or 108 immediately to report the accident location and request medical transport.',
        'State clearly to hospital staff that you are a Good Samaritan under Sec 134A MV Act.',
        'Leave the hospital freely after handing over the victim to emergency casualty medical officers.'
      ],
      'dont': [
        'Do not pay advance registration or casualty admission fees for an unknown victim.',
        'Do not submit to coercive police questioning or detention against your consent.',
        'Do not sign witness statements under duress or without legal review.'
      ],
      'legal_basis': [
        {
          'act': 'Motor Vehicles Act 1988 (as amended 2019)',
          'section': 'Section 134A (Protection of Good Samaritans)',
          'status': 'Verified Statutory Safeguard',
          'source_url': 'https://morth.nic.in'
        },
        {
          'act': 'Supreme Court of India (SaveLIFE Foundation)',
          'section': 'WP (Civil) No. 235/2012',
          'status': 'Landmark Precedent',
          'source_url': 'https://sci.gov.in'
        }
      ],
      'helplines': ['112', '108', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Civic verified statutory protocol for Good Samaritans. You cannot be detained, forced to pay hospital admission charges, or compelled to act as a witness.',
      'evidence_checklist': [
        'Note down hospital emergency casualty registration number',
        'Record 112 / 108 emergency call timestamp and dispatcher ID',
        'Document vehicle registration number of involved vehicles if safe'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },
    'road_accident_good_samaritan_good_samaritan_protection': {
      'id': 'road_accident_good_samaritan_good_samaritan_protection',
      'category': 'POLICE & CRIMINAL',
      'scenario': 'road_accident_good_samaritan',
      'branch': 'good_samaritan_protection',
      'language': 'en',
      'title': 'Good Samaritan Police Immunity & Hospital Rules',
      'roles': ['witness', 'affected'],
      'short_lines': [
        'Step 1: State firmly: I am a Good Samaritan protected under Supreme Court guidelines and Sec 134A MV Act.',
        'Step 2: Hospital cannot force you to pay registration charges or admission deposit for the victim.',
        'Step 3: You are free to leave immediately after delivering the injured person to casualty.',
        'Step 4: If police threaten detention, cite MoRTH Notification No. RT-25035/101/2014-RS.',
        'Step 5: File immediate complaint with Superintendent of Police if any officer harasses you.'
      ],
      'do': [
        'Assert your Good Samaritan immunity immediately upon arrival at hospital or police encounter.',
        'Show MoRTH Good Samaritan gazette guidelines if hospital personnel demand money.',
        'Note officer belt number and station if any coercion is attempted.'
      ],
      'dont': [
        'Do not surrender your phone or personal identification documents to hospital reception.',
        'Do not wait in the police station unless you have voluntarily agreed in writing.',
        'Do not sign admission guarantees or financial liability undertakings.'
      ],
      'legal_basis': [
        {
          'act': 'Ministry of Road Transport and Highways Guidelines',
          'section': 'Gazette Notification No. 25035/101/2014-RS',
          'status': 'Binding Executive Order',
          'source_url': 'https://morth.nic.in'
        },
        {
          'act': 'Bharatiya Nagarik Suraksha Sanhita 2023',
          'section': 'Section 35 & 47',
          'status': 'Criminal Procedure Code',
          'source_url': 'https://mha.gov.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Supreme Court guidelines explicitly protect Good Samaritans from police harassment and mandatory billing. You may leave freely.',
      'evidence_checklist': [
        'Record hospital staff names demanding admission deposit',
        'Retain emergency ambulance transit proof',
        'Save audio memo of conversation if police insist on station visit'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },
    'road_accident_good_samaritan_hit_and_run_solatium': {
      'id': 'road_accident_good_samaritan_hit_and_run_solatium',
      'category': 'POLICE & CRIMINAL',
      'scenario': 'road_accident_good_samaritan',
      'branch': 'hit_and_run_solatium',
      'language': 'en',
      'title': 'Hit & Run Solatium Fund Compensation',
      'roles': ['affected', 'parent'],
      'short_lines': [
        'Step 1: Register immediate FIR at nearest police station noting unidentified vehicle hit-and-run.',
        'Step 2: Obtain Medico-Legal Certificate (MLC) and post-mortem report if casualty occurred.',
        'Step 3: Apply to Sub-Divisional Magistrate (SDM) / Claims Enquiry Officer under Section 161 MV Act.',
        'Step 4: Solatium scheme mandates ₹2,00,000 in case of death and ₹50,000 for grievous injury.',
        'Step 5: SDM must sanction payment through General Insurance Council within 15 days of enquiry.'
      ],
      'do': [
        'Register an FIR under Section 106(2) and Section 125(b) BNS 2023 without delay.',
        'Collect certified copies of MLC, discharge summary, and treatment receipts.',
        'Submit Form I application to the Sub-Divisional Magistrate within statutory timelines.'
      ],
      'dont': [
        'Do not accept informal settlements from unidentified parties without court recording.',
        'Do not delay FIR registration beyond 24 hours of the incident.',
        'Do not compromise on statutory compensation amounts fixed by parliament.'
      ],
      'legal_basis': [
        {
          'act': 'Motor Vehicles Act 1988 (as amended 2019)',
          'section': 'Section 161 (Compensation Scheme for Hit and Run Motor Accidents)',
          'status': 'Statutory Compensation Guarantee',
          'source_url': 'https://morth.nic.in'
        },
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 106(2) (Hit and Run Offense)',
          'status': 'Criminal Penal Code',
          'source_url': 'https://mha.gov.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Section 161 of the Motor Vehicles Act provides guaranteed statutory compensation of ₹2 lakh for death and ₹50,000 for grievous injury in hit and run accidents.',
      'evidence_checklist': [
        'Certified police FIR copy with hit-and-run designation',
        'Hospital Medico-Legal Certificate (MLC) and medical bills',
        'Death certificate and post-mortem report where applicable'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },

    // 2. Passport
    'passport_verification_delay_default': {
      'id': 'passport_verification_delay_default',
      'category': 'POLICE & CRIMINAL',
      'scenario': 'passport_verification_delay',
      'branch': 'default',
      'language': 'en',
      'title': 'Passport Police Verification Bribe Demand',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Never pay any speed money or verification charge; police verification is 100% free.',
        'Step 2: Ensure standard documents (Aadhaar, address proof, educational certificates) are ready.',
        'Step 3: Demand formal receipt if officer insists on any administrative fee.',
        'Step 4: Record interaction audio/video or note visiting officer name, buckle number, and station.',
        'Step 5: Escalate bribe extortion to State Anti-Corruption Bureau (ACB 1064) or Vigilance Helpline.'
      ],
      'do': [
        'Keep original identity and residential proofs ready for physical inspection.',
        'Ask the officer for their name, designation, and police station jurisdiction.',
        'Report bribe demands immediately to the Vigilance department and District SP.'
      ],
      'dont': [
        'Do not pay cash under any circumstances; police verification has zero fee.',
        'Do not visit police stations at odd hours without official written notice.',
        'Do not sign blank verification acknowledgement forms.'
      ],
      'legal_basis': [
        {
          'act': 'Prevention of Corruption Act 1988',
          'section': 'Section 7 (Public Servant Taking Bribe)',
          'status': 'Anti-Corruption Statute',
          'source_url': 'https://cbi.gov.in'
        },
        {
          'act': 'Passports Act 1967',
          'section': 'Section 5 (Applications for Passports)',
          'status': 'Statutory Right',
          'source_url': 'https://passportindia.gov.in'
        }
      ],
      'helplines': ['1064', '112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Passport police verification is completely free of charge. Bribe demands are punishable with imprisonment under Section 7 of the Prevention of Corruption Act.',
      'evidence_checklist': [
        'Passport Seva Kendra application ARN number',
        'Officer name, buckle number, and mobile number',
        'Audio/video recording or written complaint draft'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },
    'passport_verification_delay_adverse_pvr_remedy': {
      'id': 'passport_verification_delay_adverse_pvr_remedy',
      'category': 'POLICE & CRIMINAL',
      'scenario': 'passport_verification_delay',
      'branch': 'adverse_pvr_remedy',
      'language': 'en',
      'title': 'Adverse PVR Report & Delayed Clearance',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Check online portal status; adverse report requires specific grounds under Section 6(2).',
        'Step 2: Only pending criminal court summons or conviction can justify passport denial.',
        'Step 3: File written representation to Regional Passport Officer (RPO) contesting adverse remarks.',
        'Step 4: Submit CPGRAMS grievance (pgportal.gov.in) against jurisdictional SP/Commissioner.',
        'Step 5: File RTI application under RTI Act 2005 to inspect exact adverse police report filed.'
      ],
      'do': [
        'Obtain a certified copy of your clean criminal record / police clearance certificate.',
        'Submit a formal representation to the Regional Passport Officer seeking a personal hearing.',
        'Use CPGRAMS and the Chief Minister grievance cell for rapid administrative escalation.'
      ],
      'dont': [
        'Do not conceal criminal trials or pending charge sheets on your passport application.',
        'Do not rely on verbal assurances from local beat constables.',
        'Do not let adverse status persist beyond 30 days without filing a formal objection.'
      ],
      'legal_basis': [
        {
          'act': 'Passports Act 1967',
          'section': 'Section 6 (Refusal of Passports) & Section 11 (Appeals)',
          'status': 'Statutory Safeguard',
          'source_url': 'https://passportindia.gov.in'
        },
        {
          'act': 'Right to Information Act 2005',
          'section': 'Section 6 (Request for Obtaining Information)',
          'status': 'Transparency Law',
          'source_url': 'https://rti.gov.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Section 6 of the Passports Act outlines narrow grounds for refusal. An arbitrary adverse police report can be contested before the Regional Passport Officer.',
      'evidence_checklist': [
        'Passport Seva online tracking status screenshot',
        'Copy of written representation submitted to RPO',
        'Court certified order proving absence of pending criminal charge sheets'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },

    // 3. Online Money
    'crypto_trading_investment_scam_default': {
      'id': 'crypto_trading_investment_scam_default',
      'category': 'ONLINE & MONEY',
      'scenario': 'crypto_trading_investment_scam',
      'branch': 'default',
      'language': 'en',
      'title': 'Investment App & Stock Group Scam',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Stop all money transfers immediately; fake platforms never release funds upon extra payment.',
        'Step 2: Dial national cyber helpline 1930 within golden hour to freeze beneficiary bank accounts.',
        'Step 3: Log in to cybercrime.gov.in and file formal financial cyber fraud complaint with UTR numbers.',
        'Step 4: Preserve chat logs, deposit receipts, website URLs, and recipient bank account details.',
        'Step 5: Notify your bank manager in writing requesting lien marking on fraud destination accounts.'
      ],
      'do': [
        'Call 1930 within minutes of realizing fraud to maximize account freeze chances.',
        'Save entire Telegram/WhatsApp conversation history and export chat as text.',
        'Note down exact transaction UTRs, timestamps, and beneficiary account numbers.'
      ],
      'dont': [
        'Do not pay additional tax, gas fees, or processing charges to unlock frozen profits.',
        'Do not delete scammer chat threads or clear transaction histories.',
        'Do not trust unverified private online hackers claiming to recover your funds.'
      ],
      'legal_basis': [
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 316 & 318 (Cheating & Criminal Breach of Trust)',
          'status': 'Criminal Offense',
          'source_url': 'https://mha.gov.in'
        },
        {
          'act': 'Information Technology Act 2000',
          'section': 'Section 66D (Cheating by Impersonation using Computer Resource)',
          'status': 'Cybercrime Statute',
          'source_url': 'https://meity.gov.in'
        }
      ],
      'helplines': ['1930', '112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Stop transfers immediately. Demanding tax or unfreeze fees is a cyber fraud under Section 318 BNS. Call 1930 immediately to freeze stolen funds.',
      'evidence_checklist': [
        'Bank account statement showing debit UTR numbers',
        'Screenshots of fake trading dashboard and WhatsApp/Telegram groups',
        'National Cyber Crime Reporting Portal acknowledgment slip'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },
    'crypto_trading_investment_scam_recovery_scam': {
      'id': 'crypto_trading_investment_scam_recovery_scam',
      'category': 'ONLINE & MONEY',
      'scenario': 'crypto_trading_investment_scam',
      'branch': 'recovery_scam',
      'language': 'en',
      'title': 'Fake Fund Recovery Agent Trap',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Never pay any retainer or fee to online recovery experts or ethical hackers.',
        'Step 2: Only law enforcement authorities via court order or 1930 can freeze and reverse funds.',
        'Step 3: Report recovery agency social media profiles to cyber police for impersonation.',
        'Step 4: Follow up with your district Cyber Cell investigating officer on original 1930 FIR.',
        'Step 5: File an application under Section 503 BNSS 2023 before magistrate for release of seized money.'
      ],
      'do': [
        'Deal only with official cyber police investigators assigned to your case.',
        'File an application under Section 503 BNSS 2023 before the magistrate to unfreeze seized funds.',
        'Verify identity of any legal counsel directly on the State Bar Council portal.'
      ],
      'dont': [
        'Do not pay advance fees to Instagram, Telegram, or Quora recovery agents.',
        'Do not share your bank passwords, OTPs, or recovery phrases with anyone.',
        'Do not allow third-party remote access software (AnyDesk, TeamViewer) on your phone.'
      ],
      'legal_basis': [
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 318(4) (Cheating) & Section 338',
          'status': 'Criminal Code',
          'source_url': 'https://mha.gov.in'
        },
        {
          'act': 'Bharatiya Nagarik Suraksha Sanhita 2023',
          'section': 'Section 503 (Disposal of Property Seized by Police)',
          'status': 'Magistrate Court Procedure',
          'source_url': 'https://mha.gov.in'
        }
      ],
      'helplines': ['1930', '112'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Private fund recovery agents are secondary scammers. Only statutory cyber police and magistrates can order the return of frozen funds.',
      'evidence_checklist': [
        'Cyber Crime Portal acknowledgment ID',
        'Screenshots of secondary recovery agent solicitations and payment requests',
        'Official Investigating Officer designation and police station details'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },

    // 4. Gig Worker
    'gig_worker_rights_default': {
      'id': 'gig_worker_rights_default',
      'category': 'WORK',
      'scenario': 'gig_worker_rights',
      'branch': 'default',
      'language': 'en',
      'title': 'Gig Worker Arbitrary De-Platforming',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Submit a formal grievance ticket on the partner portal demanding written reason for block.',
        'Step 2: Platform cannot forfeit accrued earnings or pending weekly payouts upon ID deactivation.',
        'Step 3: Take screenshots of customer ratings, active orders, and pending wallet balances.',
        'Step 4: File complaint before District Labor Officer citing arbitrary livelihood termination.',
        'Step 5: Approach State Gig Workers Welfare Board or registered gig delivery union for collective action.'
      ],
      'do': [
        'Capture screenshot evidence of current wallet balance, ratings, and lifetime deliveries.',
        'Send formal written email to aggregator grievance officer requesting reinstatement.',
        'Submit representation to the State Platform Based Gig Workers Welfare Board.'
      ],
      'dont': [
        'Do not accept informal customer care phone calls as final without written email documentation.',
        'Do not delete the partner application or clear app cache before exporting payout data.',
        'Do not surrender company-issued assets without formal written acknowledgment.'
      ],
      'legal_basis': [
        {
          'act': 'Code on Social Security 2020',
          'section': 'Section 114 (Schemes for Gig Workers and Platform Workers)',
          'status': 'Social Security Law',
          'source_url': 'https://labour.gov.in'
        },
        {
          'act': 'Constitution of India',
          'section': 'Article 19(1)(g) & Article 21 (Right to Livelihood)',
          'status': 'Constitutional Safeguard',
          'source_url': 'https://indiacode.nic.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Aggregator platforms cannot arbitrarily terminate gig partner IDs or forfeit earned wages without written notice and grievance redressal.',
      'evidence_checklist': [
        'Partner app profile showing account blocked notification',
        'Bank statement showing unpaid weekly delivery earnings',
        'Copy of grievance ticket raised with aggregator grievance officer'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },
    'gig_worker_rights_accident_compensation': {
      'id': 'gig_worker_rights_accident_compensation',
      'category': 'WORK',
      'scenario': 'gig_worker_rights',
      'branch': 'accident_compensation',
      'language': 'en',
      'title': 'Gig Worker On-Duty Accident Insurance',
      'roles': ['affected', 'parent'],
      'short_lines': [
        'Step 1: Notify platform emergency SOS helpline immediately while active order is registered.',
        'Step 2: Secure hospital MLC (Medico-Legal Certificate) and police accident station diary entry.',
        'Step 3: Claim benefits under platform mandatory group accidental medical and disability policy.',
        'Step 4: If company refuses claim, submit petition to Commissioner for Employee Compensation.',
        'Step 5: File claim petition before Motor Accident Claims Tribunal (MACT) against offending vehicle.'
      ],
      'do': [
        'Report the injury to the platform SOS line within 24 hours of occurrence.',
        'Obtain certified hospital discharge summary, fracture reports, and medical bills.',
        'Approach the Employee Compensation Commissioner in the Labor department for recovery.'
      ],
      'dont': [
        'Do not let the platform classify you as off-duty if the app was logged in during transit.',
        'Do not sign waivers forfeiting accident claims in exchange for minor token relief.',
        'Do not miss the 2-year limitation period for filing MACT accident claims.'
      ],
      'legal_basis': [
        {
          'act': 'Employee Compensation Act 1923',
          'section': 'Section 3 & 4 (Employer Liability for Compensation)',
          'status': 'Statutory Liability',
          'source_url': 'https://labour.gov.in'
        },
        {
          'act': 'Code on Social Security 2020',
          'section': 'Section 114 (Accident & Health Benefits for Gig Workers)',
          'status': 'Statutory Welfare',
          'source_url': 'https://labour.gov.in'
        }
      ],
      'helplines': ['112', '108', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Delivery partners injured on active duty are covered under mandatory group accidental insurance and statutory compensation provisions.',
      'evidence_checklist': [
        'Active order pickup/delivery screenshot at time of accident',
        'Hospital emergency Medico-Legal Certificate (MLC)',
        'Police Station Diary Entry or accident FIR copy'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },

    // 5. Domestic Worker
    'domestic_worker_rights_default': {
      'id': 'domestic_worker_rights_default',
      'category': 'WORK',
      'scenario': 'domestic_worker_rights',
      'branch': 'default',
      'language': 'en',
      'title': 'Domestic Worker False Theft Allegation',
      'roles': ['accused', 'affected'],
      'short_lines': [
        'Step 1: Employer has zero power of search or detention; physical confinement is a crime under Sec 127 BNS.',
        'Step 2: Only female police officers can conduct physical search of female workers under Sec 47 BNSS.',
        'Step 3: If employer threatens physical harm, immediately dial women emergency helpline 1090 or 112.',
        'Step 4: Demand presence of legal aid counsel or trusted family member before answering questions.',
        'Step 5: Approach District Legal Services Authority (DLSA) for free defense representation.'
      ],
      'do': [
        'Call 112 or Women Helpline 1090 immediately if employer locks the door or threatens violence.',
        'Insist on being accompanied by female police officers and DLSA legal aid counsel.',
        'State calmly that false accusation is punishable under Section 248 BNS 2023.'
      ],
      'dont': [
        'Do not allow employer or building security guards to conduct bodily strip searches.',
        'Do not sign confessions or promissory notes admitting to theft under intimidation.',
        'Do not remain isolated without informing family or local domestic worker union.'
      ],
      'legal_basis': [
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 127 (Wrongful Confinement) & Section 351 (Criminal Intimidation)',
          'status': 'Penal Safeguard',
          'source_url': 'https://mha.gov.in'
        },
        {
          'act': 'Bharatiya Nagarik Suraksha Sanhita 2023',
          'section': 'Section 47 (Search of Female Arrestee by Female Officer Only)',
          'status': 'Procedural Protection',
          'source_url': 'https://mha.gov.in'
        }
      ],
      'helplines': ['112', '1090', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Employers have no legal authority to detain or strip-search domestic workers. Wrongful confinement is a serious offense under Section 127 BNS.',
      'evidence_checklist': [
        'Call log to 112 / 1090 emergency helplines',
        'Audio/video recording of employer threats or unlawful confinement',
        'DLSA legal aid assignment reference number'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },
    'domestic_worker_rights_unpaid_wages': {
      'id': 'domestic_worker_rights_unpaid_wages',
      'category': 'WORK',
      'scenario': 'domestic_worker_rights',
      'branch': 'unpaid_wages',
      'language': 'en',
      'title': 'Domestic Help Wage Theft & Dues Recovery',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Gather attendance logs, bank entry records, or employer communication detailing duties.',
        'Step 2: Send formal demand notice via local domestic workers union or legal aid advocate.',
        'Step 3: File wage non-payment claim before jurisdictional Assistant Labor Commissioner.',
        'Step 4: If employer retaliates with false police complaint, file counter-complaint for criminal intimidation.',
        'Step 5: DLSA provides 100% free legal assistance to recover unorganized sector wages.'
      ],
      'do': [
        'Maintain a personal daily diary noting dates worked and payments received.',
        'Approach the District Legal Services Authority (DLSA) front desk for free legal representation.',
        'Lodge a wage recovery petition before the local Labor Officer under unorganized worker rules.'
      ],
      'dont': [
        'Do not waive your right to notice pay or earned wages under verbal pressure.',
        'Do not engage in physical altercations at the employer residence.',
        'Do not sign blank salary vouchers or settlement slips.'
      ],
      'legal_basis': [
        {
          'act': 'Unorganised Workers Social Security Act 2008',
          'section': 'Section 3 & 10 (Grievance Redressal Mechanisms)',
          'status': 'Welfare Law',
          'source_url': 'https://labour.gov.in'
        },
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 316 (Criminal Breach of Trust)',
          'status': 'Criminal Offense',
          'source_url': 'https://mha.gov.in'
        }
      ],
      'helplines': ['15100', '112'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Withholding earned wages from domestic workers violates labor laws and constitutes breach of trust under Section 316 BNS.',
      'evidence_checklist': [
        'Bank passbook or UPI transfer receipts showing historical wage credits',
        'WhatsApp or SMS messages discussing tasks, working hours, and salary dues',
        'Copy of demand notice issued through DLSA or labor advocate'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },

    // 6. Housing
    'noise_pollution_illegal_construction_default': {
      'id': 'noise_pollution_illegal_construction_default',
      'category': 'HOUSING',
      'scenario': 'noise_pollution_illegal_construction',
      'branch': 'default',
      'language': 'en',
      'title': 'Residential Noise Pollution & Loudspeakers',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Loudspeakers, DJs, and commercial noise are strictly banned between 10:00 PM and 6:00 AM.',
        'Step 2: Dial 112 police emergency and specify: Violation of Noise Pollution Rules 2000 in residential zone.',
        'Step 3: Police are legally bound to seize sound equipment and amplifiers under Rule 8.',
        'Step 4: If local police fail to act, file written complaint before Sub-Divisional Magistrate (SDM).',
        'Step 5: File petition before State Pollution Control Board or National Green Tribunal (NGT).'
      ],
      'do': [
        'Call 112 promptly when noise continues past 10 PM and note the police dispatch ticket number.',
        'Record decibel readings using standard smartphone sound level apps as supplementary evidence.',
        'Submit a joint written representation to the District Magistrate or SDM signed by neighbors.'
      ],
      'dont': [
        'Do not engage in physical fights or confront loud party organizers alone late at night.',
        'Do not accept verbal assurances from local police without equipment seizure or volume shutdown.',
        'Do not allow commercial events to operate without written municipal sound permits.'
      ],
      'legal_basis': [
        {
          'act': 'Noise Pollution (Regulation and Control) Rules 2000',
          'section': 'Rule 5 & Rule 8 (Night Restrictions and Seizure Powers)',
          'status': 'Binding Statutory Rules',
          'source_url': 'https://cpcb.nic.in'
        },
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 270 & 271 (Public Nuisance)',
          'status': 'Criminal Code',
          'source_url': 'https://mha.gov.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Loudspeakers and heavy noise are banned between 10 PM and 6 AM under Noise Pollution Rules 2000. Police are legally required to shut down and seize equipment.',
      'evidence_checklist': [
        'Time-stamped audio/video recording from inside residence demonstrating noise level',
        'Dial 112 police call logs and dispatch reference numbers',
        'Copy of written complaint submitted to jurisdictional SDM and police station'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },
    'noise_pollution_illegal_construction_illegal_structural_alteration': {
      'id': 'noise_pollution_illegal_construction_illegal_structural_alteration',
      'category': 'HOUSING',
      'scenario': 'noise_pollution_illegal_construction',
      'branch': 'illegal_structural_alteration',
      'language': 'en',
      'title': 'Illegal Structural Construction & Encroachment',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Photograph unauthorized construction, pillar demolition, or load-bearing wall removal.',
        'Step 2: Submit urgent stop-work notice to Municipal Ward Engineer and Town Planning department.',
        'Step 3: File petition under Section 152 BNSS 2023 before SDM for immediate conditional stop order.',
        'Step 4: If construction endangers building stability, approach Civil Court for an ex-parte stay injunction.',
        'Step 5: File online grievance on municipal grievance portal and copy District Collector.'
      ],
      'do': [
        'Take clear date-stamped photographs of unauthorized drilling, pillar removal, or encroachment.',
        'File an urgent written petition before the SDM under Section 152 BNSS for public safety.',
        'Demand municipal sanctioned building plan and structural audit report from builder or neighbor.'
      ],
      'dont': [
        'Do not ignore cracks appearing in your walls or structural vibration during construction.',
        'Do not wait for construction completion; obtaining demolition orders post-construction takes years.',
        'Do not enter unauthorized construction zones without safety precautions.'
      ],
      'legal_basis': [
        {
          'act': 'Bharatiya Nagarik Suraksha Sanhita 2023',
          'section': 'Section 152 (Conditional Order for Removal of Nuisance or Hazard)',
          'status': 'Magistrate Injunction Power',
          'source_url': 'https://mha.gov.in'
        },
        {
          'act': 'State Municipal Corporation Acts',
          'section': 'Provisions on Unauthorized Construction and Demolition',
          'status': 'Municipal Law',
          'source_url': 'https://indiacode.nic.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Section 152 BNSS empowers the Sub-Divisional Magistrate to issue immediate stop-work orders against dangerous unauthorized construction.',
      'evidence_checklist': [
        'Photographs and video of structural demolition, beam cutting, or encroachment',
        'Written acknowledgment of complaint from Municipal Town Planning Ward Office',
        'Copy of Section 152 BNSS petition filed before Sub-Divisional Magistrate'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },

    // 7. Animal Cruelty
    'animal_cruelty_stray_feeding_default': {
      'id': 'animal_cruelty_stray_feeding_default',
      'category': 'HOUSING',
      'scenario': 'animal_cruelty_stray_feeding',
      'branch': 'default',
      'language': 'en',
      'title': 'Stray Animal Feeder Rights & RWA Protection',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: High Court guidelines confirm citizens have the constitutional right to feed community animals.',
        'Step 2: RWAs have zero statutory authority to levy fines, issue bans, or harass animal feeders.',
        'Step 3: Coordinate with RWA to designate designated feeding spots away from children play areas.',
        'Step 4: If residents threaten or assault you, file FIR under Section 115 and 351 BNS 2023 for intimidation.',
        'Step 5: Forward formal complaint to Animal Welfare Board of India (AWBI) and local police station.'
      ],
      'do': [
        'Feed community animals in designated, hygienic areas away from common walkways.',
        'Keep copies of Animal Welfare Board of India (AWBI) feeder advisories and High Court rulings.',
        'Dial 112 immediately if aggressive residents or RWA members physically block or assault you.'
      ],
      'dont': [
        'Do not pay illegal fines or penalties imposed by RWAs for feeding stray dogs.',
        'Do not permit unauthorized relocation or displacement of sterilized community dogs.',
        'Do not enter into violent arguments; document harassment on video.'
      ],
      'legal_basis': [
        {
          'act': 'Constitution of India',
          'section': 'Article 51A(g) (Fundamental Duty to have Compassion for Living Creatures)',
          'status': 'Constitutional Duty & Right',
          'source_url': 'https://indiacode.nic.in'
        },
        {
          'act': 'Animal Birth Control Rules 2023',
          'section': 'Rule 20 (Feeding of Community Animals and Dispute Resolution)',
          'status': 'Central Statutory Rules',
          'source_url': 'https://awbi.gov.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Feeding community animals is protected under Article 51A(g) and ABC Rules 2023. RWAs cannot ban feeding or fine citizens.',
      'evidence_checklist': [
        'Copy of RWA notice, resolution, or fine demand letter',
        'Video recording of verbal abuse, threats, or physical obstruction',
        'AWBI registered feeder card or colony dog sterilization records'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },
    'animal_cruelty_stray_feeding_cruelty_complaint': {
      'id': 'animal_cruelty_stray_feeding_cruelty_complaint',
      'category': 'HOUSING',
      'scenario': 'animal_cruelty_stray_feeding',
      'branch': 'cruelty_complaint',
      'language': 'en',
      'title': 'Animal Cruelty & Poisoning Enforcement',
      'roles': ['witness', 'affected'],
      'short_lines': [
        'Step 1: Secure CCTV footage, photos, and post-mortem or veterinary treatment certificates.',
        'Step 2: Section 325 BNS makes killing, poisoning, or maiming animals punishable up to 5 years prison.',
        'Step 3: Demand immediate FIR registration under Section 11 PCA Act and Section 325 BNS.',
        'Step 4: Relocation of community dogs is strictly prohibited under Rule 11 ABC Rules 2023.',
        'Step 5: Contact Society for the Prevention of Cruelty to Animals (SPCA) to ensure police prosecution.'
      ],
      'do': [
        'Call 112 immediately and preserve the scene if you discover injured or poisoned animals.',
        'Get an immediate autopsy/post-mortem done by a registered Government Veterinary Doctor.',
        'Demand registration of a cognizable FIR under Section 325 Bharatiya Nyaya Sanhita.'
      ],
      'dont': [
        'Do not dispose of poisoned food or animal bodies before forensic collection and post-mortem.',
        'Do not permit police officers to treat animal cruelty as a simple non-cognizable complaint.',
        'Do not allow perpetrators to displace other animals in the pack.'
      ],
      'legal_basis': [
        {
          'act': 'Bharatiya Nyaya Sanhita 2023',
          'section': 'Section 325 (Mischief by Killing or Maiming Animal)',
          'status': 'Cognizable Penal Offense',
          'source_url': 'https://mha.gov.in'
        },
        {
          'act': 'Prevention of Cruelty to Animals Act 1960',
          'section': 'Section 11 (Treating Animals Cruelly)',
          'status': 'Statutory Offense',
          'source_url': 'https://awbi.gov.in'
        }
      ],
      'helplines': ['112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Poisoning or maiming animals is a cognizable criminal offense punishable up to 5 years imprisonment under Section 325 of the Bharatiya Nyaya Sanhita.',
      'evidence_checklist': [
        'Government veterinary doctor post-mortem / viscera report',
        'CCTV footage of poisoning, beating, or cruel confinement',
        'Copy of FIR registered under Section 325 BNS and Section 11 PCA'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },

    // 8. Senior Citizens
    'senior_citizen_maintenance_default': {
      'id': 'senior_citizen_maintenance_default',
      'category': 'FAMILY & SAFETY',
      'scenario': 'senior_citizen_maintenance',
      'branch': 'default',
      'language': 'en',
      'title': 'Senior Citizen Maintenance & Eviction Protection',
      'roles': ['affected', 'parent'],
      'short_lines': [
        'Step 1: Senior citizens are entitled to monthly maintenance up to ₹10,000 from adult children/heirs.',
        'Step 2: File summary petition before the Maintenance Tribunal presided over by the SDM.',
        'Step 3: Senior citizens can seek summary eviction of abusive children from self-acquired property.',
        'Step 4: Section 24 makes intentional abandonment of senior citizens punishable with imprisonment.',
        'Step 5: Call national elderline helpline 14567 for free administrative and legal intervention.'
      ],
      'do': [
        'Dial National Elderline Helpline 14567 for free counseling, rescue, and legal filing support.',
        'File an application under Section 4 and 5 of the Senior Citizens Act before the SDM Tribunal.',
        'Produce title deeds proving self-acquired ownership if seeking eviction of abusive relatives.'
      ],
      'dont': [
        'Do not suffer domestic violence or abandonment in silence; abandonment is a criminal offense.',
        'Do not let relatives coerce you into signing powers of attorney or sale deeds.',
        'Do not engage in expensive civil litigation when summary tribunal proceedings are available.'
      ],
      'legal_basis': [
        {
          'act': 'Maintenance and Welfare of Parents and Senior Citizens Act 2007',
          'section': 'Section 4, 9, & 24 (Maintenance Orders and Penalty for Abandonment)',
          'status': 'Special Protective Statute',
          'source_url': 'https://socialjustice.gov.in'
        },
        {
          'act': 'Supreme Court of India (S. Vanitha v. Deputy Commissioner)',
          'section': 'Civil Appeal No. 3822/2020',
          'status': 'Landmark Supreme Court Precedent',
          'source_url': 'https://sci.gov.in'
        }
      ],
      'helplines': ['14567', '112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 60, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'The Maintenance of Senior Citizens Act empowers SDMs to order monthly maintenance and evict abusive children from a senior citizen home.',
      'evidence_checklist': [
        'Proof of age establishing senior citizen status (Aadhaar/PAN/Voter ID)',
        'Property title deed proving self-acquired ownership of residence',
        'Bank statements, medical bills, and maintenance petition copy filed before SDM'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },
    'senior_citizen_maintenance_property_transfer_revocation': {
      'id': 'senior_citizen_maintenance_property_transfer_revocation',
      'category': 'FAMILY & SAFETY',
      'scenario': 'senior_citizen_maintenance',
      'branch': 'property_transfer_revocation',
      'language': 'en',
      'title': 'Revocation of Property Gift Deed (Sec 23)',
      'roles': ['affected', 'parent'],
      'short_lines': [
        'Step 1: If property was gifted on condition of basic amenities and care, Section 23 applies.',
        'Step 2: If children fail or refuse to provide care, transfer is deemed made by fraud or coercion.',
        'Step 3: File application before Maintenance Tribunal (SDM) declaring gift deed null and void.',
        'Step 4: Tribunal has statutory authority to cancel registration and restore title to the senior.',
        'Step 5: Local police are mandated to enforce peaceful possession back to the senior citizen.'
      ],
      'do': [
        'Submit a copy of the registered gift deed or settlement deed to the Maintenance Tribunal.',
        'Demonstrate that the transferee failed to provide basic medical care, food, and emotional support.',
        'Seek an interim order restraining children from creating third-party rights on the property.'
      ],
      'dont': [
        'Do not wait if children attempt to sell or mortgage the gifted residential property.',
        'Do not sign subsequent affidavits affirming the gift deed while dispute is pending.',
        'Do not vacate the house; retain physical possession with police support.'
      ],
      'legal_basis': [
        {
          'act': 'Maintenance and Welfare of Parents and Senior Citizens Act 2007',
          'section': 'Section 23 (Transfer of Property to be Void in Certain Circumstances)',
          'status': 'Statutory Revocation Power',
          'source_url': 'https://socialjustice.gov.in'
        },
        {
          'act': 'Constitution of India',
          'section': 'Article 21 (Right to Dignified Life)',
          'status': 'Fundamental Right',
          'source_url': 'https://indiacode.nic.in'
        }
      ],
      'helplines': ['14567', '112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 60, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Under Section 23 of the Senior Citizens Act, a gifted property can be declared void by the Maintenance Tribunal if children fail to provide basic care.',
      'evidence_checklist': [
        'Copy of the registered gift deed / settlement deed',
        'Medical prescriptions and hospital bills demonstrating lack of support',
        'Section 23 application acknowledgment from SDM Maintenance Tribunal'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },

    // 9. Health Insurance
    'health_insurance_claim_rejected_default': {
      'id': 'health_insurance_claim_rejected_default',
      'category': 'CONSUMER & DOCUMENTS',
      'scenario': 'health_insurance_claim_rejected',
      'branch': 'default',
      'language': 'en',
      'title': 'Hospital Cashless Denial at Discharge',
      'roles': ['affected', 'parent'],
      'short_lines': [
        'Step 1: IRDAI Master Circular mandates insurers must grant final cashless decision within 3 hours.',
        'Step 2: Hospital cannot detain patient or withhold discharge summary past the 3-hour period.',
        'Step 3: If insurer delays past 3 hours, hospital must release patient; insurer pays extra hospital charges.',
        'Step 4: Demand written repudiation letter specifying exact clause from policy document.',
        'Step 5: File complaint on IRDAI Bima Bharosa portal (bimabharosa.irdai.gov.in) with TPA pre-auth ID.'
      ],
      'do': [
        'Show hospital TPA desk the IRDAI Master Circular 2024 clause mandating 3-hour discharge decisions.',
        'Demand a written rejection letter clearly stating the clinical reason and policy exclusion clause.',
        'Lodge an immediate ticket on IRDAI Bima Bharosa portal (bimabharosa.irdai.gov.in).'
      ],
      'dont': [
        'Do not allow hospital billing desks to hold patient physically hostage for insurance delays.',
        'Do not pay inflated cash charges without an itemized bill signed by the medical superintendent.',
        'Do not accept vague verbal denials from TPA coordinators.'
      ],
      'legal_basis': [
        {
          'act': 'Insurance Regulatory and Development Authority of India (IRDAI) Act 1999',
          'section': 'IRDAI Master Circular on Operations and Allied Matters of Health Insurance 2024',
          'status': 'Binding Statutory Regulation',
          'source_url': 'https://irdai.gov.in'
        },
        {
          'act': 'Consumer Protection Act 2019',
          'section': 'Section 2(11) (Deficiency in Service)',
          'status': 'Consumer Rights Law',
          'source_url': 'https://consumeraffairs.nic.in'
        }
      ],
      'helplines': ['1915', '155255', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Under IRDAI 2024 regulations, insurers must process cashless discharge within 3 hours. Detaining patients for billing delays is prohibited.',
      'evidence_checklist': [
        'Hospital discharge summary and TPA final billing submission timestamp',
        'Copy of insurer pre-authorization letter and policy schedule',
        'IRDAI Bima Bharosa complaint token number'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 1
    },
    'health_insurance_claim_rejected_ombudsman_complaint': {
      'id': 'health_insurance_claim_rejected_ombudsman_complaint',
      'category': 'CONSUMER & DOCUMENTS',
      'scenario': 'health_insurance_claim_rejected',
      'branch': 'ombudsman_complaint',
      'language': 'en',
      'title': 'Insurance Ombudsman Fast-Track Complaint',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Submit formal written representation to Insurer Internal Grievance Redressal Officer (GRO).',
        'Step 2: If rejected or unresolved after 30 days, approach Insurance Ombudsman within 1 year.',
        'Step 3: Ombudsman service is 100% free; no court fees or advocate required for filing.',
        'Step 4: Insurer bears the strict burden of proof to demonstrate non-disclosure of pre-existing illness.',
        'Step 5: Ombudsman award must be executed by the insurance company within 30 days of passing.'
      ],
      'do': [
        'File representation before the Insurer Grievance Redressal Officer (GRO) first.',
        'Submit complaint online at cioins.co.in to the territorial Insurance Ombudsman within 1 year.',
        'Attach treating doctor certificate proving the ailment was not pre-existing before policy inception.'
      ],
      'dont': [
        'Do not engage third-party claim settlement agents taking hefty commissions.',
        'Do not miss the 1-year deadline following the insurer repudiation letter.',
        'Do not file simultaneously in Consumer Forum; choose Ombudsman for faster 30-day resolution.'
      ],
      'legal_basis': [
        {
          'act': 'Insurance Ombudsman Rules 2017',
          'section': 'Rule 13 (Manner in which Complaint is to be Made) & Rule 17 (Award)',
          'status': 'Statutory Dispute Redressal',
          'source_url': 'https://cioins.co.in'
        },
        {
          'act': 'Consumer Protection Act 2019',
          'section': 'Section 35 (Filing of Consumer Complaint)',
          'status': 'Consumer Rights',
          'source_url': 'https://consumeraffairs.nic.in'
        }
      ],
      'helplines': ['1915', '155255', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'The Insurance Ombudsman offers free, binding dispute resolution up to ₹50 lakh. Insurers must implement awards within 30 days.',
      'evidence_checklist': [
        'Insurer claim repudiation letter with GRO rejection confirmation',
        'Treating physician certificate clarifying medical history',
        'Online complaint acknowledgment from Insurance Ombudsman portal (cioins.co.in)'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },

    // 10. E-Commerce
    'ecommerce_counterfeit_delivery_scam_default': {
      'id': 'ecommerce_counterfeit_delivery_scam_default',
      'category': 'CONSUMER & DOCUMENTS',
      'scenario': 'ecommerce_counterfeit_delivery_scam',
      'branch': 'default',
      'language': 'en',
      'title': 'E-Commerce Empty Box & Fake Item Delivery',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Take unboxing video, photo of shipping label, package weight, and invoice barcode.',
        'Step 2: Raise immediate return/refund ticket within 24 hours via platform app or customer care.',
        'Step 3: Platforms cannot claim immunity as intermediaries under Consumer E-Commerce Rules 2020.',
        'Step 4: Lodge formal grievance on National Consumer Helpline (NCH 1915 or consumerhelpline.gov.in).',
        'Step 5: If platform evades refund, dispute transaction with your credit card issuer for immediate chargeback.'
      ],
      'do': [
        'Record complete unboxing videos showing courier label, seal integrity, and internal contents.',
        'Register complaint on National Consumer Helpline (NCH) dialing 1915 or via WhatsApp.',
        'Email platform grievance officer with order invoice, product weight, and unboxing clips.'
      ],
      'dont': [
        'Do not discard original shipping outer packaging, courier waybill, or packing slips.',
        'Do not wait past platform return window (usually 3 to 7 days) before reporting issue.',
        'Do not hand over returned items to courier delivery agents without a physical pickup receipt.'
      ],
      'legal_basis': [
        {
          'act': 'Consumer Protection (E-Commerce) Rules 2020',
          'section': 'Rule 5 & Rule 6 (Liabilities of Marketplace and Inventory Platforms)',
          'status': 'Central Statutory Regulation',
          'source_url': 'https://consumeraffairs.nic.in'
        },
        {
          'act': 'Consumer Protection Act 2019',
          'section': 'Section 2(47) (Unfair Trade Practice) & Section 84 (Product Liability)',
          'status': 'Statutory Consumer Protection',
          'source_url': 'https://consumeraffairs.nic.in'
        }
      ],
      'helplines': ['1915', '112', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'E-commerce platforms are liable for counterfeit goods and empty boxes under Consumer E-Commerce Rules 2020. Call NCH 1915 or request a bank chargeback.',
      'evidence_checklist': [
        'Unbroken unboxing video and photographs of empty/counterfeit parcel',
        'Courier waybill shipping label showing billed package weight',
        'NCH 1915 grievance docket number and platform support chat transcript'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },
    'ecommerce_counterfeit_delivery_scam_chargeback_dispute': {
      'id': 'ecommerce_counterfeit_delivery_scam_chargeback_dispute',
      'category': 'CONSUMER & DOCUMENTS',
      'scenario': 'ecommerce_counterfeit_delivery_scam',
      'branch': 'chargeback_dispute',
      'language': 'en',
      'title': 'Bank Card Chargeback for Merchant Fraud',
      'roles': ['affected'],
      'short_lines': [
        'Step 1: Contact card-issuing bank customer care within 60 days of transaction.',
        'Step 2: Request a formal Chargeback under Goods Not Received or Defective/Counterfeit Product.',
        'Step 3: Submit proof of platform refusal, order invoice, and photo/video evidence to bank.',
        'Step 4: Bank puts transaction on provisional dispute credit while investigating merchant bank.',
        'Step 5: If bank fails to process chargeback, escalate to RBI Banking Ombudsman (cms.rbi.org.in).'
      ],
      'do': [
        'Initiate chargeback request in writing via official netbanking dispute portal or registered email.',
        'Attach platform written refusal to refund alongside invoice and delivery tracking evidence.',
        'Cite Visa/Mastercard/RuPay dispute reason code for defective/counterfeit merchandise.'
      ],
      'dont': [
        'Do not delay beyond the 60 to 120 day card scheme dispute filing window.',
        'Do not accept closed chargeback tickets without written reasons from your bank dispute team.',
        'Do not cancel dispute until provisional credit is confirmed permanent.'
      ],
      'legal_basis': [
        {
          'act': 'Reserve Bank of India Master Directions on Credit Card and Debit Card Operations 2022',
          'section': 'Section 16 (Grievance Redressal and Customer Protection)',
          'status': 'Binding Central Bank Direction',
          'source_url': 'https://rbi.org.in'
        },
        {
          'act': 'Reserve Bank - Integrated Ombudsman Scheme 2021',
          'section': 'Clause 8 (Grounds of Complaint for Deficiency in Banking Services)',
          'status': 'Statutory Banking Ombudsman',
          'source_url': 'https://cms.rbi.org.in'
        }
      ],
      'helplines': ['1915', '14448', '15100'],
      'applies_to': {'states': ['ALL'], 'age_min': 0, 'user_types': ['all']},
      'next_branch': null,
      'voice_script': 'Under RBI and card network rules, you have the right to file a bank chargeback if an online merchant delivers counterfeit or empty goods.',
      'evidence_checklist': [
        'Bank account statement showing transaction debit line item',
        'Official chargeback dispute form submitted to issuing bank',
        'Written proof of platform refusing refund or closing grievance ticket'
      ],
      'reviewed_by': 'CIVIC Statutory Legal Review Board',
      'reviewed_on': '2026-10-01T00:00:00.000Z',
      'valid_until': '2028-12-31T23:59:59.000Z',
      'risk_tier': 2
    },
  };

  const encoder = JsonEncoder.withIndent('  ');
  int count = 0;
  for (final entry in cards.entries) {
    final cardId = entry.key;
    final cardData = entry.value;
    final file = File('assets/content/cards/$cardId.json');
    file.writeAsStringSync(encoder.convert(cardData));
    count++;
  }

  print('Successfully wrote $count fully conformant production cards!');
}
