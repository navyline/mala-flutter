import 'dart:math';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// [MemberCard] displays digital membership information including points and QR code.
///
/// It features a two-tone design:
/// 1. An upper section with a brand-colored background and loyalty data.
/// 2. A lower section containing a dynamically generated QR code for member identification.
class MemberCard extends StatelessWidget {
  final String name;
  final int points;
  final String phone;
  final String numberCode;
  final DateTime createdAt;
  final VoidCallback onHistoryTap;

  const MemberCard({
    super.key,
    required this.name,
    required this.points,
    required this.phone,
    required this.numberCode,
    required this.createdAt,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    // 🎨 Data Transformation: Format Date to "DD Mmm YY" (Thai Locale)
    const monthNames = [
      "ม.ค.",
      "ก.พ.",
      "มี.ค.",
      "เม.ย.",
      "พ.ค.",
      "มิ.ย.",
      "ก.ค.",
      "ส.ค.",
      "ก.ย.",
      "ต.ค.",
      "พ.ย.",
      "ธ.ค.",
    ];
    final dateStr =
        "${createdAt.day.toString().padLeft(2, '0')} ${monthNames[createdAt.month - 1]} ${createdAt.year.toString().substring(2)}";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // --- PART 1: ORANGE BRANDING & LOYALTY INFO ---
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24.0),
              topRight: Radius.circular(24.0),
            ),
            child: Container(
              color: Colors.orange.shade500,
              padding: const EdgeInsets.all(24.0),
              child: Stack(
                children: [
                  // 🎭 Aesthetic Background: Rotating Flame Watermark
                  Positioned(
                    right: -40,
                    bottom: -40,
                    child: Transform.rotate(
                      angle: 12 * pi / 180,
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        size: 180,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),

                  // 📝 Content Layer: Member Details & Action Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'MALA MEMBER',
                                style: TextStyle(
                                  color: Colors.orange.shade100,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2.0,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          // 🕒 Action: View Transaction History
                          InkWell(
                            onTap: onHistoryTap,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                              ),
                              child: const Icon(
                                Icons.assignment_outlined,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'คะแนนสะสม',
                        style: TextStyle(
                          color: Colors.orange.shade100,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            points.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -2.0,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'POINTS',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // --- PART 2: IDENTIFICATION (QR CODE) ---
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(24.0),
                bottomRight: Radius.circular(24.0),
              ),
              border: Border(
                top: BorderSide(color: Colors.grey.shade100, width: 2),
              ),
            ),
            child: Column(
              children: [
                // 🔍 Unique Member QR Code Generator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade50),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: QrImageView(
                    data: numberCode,
                    version: QrVersions.auto,
                    size: 140.0,
                  ),
                ),
                const SizedBox(height: 16),

                // Monospaced Member ID for improved readability during manual entry
                Text(
                  numberCode,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4.0,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),

                // 📞 Contact & Metadata Information
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.phone, size: 12, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      phone,
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.calendar_today,
                      size: 12,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'วันที่สมัคร: $dateStr',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
