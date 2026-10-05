import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/directory_detail_scaffold.dart';

class EmergencyDispatchScreen extends StatelessWidget {
  const EmergencyDispatchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DirectoryDetailScaffold(
      category: 'Resources',
      badgeText: '24/7 STATUTORY DISPATCH',
      title: 'Emergency 112 & National Helplines Directory',
      subtitle:
          'Single emergency response support system, cyber fraud reporting, and legal aid hotlines across India.',
      children: [
        _buildHelplineTile(
          context,
          number: '112',
          title: 'National Emergency Response Support System (ERSS)',
          statute: 'Police · Fire · Ambulance · Disaster SOS',
          body:
              'Pan-India single toll-free number for immediate police assistance, ambulance dispatch, and fire rescue. Callers are triangulated with GPS location for immediate mobile patrol dispatch.',
          isPrimary: true,
        ),
        _buildHelplineTile(
          context,
          number: '1930',
          title: 'Citizen Financial Cyber Fraud Reporting System (CFCFRMS)',
          statute: 'Ministry of Home Affairs · Indian Cyber Crime Coordination Centre (I4C)',
          body:
              'Call immediately within the golden hour if you are defrauded through UPI, net banking, or cyber extortion. 1930 coordinates with national banking nodal officers to immediately freeze fraudulent beneficiary accounts.',
          isPrimary: false,
        ),
        _buildHelplineTile(
          context,
          number: '15100',
          title: 'NALSA Free Legal Aid Helpline (24/7)',
          statute: 'National Legal Services Authority · Statutory Legal Aid',
          body:
              '24/7 free legal assistance for citizens facing unlawful detention, domestic violence, custodial harassment, or requiring urgent remand representation.',
          isPrimary: false,
        ),
        _buildHelplineTile(
          context,
          number: '1091',
          title: 'National Women in Distress Helpline',
          statute: 'Ministry of Women and Child Development',
          body:
              'Dedicated toll-free helpline for women facing physical harassment, domestic violence, cyber stalking, or eve-teasing in public transit.',
          isPrimary: false,
        ),
        _buildHelplineTile(
          context,
          number: '1098',
          title: 'Childline India Emergency Service',
          statute: 'Children in Distress & Protection Safeguards',
          body:
              '24-hour toll-free emergency phone outreach service for children in need of care and protection against trafficking, child labor, or abandonment.',
          isPrimary: false,
        ),
        _buildHelplineTile(
          context,
          number: '14567',
          title: 'Elderline National Helpline for Senior Citizens',
          statute: 'Maintenance & Welfare of Parents and Senior Citizens Act 2007',
          body:
              'Legal assistance, abuse rescue, emotional support, and shelter facilitation for senior citizens across India.',
          isPrimary: false,
        ),
      ],
    );
  }

  static Widget _buildHelplineTile(
    BuildContext context, {
    required String number,
    required String title,
    required String statute,
    required String body,
    required bool isPrimary,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isPrimary ? const Color(0xFF17261F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPrimary ? const Color(0xFF17261F) : const Color(0xFFECEEF2),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isPrimary
                      ? const Color(0xFFFF5A00)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: isPrimary ? Colors.white : const Color(0xFF17261F),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isPrimary ? Colors.white : const Color(0xFF17261F),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      statute,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: isPrimary
                            ? const Color(0xFFFF8B4A)
                            : const Color(0xFFFF5A00),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: TextStyle(
              fontSize: 12.5,
              height: 1.55,
              color: isPrimary
                  ? const Color(0xFFD1D5DB)
                  : const Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: number));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Helpline $number copied to clipboard'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.copy_rounded, size: 14),
                label: Text('COPY $number'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPrimary
                      ? const Color(0xFFFF5A00)
                      : const Color(0xFF17261F),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
