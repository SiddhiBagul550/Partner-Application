import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../screens/static_content_screen.dart';

class MenuGrid extends StatelessWidget {
  final Function(int) onNavTap;
  const MenuGrid({super.key, required this.onNavTap});

  static const _items = [
    {'icon': '📂', 'label': 'My Projects'},
    {'icon': '💰', 'label': 'Earnings'},
    {'icon': '📊', 'label': 'Performance'},
    {'icon': '📄', 'label': 'Agreements'},
    {'icon': '📢', 'label': 'Events'},
    {'icon': '🏆', 'label': 'Vendor Level'},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.1,
      ),
      itemCount: _items.length,
      itemBuilder: (context, i) {
        final item = _items[i];
        return _MenuCard(
          icon: item['icon']!,
          label: item['label']!,
          onTap: () {
            if (i == 0) onNavTap(1);      // My Projects -> index 1
            else if (i == 1) onNavTap(3); // Earnings -> index 3
            else if (i == 2) onNavTap(4); // Performance (Profile) -> index 4
            else if (i == 4) onNavTap(2); // Events -> index 2
            else if (i == 5) onNavTap(4); // Vendor Level (Profile) -> index 4
            else if (i == 3) {
              // Agreements -> Bottom Sheet
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) => _buildAgreementsSheet(ctx),
              );
            }
          },
        );
      },
    );
  }

  Widget _buildAgreementsSheet(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.black2,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.goldBorder)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.whiteDim,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'AGREEMENTS',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: AppColors.gold,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          ListTile(
            leading: const Icon(Icons.description_outlined, color: AppColors.goldLight),
            title: Text('Terms and Conditions', style: GoogleFonts.dmSans(color: AppColors.white)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.whiteDim),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: AppColors.black4,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaticContentScreen(title: 'Terms and Conditions')));
            },
          ),
          const SizedBox(height: 10),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: AppColors.goldLight),
            title: Text('Privacy Policy', style: GoogleFonts.dmSans(color: AppColors.white)),
            trailing: const Icon(Icons.chevron_right, color: AppColors.whiteDim),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            tileColor: AppColors.black4,
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const StaticContentScreen(title: 'Privacy Policy')));
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final String icon;
  final String label;
  final VoidCallback onTap;
  const _MenuCard(
      {required this.icon, required this.label, required this.onTap});

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _hovering = true),
      onTapUp: (_) => setState(() => _hovering = false),
      onTapCancel: () => setState(() => _hovering = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _hovering
              ? AppColors.goldGlow
              : AppColors.black4,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _hovering
                ? AppColors.gold
                : AppColors.goldBorder.withOpacity(0.4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(widget.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.whiteDim,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
