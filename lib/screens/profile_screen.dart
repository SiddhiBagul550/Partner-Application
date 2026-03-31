import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
          _TierProgress(),
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
                  'You are: GOLD ⭐',
                  style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: AppColors.gold,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  'Projects: 8  ·  Rating: 4.8  ·  On-time: 92%',
                  style: GoogleFonts.dmSans(
                      fontSize: 11, color: AppColors.whiteDim),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _TierRequirements(),
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
            children: const [
              _PerfCard(value: '96%', label: 'Completion'),
              _PerfCard(value: '92%', label: 'On-time'),
              _PerfCard(value: '4.8 ⭐', label: 'Rating'),
              _PerfCard(value: '40%', label: 'Repeat Clients'),
            ],
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
}

class _TierProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TierCircle(emoji: '🥈', name: 'Silver', color: const Color(0xFFAAAAAA), active: false, done: true),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(gradient: AppColors.goldGradient),
          ),
        ),
        _TierCircle(emoji: '⭐', name: 'Gold', color: AppColors.gold, active: true, done: false),
        Expanded(
          child: Container(height: 2, color: AppColors.black5),
        ),
        _TierCircle(emoji: '💎', name: 'Platinum', color: const Color(0xFFB0C4DE), active: false, done: false, faded: true),
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
              color: active ? AppColors.goldGlow : Colors.transparent,
              border: Border.all(color: color, width: 2),
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
  @override
  Widget build(BuildContext context) {
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
            'Platinum Requirements:',
            style: GoogleFonts.dmSans(
                fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            '20+ projects  ·  City Exclusive Rights  ·  Contract Agreement',
            style:
                GoogleFonts.dmSans(fontSize: 11, color: AppColors.whiteDim),
          ),
          const SizedBox(height: 10),
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
                    widthFactor: 0.40,
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
                '8/20',
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
