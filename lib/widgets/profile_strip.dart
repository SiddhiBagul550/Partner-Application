import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

class ProfileStrip extends StatelessWidget {
  const ProfileStrip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.15),
            AppColors.gold.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.goldGradient,
            ),
            child: Center(
              child: Text(
                'R',
                style: GoogleFonts.cormorantGaramond(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Name + tier
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rajiv Sharma',
                  style: GoogleFonts.dmSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                ShaderMask(
                  shaderCallback: (b) =>
                      AppColors.goldGradient.createShader(b),
                  child: Text(
                    '✦ Gold Vendor',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Rating + wallet
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '⭐ 4.8',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '₹12,400',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: AppColors.whiteDim,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
