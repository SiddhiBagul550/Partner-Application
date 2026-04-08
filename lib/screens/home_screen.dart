import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../widgets/profile_strip.dart';
import '../widgets/menu_grid.dart';
import '../services/vendor_service.dart';
import '../services/event_service.dart';
import '../models/vendor_model.dart';
import '../models/event_model.dart';

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
          _RecentActivity(),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VendorModel?>(
      stream: VendorService().currentVendorStream(),
      builder: (context, snapshot) {
        final vendor = snapshot.data;
        double progress = (vendor?.projectsCompleted ?? 0) / 20.0;
        if (progress > 1.0) progress = 1.0;
        if (vendor == null) progress = 0.0;
        final pert = (progress * 100).toInt();

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
                  widthFactor: progress,
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
              '$pert%',
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: AppColors.gold,
              ),
            ),
          ],
        );
      }
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

/// Displays the vendor's last 3 committed events as Recent Activity (real-time).
class _RecentActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vendorEmail = FirebaseAuth.instance.currentUser?.email ?? '';

    return StreamBuilder<List<EventModel>>(
      stream: EventService().vendorEventsStream(vendorEmail),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: CircularProgressIndicator(color: AppColors.gold),
            ),
          );
        }

        final events = snapshot.data ?? [];
        // Show up to 3 most recent events any status
        final recent = events.take(3).toList();

        if (recent.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.black4,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.goldBorder.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                'No activity yet. Book an event to get started!',
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.whiteDim,
                ),
              ),
            ),
          );
        }

        return Column(
          children: recent.map((e) {
            final isDone = e.status == EventStatus.completed;
            final isOngoing = e.status == EventStatus.ongoing;
            final badge = isDone ? 'Paid' : (isOngoing ? 'Active' : 'Pending');
            final badgeColor = isDone
                ? AppColors.green
                : (isOngoing ? AppColors.gold : const Color(0xFFAAAAAA));

            // Category emoji
            final catStr = e.roles.map((r) => r.category.toLowerCase()).join(' ');
            final icon = catStr.contains('wedding')
                ? '💍'
                : (catStr.contains('corporate') || catStr.contains('brand'))
                    ? '🏢'
                    : catStr.contains('portrait')
                        ? '🖼️'
                        : '📸';

            return _ActivityCard(
              icon: icon,
              title: e.name,
              sub: '${e.formattedBudget} · ${e.city}',
              badge: badge,
              badgeColor: badgeColor,
            );
          }).toList(),
        );
      },
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
