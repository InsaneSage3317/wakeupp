import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';

const _uuid = Uuid();

class AddAlarmScreen extends StatefulWidget {
  final AlarmModel? existing;
  const AddAlarmScreen({super.key, this.existing});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late TimeOfDay _time;
  late TextEditingController _labelCtrl;
  late ChallengeType _challengeType;
  late Difficulty _difficulty;
  late List<bool> _repeatDays;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _time = e?.time ?? TimeOfDay.now();
    _labelCtrl = TextEditingController(text: e?.label ?? '');
    _challengeType = e?.challengeType ?? ChallengeType.math;
    _difficulty = e?.difficulty ?? Difficulty.medium;
    _repeatDays = e?.repeatDays != null
        ? List.from(e!.repeatDays)
        : List.filled(7, false);
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF7C4DFF),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1A0050),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _save() {
    final alarm = AlarmModel(
      id: widget.existing?.id ?? _uuid.v4(),
      label: _labelCtrl.text.trim().isEmpty
          ? 'Alarm'
          : _labelCtrl.text.trim(),
      time: _time,
      isEnabled: widget.existing?.isEnabled ?? true,
      repeatDays: _repeatDays,
      challengeType: _challengeType,
      difficulty: _difficulty,
    );
    Navigator.pop(context, alarm);
  }

  @override
  Widget build(BuildContext context) {
    final h = _time.hourOfPeriod == 0 ? 12 : _time.hourOfPeriod;
    final m = _time.minute.toString().padLeft(2, '0');
    final period = _time.period == DayPeriod.am ? 'AM' : 'PM';

    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFF),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Color(0xFF1A0050), size: 20),
                  ),
                  Text(
                    _isEdit ? 'Edit alarm' : 'New reminder',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A0050),
                    ),
                  ),
                  const Spacer(),
                  Icon(Icons.tune_rounded,
                      color: const Color(0xFF7C4DFF).withOpacity(0.5), size: 22),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Time display ─────────────────────────────────────────
                    GestureDetector(
                      onTap: _pickTime,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF7C4DFF), Color(0xFFAA80FF)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF7C4DFF).withOpacity(0.3),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '$h:$m',
                                  style: GoogleFonts.dmSans(
                                    fontSize: 64,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -2,
                                    height: 1,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text(
                                    period,
                                    style: GoogleFonts.dmSans(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to change time',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.65),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Label ────────────────────────────────────────────────
                    _SectionLabel(label: 'Name'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _labelCtrl,
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          color: const Color(0xFF1A0050),
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          hintText: 'e.g. Good morning',
                          hintStyle: GoogleFonts.dmSans(
                              color: const Color(0xFFB0B0B0)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          prefixIcon: const Icon(Icons.label_outline_rounded,
                              color: Color(0xFF7C4DFF), size: 20),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Repeat Days ──────────────────────────────────────────
                    _SectionLabel(label: 'Repeat'),
                    const SizedBox(height: 10),
                    _RepeatDayPicker(
                      days: _repeatDays,
                      onChanged: (i) =>
                          setState(() => _repeatDays[i] = !_repeatDays[i]),
                    ),

                    const SizedBox(height: 24),

                    // ── Challenge Type ───────────────────────────────────────
                    _SectionLabel(label: 'Challenge type'),
                    const SizedBox(height: 10),
                    _ChallengeTypePicker(
                      selected: _challengeType,
                      onChanged: (t) => setState(() => _challengeType = t),
                    ),

                    const SizedBox(height: 24),

                    // ── Difficulty ───────────────────────────────────────────
                    _SectionLabel(label: 'Difficulty level'),
                    const SizedBox(height: 10),
                    _DifficultyPicker(
                      selected: _difficulty,
                      onChanged: (d) => setState(() => _difficulty = d),
                    ),

                    const SizedBox(height: 32),

                    // ── Save Button ──────────────────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: GestureDetector(
                        onTap: _save,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C4DFF), Color(0xFFAA80FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7C4DFF).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _isEdit ? 'Update alarm' : 'Set reminder',
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
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

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.dmSans(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF6B6B8A),
        letterSpacing: 0.3,
      ),
    );
  }
}

// ── Repeat Day Picker ─────────────────────────────────────────────────────────
class _RepeatDayPicker extends StatelessWidget {
  final List<bool> days;
  final void Function(int) onChanged;

  const _RepeatDayPicker({required this.days, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final active = days[i];
        return GestureDetector(
          onTap: () => onChanged(i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF7C4DFF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? const Color(0xFF7C4DFF).withOpacity(0.3)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                labels[i],
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF9E9E9E),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

// ── Challenge Type Picker ─────────────────────────────────────────────────────
class _ChallengeTypePicker extends StatelessWidget {
  final ChallengeType selected;
  final void Function(ChallengeType) onChanged;

  const _ChallengeTypePicker(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final options = [
      (ChallengeType.math, Icons.calculate_outlined, 'Math\nProblem'),
      (ChallengeType.wordTyping, Icons.keyboard_outlined, 'Word\nTyping'),
      (ChallengeType.pattern, Icons.grid_view_rounded, 'Pattern\nChallenge'),
    ];

    return Row(
      children: options.map((opt) {
        final (type, icon, label) = opt;
        final isSelected = selected == type;
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF7C4DFF) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF7C4DFF).withOpacity(0.35)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(icon,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF7C4DFF),
                      size: 26),
                  const SizedBox(height: 8),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.dmSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF6B6B8A),
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Difficulty Picker ─────────────────────────────────────────────────────────
class _DifficultyPicker extends StatelessWidget {
  final Difficulty selected;
  final void Function(Difficulty) onChanged;

  const _DifficultyPicker({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = [
      (Difficulty.easy, '😊', 'Easy', Color(0xFF4CAF50)),
      (Difficulty.medium, '🔥', 'Medium', Color(0xFFFF9800)),
      (Difficulty.hard, '💀', 'Hard', Color(0xFFE53935)),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: options.map((opt) {
          final (diff, emoji, label, color) = opt;
          final isSelected = selected == diff;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(diff),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? color.withOpacity(0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: isSelected
                      ? Border.all(color: color.withOpacity(0.4), width: 1.5)
                      : null,
                ),
                child: Column(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? color : const Color(0xFF9E9E9E),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
