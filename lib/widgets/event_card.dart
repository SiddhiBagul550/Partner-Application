import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../models/event_model.dart';
import '../../services/event_service.dart';
import '../../services/vendor_service.dart';

class EventCard extends StatelessWidget {
  final EventModel event;
  const EventCard({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final colors = _statusColors(event.status);
    final vendorEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final hasApplied = event.committedVendors.contains(vendorEmail);
    final isFullAndNotApplied = event.isFull && !hasApplied;

    Widget cardContent = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.black4,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.goldBorder.withOpacity(0.6)),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Gold left accent bar
            Container(
              width: 3,
              decoration: BoxDecoration(
                gradient: AppColors.darkGoldGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title + status & vacancies row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.name,
                            style: GoogleFonts.dmSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _StatusBadge(status: event.status, colors: colors),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.black4,
                                border: Border.all(
                                    color: AppColors.goldBorder.withOpacity(0.4)),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${event.filledCount} / ${event.vacancies} Filled',
                                style: GoogleFonts.dmSans(
                                  fontSize: 9,
                                  color: AppColors.whiteDim,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // City + roles
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _MetaChip('📍 ${event.city}'),
                        ...event.roles.map((r) => _MetaChip('${r.category} (${r.committedVendors.length}/${r.vacancies})')),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Date
                    Text(
                      event.formattedDate,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.whiteDim,
                      ),
                    ),
                    if (event.description != null &&
                        event.description!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        event.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: AppColors.whiteDim.withOpacity(0.7),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    // Budget + apply row
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (b) =>
                              AppColors.goldGradient.createShader(b),
                          child: Text(
                            event.formattedBudget,
                            style: GoogleFonts.cormorantGaramond(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Budget',
                          style: GoogleFonts.dmSans(
                            fontSize: 10,
                            color: AppColors.whiteDim,
                          ),
                        ),
                        const Spacer(),
                        if (event.status != EventStatus.completed)
                          _ApplyButton(event: event, hasApplied: hasApplied, vendorEmail: vendorEmail),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (isFullAndNotApplied) {
      return Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 3.5, sigmaY: 3.5),
            child: cardContent,
          ),
          Positioned.fill(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.black2.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.gold, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'EVENT FULL',
                      style: GoogleFonts.dmSans(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    }

    return cardContent;
  }

  Map<String, Color> _statusColors(EventStatus s) {
    switch (s) {
      case EventStatus.ongoing:
        return {'bg': const Color(0x1F4ADE80), 'text': const Color(0xFF4ADE80)};
      case EventStatus.completed:
        return {'bg': const Color(0x1F93C5FD), 'text': const Color(0xFF93C5FD)};
      default:
        return {'bg': AppColors.goldGlow, 'text': AppColors.gold};
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final EventStatus status;
  final Map<String, Color> colors;
  const _StatusBadge({required this.status, required this.colors});

  @override
  Widget build(BuildContext context) {
    final label = status == EventStatus.upcoming
        ? 'Upcoming'
        : status == EventStatus.ongoing
            ? 'Ongoing'
            : 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors['bg'],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors['text']!.withOpacity(0.4)),
      ),
      child: Text(
        label.toUpperCase(),
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: colors['text'],
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  const _MetaChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.black5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          color: AppColors.whiteDim,
        ),
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final EventModel event;
  final bool hasApplied;
  final String vendorEmail;
  const _ApplyButton({required this.event, required this.hasApplied, required this.vendorEmail});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _isLoading = false;

  void _confirmWithdraw() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.black2,
        title: Text('Withdraw Application', style: GoogleFonts.dmSans(color: AppColors.white)),
        content: Text(
          'Are you sure you want to withdraw from "${widget.event.name}"? This will reopen your spot for other vendors.',
          style: GoogleFonts.dmSans(color: AppColors.whiteDim),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.whiteDim))),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _processWithdrawal();
            },
            child: const Text('Withdraw', style: TextStyle(color: AppColors.red)),
          )
        ],
      ),
    );
  }

  Future<void> _processWithdrawal() async {
    setState(() => _isLoading = true);
    try {
      await EventService().withdrawEvent(widget.event.id, widget.vendorEmail);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Withdrawn from event.', style: GoogleFonts.dmSans(color: AppColors.black)),
            backgroundColor: AppColors.whiteDim,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Withdrawal failed.', style: GoogleFonts.dmSans(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _processApplicationDialog() async {
    setState(() => _isLoading = true);
    try {
      final vendor = await VendorService().getVendorByEmail(widget.vendorEmail);
      if (vendor == null) throw Exception('Vendor profile not found');
      setState(() => _isLoading = false);

      if (!mounted) return;
      
      showModalBottomSheet(
        context: context,
        backgroundColor: AppColors.black3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Select Role', style: GoogleFonts.dmSans(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                ...widget.event.roles.map((role) {
                  final isRoleFull = role.isFull;
                  final vendorQualifies = vendor.services.contains(role.category);
                  
                  final canApply = !isRoleFull && vendorQualifies;
                  
                  return ListTile(
                    title: Text(role.category, style: GoogleFonts.dmSans(color: Colors.white)),
                    subtitle: Text(
                      isRoleFull ? 'Filled (${role.vacancies}/${role.vacancies})' : (vendorQualifies ? 'Open (${role.committedVendors.length}/${role.vacancies})' : 'Missing Qualification'),
                      style: GoogleFonts.dmSans(color: isRoleFull || !vendorQualifies ? Colors.redAccent : Colors.tealAccent),
                    ),
                    trailing: canApply ? const Icon(Icons.arrow_forward_ios, color: AppColors.gold, size: 16) : null,
                    onTap: canApply ? () {
                      Navigator.pop(ctx);
                      _executeApplication(role.category);
                    } : null,
                  );
                }),
              ],
            ),
          );
        }
      );
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _executeApplication(String categoryRole) async {
    setState(() => _isLoading = true);
    try {
      await EventService().acceptEvent(widget.event.id, widget.vendorEmail, categoryRole);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied as $categoryRole for "${widget.event.name}"', style: GoogleFonts.dmSans(color: AppColors.black)),
            backgroundColor: AppColors.gold,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Application failed. It may be full.', style: GoogleFonts.dmSans(color: Colors.white)), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasApplied = widget.hasApplied;
    final isFull = widget.event.isFull;
    final isDisabled = _isLoading;

    String buttonText;
    Color buttonColor;

    if (_isLoading) {
      buttonText = '...';
      buttonColor = AppColors.whiteDim;
    } else if (hasApplied) {
      EventRole? assignedRole;
      try {
        assignedRole = widget.event.roles.firstWhere((r) => r.committedVendors.contains(widget.vendorEmail));
      } catch (_) {}
      buttonText = assignedRole != null ? 'Withdraw (${assignedRole.category})' : 'Withdraw';
      buttonColor = AppColors.red;
    } else if (isFull) {
      buttonText = 'Filled';
      buttonColor = AppColors.whiteDim;
    } else {
      buttonText = 'Apply';
      buttonColor = AppColors.gold;
    }

    // You can't apply if it's full AND you haven't applied
    final cannotTap = isDisabled || (isFull && !hasApplied);

    return GestureDetector(
      onTap: cannotTap
          ? null
          : (hasApplied ? _confirmWithdraw : _processApplicationDialog),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
              color: cannotTap
                  ? buttonColor.withOpacity(0.3)
                  : buttonColor),
          borderRadius: BorderRadius.circular(10),
          color: cannotTap ? buttonColor.withOpacity(0.1) : (hasApplied ? buttonColor.withOpacity(0.1) : null),
        ),
        child: Text(
          buttonText,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: cannotTap
                ? buttonColor.withOpacity(0.6)
                : buttonColor,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
