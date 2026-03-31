import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
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
            children: const [
              _EarnCard(value: '₹84K', label: 'Total Earned'),
              _EarnCard(value: '₹12.4K', label: 'Withdrawable'),
              _EarnCard(value: '₹6K', label: 'Pending'),
              _EarnCard(value: '₹8.4K', label: 'Commission'),
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
          _PaymentCard(
            title: 'TechCorp Brand Shoot',
            meta: '₹15,000 · Commission: ₹1,500',
            date: 'Feb 28',
          ),
          _PaymentCard(
            title: 'Pre-Wedding Shoot',
            meta: '₹22,000 · Commission: ₹2,200',
            date: 'Feb 10',
          ),
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
                onPressed: () {},
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
                    color: AppColors.black,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
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
              date,
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
