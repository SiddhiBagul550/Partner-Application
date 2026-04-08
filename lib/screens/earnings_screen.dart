import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/event_model.dart';
import '../models/vendor_model.dart';
import '../services/event_service.dart';
import '../services/vendor_service.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vendorEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: StreamBuilder<VendorModel?>(
        stream: VendorService().currentVendorStream(),
        builder: (context, vendorSnap) {
          final vendorWallet = vendorSnap.data?.wallet ?? 0.0;

          return StreamBuilder<List<EventModel>>(
            stream: EventService().vendorEventsStream(vendorEmail),
            builder: (context, eventSnap) {
              if (eventSnap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: AppColors.gold));
              }

              final events = eventSnap.data ?? [];
              
              double totalEarned = 0;
              double pending = 0;
              final completedEvents = <EventModel>[];

              for (final e in events) {
                // Earning calculation takes into account budget split among assigned vendors
                final vendorCount = e.committedVendors.isEmpty ? 1 : e.committedVendors.length;
                final singlePayout = e.budget / vendorCount;

                if (e.status == EventStatus.completed) {
                  totalEarned += singlePayout;
                  completedEvents.add(e);
                } else {
                  pending += singlePayout;
                }
              }

              final commission = totalEarned * 0.15; // Assuming 15% platform commission
              
              String formatAmt(double amt) {
                if (amt >= 1000) return '₹${(amt / 1000).toStringAsFixed(1)}K';
                return '₹${amt.toStringAsFixed(0)}';
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'EARNINGS OVERVIEW',
                    style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.gold,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 14),
                  // Stats grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.7,
                    children: [
                      _EarnCard(value: formatAmt(totalEarned), label: 'Total Earned'),
                      _EarnCard(value: formatAmt(vendorWallet), label: 'Withdrawable'),
                      _EarnCard(value: formatAmt(pending), label: 'Pending'),
                      _EarnCard(value: formatAmt(commission), label: 'Comm. Dedicated'),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Divider(color: AppColors.goldBorder.withOpacity(0.4)),
                  const SizedBox(height: 14),
                  Text(
                    'RECENT PAYMENTS',
                    style: GoogleFonts.dmSans(
                        fontSize: 10,
                        color: AppColors.gold,
                        letterSpacing: 2,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  
                  if (completedEvents.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No completed event payments yet.',
                          style: GoogleFonts.dmSans(color: AppColors.whiteDim),
                        ),
                      ),
                    )
                  else
                    ...completedEvents.map((e) {
                      final vendorCount = e.committedVendors.isEmpty ? 1 : e.committedVendors.length;
                      final singlePayout = e.budget / vendorCount;
                      final payoutComm = singlePayout * 0.15;

                      return _PaymentCard(
                        title: e.name,
                        meta: '₹${singlePayout.toStringAsFixed(0)} · Commission: ₹${payoutComm.toStringAsFixed(0)}',
                        date: e.formattedDate,
                      );
                    }),

                  const SizedBox(height: 16),
                  // Withdraw button
                  SizedBox(
                    width: double.infinity,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextButton(
                        onPressed: vendorWallet > 0 ? () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Withdrawal request active.', style: GoogleFonts.dmSans(color: AppColors.black)),
                                backgroundColor: AppColors.gold,
                              ),
                            );
                        } : null,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          '💳  REQUEST WITHDRAWAL',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: vendorWallet > 0 ? AppColors.black : AppColors.black.withOpacity(0.5),
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }
          );
        }
      ),
    );
  }
}

class _EarnCard extends StatelessWidget {
  final String value;
  final String label;
  const _EarnCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShaderMask(
            shaderCallback: (b) => AppColors.goldGradient.createShader(b),
            child: Text(
              value,
              style: GoogleFonts.cormorantGaramond(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.whiteDim)),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  final String title;
  final String meta;
  final String date;
  const _PaymentCard(
      {required this.title, required this.meta, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white)),
                const SizedBox(height: 3),
                Text(meta,
                    style: GoogleFonts.dmSans(
                        fontSize: 11, color: AppColors.whiteDim)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.green.withOpacity(0.4)),
            ),
            child: Text(
              'PAID',
              style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.green),
            ),
          ),
        ],
      ),
    );
  }
}
