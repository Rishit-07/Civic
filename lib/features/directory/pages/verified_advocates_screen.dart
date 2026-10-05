import 'package:flutter/material.dart';
import '../widgets/directory_detail_scaffold.dart';

class VerifiedAdvocatesScreen extends StatelessWidget {
  const VerifiedAdvocatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DirectoryDetailScaffold(
      category: 'Initiative',
      badgeText: 'BAR COUNCIL OF INDIA COMPLIANCE',
      title: 'Verified Advocates & Pro-Bono Counsel Directory',
      subtitle:
          'How to verify legal credentials, access court-appointed counsel, and navigate pro-bono legal defense.',
      children: [
        DirectoryCard(
          title: 'Court-Appointed Legal Defense Mandate',
          statute: 'Section 340 BNSS 2023 · Formerly Section 304 CrPC',
          icon: Icons.account_balance_outlined,
          body:
              'In any criminal trial before a Sessions Court or Judicial Magistrate where the accused is unrepresented and lacks sufficient means, the presiding Magistrate or Judge is legally obligated to assign defense counsel at the expense of the State. A trial conducted without offering legal representation is legally void.',
        ),
        DirectoryCard(
          title: 'How to Verify an Advocate Credentials',
          statute: 'Bar Council of India (BCI) Enrollment Registry',
          icon: Icons.verified_outlined,
          body:
              'Every licensed advocate in India holds a permanent State Bar Council enrollment number (e.g., D/1234/2018). You can verify an advocate by:\n1. Asking to see their official Bar Council Identity Card.\n2. Checking the State Bar Council public enrollment verification portal online.\n3. Requesting their Certificate of Practice (AIBE verification) issued by the Bar Council of India.',
        ),
        DirectoryCard(
          title: 'Department of Justice: Tele-Law Initiative',
          statute: 'Tele-Law Mobile App & Common Service Centers (CSC)',
          icon: Icons.cell_tower_rounded,
          body:
              'The Ministry of Law and Justice operates the Tele-Law scheme connecting citizens in rural and semi-urban panchayats to panel lawyers through video conference at local Common Service Centers (CSCs). Consultations are 100% free for eligible citizens.',
        ),
        DirectoryCard(
          title: 'Reporting Professional Misconduct',
          statute: 'Section 35 · Advocates Act, 1961',
          icon: Icons.report_problem_outlined,
          body:
              'If an advocate demands unauthorized fees for legal aid assignments, breaches confidentiality, or misrepresents case filings, citizens can file a formal complaint with the Disciplinary Committee of the concerned State Bar Council.',
        ),
      ],
    );
  }
}
