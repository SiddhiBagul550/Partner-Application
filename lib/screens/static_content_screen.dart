import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class StaticContentScreen extends StatelessWidget {
  final String title;
  const StaticContentScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final bool isTerms = title.toLowerCase().contains('term');
    final content = isTerms
        ? '''1. Introduction\nWelcome to FliqaIndia Vendor Platform. By accessing or using our app, you agree to be bound by these Terms.\n\n2. Service Agreement\nVendors agree to provide the services described at the agreed-upon rates. FliqaIndia reserves the right to suspend or terminate vendors for non-compliance.\n\n3. Payments\nPayments are disbursed within 5 business days of project completion confirmation.\n\n4. Conduct\nVendors must maintain professional conduct and high quality on all assigned projects.'''
        : '''1. Information Collection\nWe collect information you provide directly to us (e.g., registration details, banking info) and automatically (e.g., device logs). \n\n2. Use of Information\nThis data is used to verify identities, process payments, and improve platform functionality.\n\n3. Data Sharing\nWe do not share your private data with third parties except as necessary to provide services (e.g., payment gateways).\n\n4. Security\nWe implement standard security measures to protect your personal information.''';

    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        iconTheme: const IconThemeData(color: AppColors.gold),
        title: Text(
          title,
          style: GoogleFonts.cormorantGaramond(
            color: AppColors.goldLight,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Text(
          content,
          style: GoogleFonts.dmSans(
            fontSize: 14,
            color: AppColors.whiteDim,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}
