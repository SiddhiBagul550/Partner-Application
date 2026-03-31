import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Ongoing', 'Completed', 'Pending'];

  static const _projects = [
    {
      'client': 'Ananya & Vikram Wedding',
      'city': 'Kolkata',
      'date': 'Mar 15',
      'budget': '₹28,000',
      'status': 'pending',
      'tab': 0,
    },
    {
      'client': 'TechCorp Brand Shoot',
      'city': 'Mumbai',
      'date': 'Mar 22',
      'budget': '₹15,000',
      'status': 'paid',
      'tab': 1,
    },
    {
      'client': 'Corporate Gala – Kolkata',
      'city': 'Kolkata',
      'date': 'Mar 30',
      'budget': '₹22,000',
      'status': 'pending',
      'tab': 2,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered =
        _projects.where((p) => p['tab'] == _tabIndex).toList();
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MY PROJECTS',
            style: GoogleFonts.dmSans(
              fontSize: 10,
              color: AppColors.gold,
              letterSpacing: 2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // Tabs
          Row(
            children: List.generate(
              _tabs.length,
              (i) => GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: _tabIndex == i ? AppColors.goldGlow : AppColors.black4,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _tabIndex == i
                          ? AppColors.gold
                          : AppColors.goldBorder.withOpacity(0.4),
                    ),
                  ),
                  child: Text(
                    _tabs[i],
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: _tabIndex == i ? AppColors.gold : AppColors.whiteDim,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      'No ${_tabs[_tabIndex].toLowerCase()} projects.',
                      style: GoogleFonts.dmSans(color: AppColors.whiteDim),
                    ),
                  )
                : ListView(
                    children: filtered.map(_buildCard).toList(),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(Map<String, Object> project) {
    final isPaid = project['status'] == 'paid';
    final badgeColor = isPaid ? AppColors.green : AppColors.gold;
    final badgeLabel = isPaid ? 'Paid' : 'Pending';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.4)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: AppColors.darkGoldGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      project['client'] as String,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('📍 ${project['city']}',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppColors.whiteDim)),
                        const SizedBox(width: 10),
                        Text('📅 ${project['date']}',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppColors.whiteDim)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('💸 ${project['budget']}',
                        style: GoogleFonts.dmSans(
                            fontSize: 12, color: AppColors.whiteDim)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: badgeColor.withOpacity(0.4)),
                      ),
                      child: Text(
                        badgeLabel.toUpperCase(),
                        style: GoogleFonts.dmSans(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
