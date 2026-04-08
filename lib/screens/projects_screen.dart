import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../models/event_model.dart';
import '../services/event_service.dart';

class ProjectsScreen extends StatefulWidget {
  const ProjectsScreen({super.key});

  @override
  State<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends State<ProjectsScreen> {
  int _tabIndex = 0;
  static const _tabs = ['Upcoming', 'Ongoing', 'Completed'];

  @override
  Widget build(BuildContext context) {
    final vendorEmail = FirebaseAuth.instance.currentUser?.email ?? '';

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
            child: StreamBuilder<List<EventModel>>(
              stream: EventService().vendorEventsStream(vendorEmail),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.gold));
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error loading projects', style: GoogleFonts.dmSans(color: AppColors.red)),
                  );
                }

                final events = snapshot.data ?? [];
                
                // Map the EventStatus enum directly into the _tabs indexes
                // 0 -> Upcoming
                // 1 -> Ongoing
                // 2 -> Completed
                final filtered = events.where((e) {
                  if (_tabIndex == 0 && e.status == EventStatus.upcoming) return true;
                  if (_tabIndex == 1 && e.status == EventStatus.ongoing) return true;
                  if (_tabIndex == 2 && e.status == EventStatus.completed) return true;
                  return false;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No ${_tabs[_tabIndex].toLowerCase()} projects found.',
                      style: GoogleFonts.dmSans(color: AppColors.whiteDim),
                    ),
                  );
                }

                return ListView(
                  children: filtered.map((e) => _buildCard(e)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(EventModel event) {
    final isDone = event.status == EventStatus.completed;
    final badgeColor = isDone ? AppColors.green : AppColors.gold;
    final badgeLabel = isDone ? 'Done' : (event.status == EventStatus.ongoing ? 'Active' : 'Pending');

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
                      event.name,
                      style: GoogleFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text('📍 ${event.city}',
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppColors.whiteDim)),
                        const SizedBox(width: 10),
                        Text(event.formattedDate,
                            style: GoogleFonts.dmSans(
                                fontSize: 11, color: AppColors.whiteDim)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('💸 ${event.formattedBudget}',
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
