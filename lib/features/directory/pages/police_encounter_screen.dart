import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class PoliceEncounterScreen extends StatelessWidget {
  const PoliceEncounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Protocols',
      badgeText: 'FIELD PROTOCOL',
      title: 'Police Encounter & Traffic Stop Protocol',
      subtitle:
          'Citizen rights, officer rank mandates, and documentation limits during street checkpoints and vehicle stops.',
      children: [
        DirectoryCard(
          title: 'Traffic Officer Rank & Compounding Authority',
          statute: 'Motor Vehicles Act 1988 · Rule 139 CMVR',
          icon: Icons.traffic_rounded,
          body:
              'Only a police officer of the rank of Sub-Inspector (SI - 2 stars) or above, or an authorized RTO officer, has legal compounding authority to issue on-spot cash challans. Constables or Head Constables (stripes only) cannot issue compoundable traffic fines without a Sub-Inspector present.',
        ),
        DirectoryCard(
          title: 'Ignition Key Confiscation & Vehicle Seizure Limits',
          statute: 'Section 130 & 206 · Motor Vehicles Act',
          icon: Icons.vpn_key_off_outlined,
          body:
              'Traffic personnel cannot snatch vehicle ignition keys from a running or stationary vehicle or deflate tires. Under Section 206 MVA, an officer can impound a vehicle only in narrow statutory situations (driving without registration, driving under intoxication, or dangerous driving causing acute danger).',
        ),
        DirectoryCard(
          title: 'Digital Documents via DigiLocker / mParivahan',
          statute: 'Ministry of Road Transport (MoRTH) Advisory RT-11036/64/2017',
          icon: Icons.mobile_friendly_rounded,
          body:
              'Presenting digital driving licenses, registration certificates (RC), and insurance through the official DigiLocker or mParivahan apps is statutorily equivalent to presenting physical laminated cards under Rule 139 of the Central Motor Vehicles Rules (CMVR). Physical card confiscation is invalid when digital proof is verified.',
        ),
        DirectoryCard(
          title: 'Officer Identification & Name Badge Mandate',
          statute: 'D.K. Basu Guideline 1 · Police Standing Orders',
          icon: Icons.badge_outlined,
          body:
              'Every police officer conducting an inquiry or stop must display visible, legible identification with their name and designation badge. You are legally entitled to politely ask for the officer badge number and police station attachment.',
        ),
      ],
    );
  }
}
