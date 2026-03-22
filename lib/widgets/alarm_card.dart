import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alarm_model.dart';

class AlarmCard extends StatefulWidget {
  final AlarmModel alarm;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<AlarmCard> createState() => _AlarmCardState();
}

class _AlarmCardState extends State<AlarmCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1, end: 0.97)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _challengeColor {
    switch (widget.alarm.challengeType) {
      case ChallengeType.math:
        return const Color(0xFF7C4DFF);
      case ChallengeType.wordTyping:
        return const Color(0xFF2196F3);
      case ChallengeType.pattern:
        return const Color(0xFFFF9800);
    }
  }

  IconData get _challengeIcon {
    switch (widget.alarm.challengeType) {
      case ChallengeType.math:
        return Icons.calculate_outlined;
      case ChallengeType.wordTyping:
        return Icons.keyboard_outlined;
      case ChallengeType.pattern:
        return Icons.grid_view_rounded;
    }
  }

  Color get _diffColor {
    switch (widget.alarm.difficulty) {
      case Difficulty.easy:
        return const Color(0xFF4CAF50);
      case Difficulty.medium:
        return const Color(0xFFFF9800);
      case Difficulty.hard:
        return const Color(0xFFE53935);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.alarm.isEnabled;

    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onEdit();
      },
      onTapCancel: () => _ctrl.reverse(),
      onLongPress: () => _showDeleteDialog(context),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: enabled
                    ? const Color(0xFF7C4DFF).withOpacity(0.08)
                    : Colors.black.withOpacity(0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
            border: enabled
                ? Border.all(
                    color: const Color(0xFF7C4DFF).withOpacity(0.15),
                    width: 1.2)
                : null,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Time
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.alarm.formattedTime,
                            style: GoogleFonts.dmSans(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: enabled
                                  ? const Color(0xFF1A0050)
                                  : const Color(0xFFB0B0B0),
                              letterSpacing: -1,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.alarm.label,
                            style: GoogleFonts.dmSans(
                              fontSize: 13,
                              color: enabled
                                  ? const Color(0xFF6B6B8A)
                                  : const Color(0xFFCCCCCC),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Toggle
                    GestureDetector(
                      onTap: () {
                        widget.onToggle();
                      },
                      child: _PurpleToggle(value: enabled),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF0F0F0)),
                const SizedBox(height: 12),

                // Meta row
                Row(
                  children: [
                    // Repeat
                    Icon(
                      Icons.repeat_rounded,
                      size: 13,
                      color: enabled
                          ? const Color(0xFF7C4DFF)
                          : const Color(0xFFCCCCCC),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.alarm.repeatLabel,
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: enabled
                            ? const Color(0xFF6B6B8A)
                            : const Color(0xFFCCCCCC),
                      ),
                    ),
                    const Spacer(),

                    // Challenge badge
                    _ChallengeBadge(
                      icon: _challengeIcon,
                      label: widget.alarm.challengeLabel,
                      color: enabled ? _challengeColor : const Color(0xFFCCCCCC),
                    ),
                    const SizedBox(width: 6),

                    // Difficulty badge
                    _DiffBadge(
                      label: widget.alarm.difficultyLabel,
                      color: enabled ? _diffColor : const Color(0xFFCCCCCC),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete alarm?',
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700, color: const Color(0xFF1A0050)),
        ),
        content: Text(
          '"${widget.alarm.label}" will be permanently deleted.',
          style: GoogleFonts.dmSans(
              fontSize: 13, color: const Color(0xFF6B6B8A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel',
                style: GoogleFonts.dmSans(color: const Color(0xFF9E9E9E))),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDelete();
            },
            child: Text('Delete',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _PurpleToggle extends StatelessWidget {
  final bool value;
  const _PurpleToggle({required this.value});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: 52,
      height: 30,
      decoration: BoxDecoration(
        color: value ? const Color(0xFF7C4DFF) : const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(15),
        boxShadow: value
            ? [
                BoxShadow(
                  color: const Color(0xFF7C4DFF).withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : [],
      ),
      child: Stack(
        children: [
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutBack,
            left: value ? 24 : 2,
            top: 2,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ChallengeBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _DiffBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
