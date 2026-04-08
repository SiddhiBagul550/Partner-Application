import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../services/vendor_service.dart';
import '../models/vendor_model.dart';

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
      child: StreamBuilder<VendorModel?>(
        stream: VendorService().currentVendorStream(),
        builder: (context, snapshot) {
          final vendor = snapshot.data;
          final name = vendor?.fullName ?? 'Loading...';
          final initial = name.isNotEmpty ? name[0].toUpperCase() : 'V';
          final tier = vendor?.tier ?? 'Silver';
          final rating = vendor?.rating.toStringAsFixed(1) ?? '0.0';
          final wallet = vendor?.wallet.toInt() ?? 0;

          return Row(
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
                    initial,
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
                      name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    ShaderMask(
                      shaderCallback: (b) =>
                          AppColors.goldGradient.createShader(b),
                      child: Text(
                        '✦ $tier Vendor',
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
                    '⭐ $rating',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '₹$wallet',
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      color: AppColors.whiteDim,
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}
