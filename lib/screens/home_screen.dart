import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_strip.dart';
import '../widgets/menu_grid.dart';

class HomeScreen extends StatelessWidget {
  final Function(int) onNavTap;
  const HomeScreen({super.key, required this.onNavTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ProfileStrip(),
          const SizedBox(height: 14),
          // Profile progress
          _ProgressRow(),
          const SizedBox(height: 18),
          _SectionLabel('Main Menu'),
          const SizedBox(height: 10),
          MenuGrid(onNavTap: onNavTap),
          const SizedBox(height: 20),
          _SectionLabel('Recent Activity'),
          const SizedBox(height: 10),
          _ActivityCard(
            icon: '📸',
            title: 'TechCorp Brand Shoot',
            sub: 'Payment received · ₹15,000',
            badge: 'Paid',
            badgeColor: AppColors.green,
          ),
          _ActivityCard(
            icon: '📸',
            title: 'Ananya & Vikram Wedding',
            sub: 'Delivery pending · ₹28,000',
            badge: 'Pending',
            badgeColor: AppColors.gold,
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'PROFILE',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppColors.whiteDim,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.black5,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: 0.78,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '78%',
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppColors.gold,
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: GoogleFonts.dmSans(
        fontSize: 10,
        color: AppColors.gold,
        letterSpacing: 2,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  final String icon;
  final String title;
  final String sub;
  final String badge;
  final Color badgeColor;
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.sub,
    required this.badge,
    required this.badgeColor,
  });

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
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  sub,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.whiteDim,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: badgeColor.withOpacity(0.4)),
            ),
            child: Text(
              badge,
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: badgeColor,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
