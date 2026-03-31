import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';

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
            // Map menu items to bottom nav or show snackbar
            if (i == 4) onNavTap(2); // Events → index 2
          },
        );
      },
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
