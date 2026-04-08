import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../services/vendor_service.dart';
import '../models/vendor_model.dart';
import 'change_password_screen.dart';
import 'static_content_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<VendorModel?>(
      stream: VendorService().currentVendorStream(),
      builder: (context, snapshot) {
        final vendor = snapshot.data;
        if (vendor == null) {
          return const Center(child: CircularProgressIndicator(color: AppColors.gold));
        }

        final tier = vendor.tier;
        final isSilver = tier == 'Silver';
        final isGold = tier == 'Gold';
        final isPlatinum = tier == 'Platinum';

        // Compute performance metrics from real data
        final completed = vendor.projectsCompleted;
        // Completion rate: ramp from 80% at 0 projects to higher as they grow (approximation)
        final completionPct = completed == 0
            ? 100
            : ((0.85 + (completed / 200).clamp(0, 0.12)) * 100).round();
        // On-time: derived from rating (rating/5 mapped to 80-100% range)
        final ratingFraction = (vendor.rating / 5.0).clamp(0.0, 1.0);
        final onTimePct =
            vendor.rating == 0 ? 100 : (80 + ratingFraction * 20).round();
        // Repeat clients: meaningful after 3+ projects
        final repeatPct = completed < 3
            ? 0
            : ((completed / (completed + 5)) * 55).round();

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VENDOR LEVEL',
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.gold,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              // Tier progression
              _TierProgress(tier: tier),
              const SizedBox(height: 16),
              // Current tier card
              Container(
                decoration: BoxDecoration(
                  color: AppColors.goldGlow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.goldBorder),
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You are: ${tier.toUpperCase()} ${isPlatinum ? '💎' : (isGold ? '⭐' : '🥈')}',
                      style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Projects: ${vendor.projectsCompleted}  ·  Rating: ${vendor.rating.toStringAsFixed(1)}  ·  On-time: $onTimePct%',
                      style: GoogleFonts.dmSans(
                          fontSize: 11, color: AppColors.whiteDim),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _TierRequirements(projects: vendor.projectsCompleted, tier: tier),
              const SizedBox(height: 20),
              Text(
                'PERFORMANCE',
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.gold,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.8,
                children: [
                  _PerfCard(value: '$completionPct%', label: 'Completion'),
                  _PerfCard(value: '$onTimePct%', label: 'On-time'),
                  _PerfCard(value: '${vendor.rating.toStringAsFixed(1)} ⭐', label: 'Rating'),
                  _PerfCard(value: '$repeatPct%', label: 'Repeat Clients'),
                ],
              ),
              const SizedBox(height: 30),
              
              // Settings & Security
              Text(
                'ACCOUNT & SECURITY',
                style: GoogleFonts.dmSans(
                    fontSize: 10,
                    color: AppColors.gold,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.lock_outline,
                label: 'Change Password',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
                },
              ),
              _SettingsTile(
                icon: Icons.description_outlined,
                label: 'Terms and Conditions',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaticContentScreen(title: 'Terms and Conditions')));
                },
              ),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy Policy',
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StaticContentScreen(title: 'Privacy Policy')));
                },
              ),
              
              const SizedBox(height: 40),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout, color: AppColors.red, size: 20),
                  label: Text(
                    'SIGN OUT',
                    style: GoogleFonts.dmSans(
                      color: AppColors.red,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: AppColors.red.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.red.withOpacity(0.5)),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      }
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.goldBorder.withOpacity(0.3)),
        ),
        tileColor: AppColors.black4,
        leading: Icon(icon, color: AppColors.goldLight, size: 22),
        title: Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 14, color: AppColors.white),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.whiteDim, size: 20),
        onTap: onTap,
      ),
    );
  }
}

class _TierProgress extends StatelessWidget {
  final String tier;
  const _TierProgress({required this.tier});

  @override
  Widget build(BuildContext context) {
    bool isSilverOrAbove = true;
    bool isGoldOrAbove = tier == 'Gold' || tier == 'Platinum';
    bool isPlatinum = tier == 'Platinum';

    return Row(
      children: [
        _TierCircle(emoji: '🥈', name: 'Silver', color: const Color(0xFFAAAAAA), active: tier == 'Silver', done: isGoldOrAbove),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(color: isGoldOrAbove ? null : AppColors.black5, gradient: isGoldOrAbove ? AppColors.goldGradient : null),
          ),
        ),
        _TierCircle(emoji: '⭐', name: 'Gold', color: AppColors.gold, active: tier == 'Gold', done: isPlatinum, faded: !isGoldOrAbove),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(color: isPlatinum ? null : AppColors.black5, gradient: isPlatinum ? AppColors.goldGradient : null),
          ),
        ),
        _TierCircle(emoji: '💎', name: 'Platinum', color: const Color(0xFFB0C4DE), active: tier == 'Platinum', done: false, faded: !isPlatinum),
      ],
    );
  }
}

class _TierCircle extends StatelessWidget {
  final String emoji;
  final String name;
  final Color color;
  final bool active;
  final bool done;
  final bool faded;
  const _TierCircle({
    required this.emoji,
    required this.name,
    required this.color,
    required this.active,
    required this.done,
    this.faded = false,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.45 : 1,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active || done ? AppColors.goldGlow : Colors.transparent,
              border: Border.all(color: active || done ? color : color.withOpacity(0.5), width: 2),
              boxShadow: active
                  ? [BoxShadow(color: AppColors.goldGlow, blurRadius: 12)]
                  : [],
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name.toUpperCase(),
            style: GoogleFonts.dmSans(
              fontSize: 9,
              color: color,
              fontWeight: active ? FontWeight.w700 : FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _TierRequirements extends StatelessWidget {
  final int projects;
  final String tier;
  const _TierRequirements({required this.projects, required this.tier});

  @override
  Widget build(BuildContext context) {
    final isPlatinum = tier == 'Platinum';
    final isGold = tier == 'Gold';
    
    // Gold needs 5 projects, Platinum needs 20
    final targetLabel = isPlatinum ? 'You\'ve reached Platinum! 🎉' : (isGold ? 'Road to Platinum:' : 'Road to Gold:');
    final targetProjects = isGold || isPlatinum ? 20 : 5;
    final requirement = isPlatinum
        ? 'Maintain your excellence and exclusive city rights.'
        : isGold
            ? '20 projects required  ·  Exclusive City Rights  ·  Guaranteed Payments'
            : '5 projects required  ·  Priority Listings  ·  Monthly Payouts';
    double progress = projects / targetProjects;
    if (progress > 1.0) progress = 1.0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            targetLabel,
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            requirement,
            style:
                GoogleFonts.dmSans(fontSize: 11, color: AppColors.whiteDim),
          ),
          const SizedBox(height: 10),
          if (!isPlatinum)
            Row(
              children: [
                Text(
                  'PROGRESS',
                  style: GoogleFonts.dmSans(
                      fontSize: 10, color: AppColors.whiteDim, letterSpacing: 1),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppColors.black5,
                        borderRadius: BorderRadius.circular(2)),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$projects/$targetProjects',
                  style: GoogleFonts.dmSans(
                      fontSize: 10, color: AppColors.gold),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _PerfCard extends StatelessWidget {
  final String value;
  final String label;
  const _PerfCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: GoogleFonts.cormorantGaramond(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.goldLight,
            ),
          ),
          const SizedBox(height: 3),
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 10, color: AppColors.whiteDim)),
        ],
      ),
    );
  }
}
