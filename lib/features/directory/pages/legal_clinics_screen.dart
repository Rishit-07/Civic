import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/directory_detail_scaffold.dart';

class LegalClinicsScreen extends StatelessWidget {
  const LegalClinicsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DirectoryDetailScaffold(
      category: 'Initiative',
      badgeText: 'NALSA & SLSA DIRECTORY',
      title: 'Free Legal Aid Clinics & NALSA Centers',
      subtitle:
          'Statutory pro-bono legal counsel clinics operated under the Legal Services Authorities Act, 1987.',
      children: [
        const DirectoryCard(
          title: 'Who is Eligible for 100% Free Legal Aid?',
          statute: 'Section 12 · Legal Services Authorities Act, 1987',
          icon: Icons.verified_user_outlined,
          body:
              'Under Indian law, the following citizens are statutorily entitled to free legal counsel at state expense regardless of means:\n• All Women and Children\n• Members of Scheduled Castes (SC) and Scheduled Tribes (ST)\n• Persons in Police Custody or Custodial Detention\n• Industrial Workmen\n• Victims of Human Trafficking, Beggar Homes, or Mass Disasters\n• Persons with annual income under the state threshold (typically ₹3,00,000).',
        ),
        DirectoryCard(
          title: 'National Legal Services Authority (NALSA)',
          statute: 'Helpline: 15100 (Toll-Free 24/7)',
          icon: Icons.support_agent_rounded,
          accentColor: const Color(0xFF15803D),
          body:
              'Central statutory body managing free legal representation in the Supreme Court, High Courts, and Subordinate Courts.\nOffice: 12/11, Jam Nagar House, Shahjahan Road, New Delhi 110011.\nWeb: nalsa.gov.in',
          actions: [
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '15100'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('NALSA Helpline 15100 copied to clipboard'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.phone_in_talk, size: 16),
              label: const Text('COPY 15100'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        const DirectoryCard(
          title: 'District Legal Services Authorities (DLSA)',
          statute: 'Located inside every District Court Complex across India',
          icon: Icons.location_city_rounded,
          body:
              'Every district in India has a permanent Front Office Legal Aid Clinic within the District Court premises. Operating hours: Monday through Saturday 10:00 AM to 5:00 PM. Duty advocates are appointed immediately for bail applications, remands, and defense filing without application fees.',
        ),
        const DirectoryCard(
          title: 'How to Request a Free Legal Aid Advocate',
          statute: 'Regulation 7 · NALSA (Free and Competent Legal Services) Regulations',
          icon: Icons.assignment_outlined,
          body:
              '1. Visit the nearest District Court DLSA Front Office or call 15100.\n2. Submit a simple declaration form stating your case details and eligibility.\n3. The Secretary DLSA will assign an empaneled defense advocate within 24 to 48 hours.\n4. All advocate honorarium and court fees are settled directly by the State Legal Services Authority.',
        ),
      ],
    );
  }
}
