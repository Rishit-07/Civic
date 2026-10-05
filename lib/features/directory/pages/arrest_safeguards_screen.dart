import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class ArrestSafeguardsScreen extends StatelessWidget {
  const ArrestSafeguardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Protocols',
      badgeText: 'ARREST PROCEDURES',
      title: 'Arrest Safeguards & D.K. Basu Directives',
      subtitle:
          'Mandatory statutory rights of arrested persons under the BNSS 2023 and landmark Supreme Court rulings.',
      children: [
        DirectoryCard(
          title: 'Arrest Memo & Independent Witness Requirement',
          statute: 'Section 36 BNSS 2023 · D.K. Basu Guideline 2',
          icon: Icons.description_outlined,
          body:
              'At the time of arrest, the police officer MUST prepare an official Arrest Memo specifying the exact date, time, and ground of arrest. The memo must be attested by at least one independent witness (a family member or respected member of the locality) and countersigned by the arrested individual.',
        ),
        DirectoryCard(
          title: 'Right to Inform Family or a Friend',
          statute: 'Section 37 & 48 BNSS 2023 · D.K. Basu Guideline 3',
          icon: Icons.phone_forwarded_rounded,
          body:
              'The arrested person has the statutory right to have one friend, relative, or person known to them informed of their arrest and the exact police station where they are being detained, within 8 to 12 hours of arrest. The officer must record who was informed in the station General Diary.',
        ),
        DirectoryCard(
          title: 'No Arrest of Women Between Sunset & Sunrise',
          statute: 'Section 43 BNSS 2023 · Formerly Section 46(4) CrPC',
          icon: Icons.nightlight_round,
          body:
              'No woman shall be arrested after sunset and before sunrise. In exceptional circumstances involving urgent cognizable offenses, the female police officer must obtain prior written permission from a Judicial Magistrate First Class within whose jurisdiction the offense was committed or arrest is made.',
        ),
        DirectoryCard(
          title: 'Mandatory Medical Examination Every 48 Hours',
          statute: 'Section 53 BNSS 2023 · Formerly Section 54 CrPC',
          icon: Icons.medical_services_outlined,
          body:
              'The arrested person must be medically examined by a registered medical practitioner at the time of arrest, documenting all existing major or minor injuries in an inspection memo. During prolonged police custody, medical checkups must be conducted every 48 hours.',
        ),
        DirectoryCard(
          title: '24-Hour Magistrate Production Rule',
          statute: 'Article 22(2) Constitution · Section 58 BNSS 2023',
          icon: Icons.timer_outlined,
          body:
              'Every arrested person must be produced before the nearest Judicial Magistrate within 24 hours of arrest (excluding travel time). Detention in police custody beyond 24 hours without an explicit judicial remand order from a Magistrate is unlawful and constitutes wrongful confinement.',
        ),
      ],
    );
  }
}
