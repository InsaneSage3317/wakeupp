import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) => Scaffold(
        backgroundColor: const Color(0xFFF3EFFF),
        body: SafeArea(
          child: Column(
            children: [
              // ── Header ─────────────────────────────────────────────────────
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
                      'Settings',
                      style: GoogleFonts.dmSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF1A0050),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    // ── Sound section ─────────────────────────────────────────
                    _SettingsCard(
                      children: [
                        _SettingsHeader(
                            icon: Icons.volume_up_rounded, title: 'Sound'),
                        const SizedBox(height: 16),
                        _SliderRow(
                          label: 'Volume',
                          value: state.volume,
                          icon: Icons.volume_up_outlined,
                          color: const Color(0xFF7C4DFF),
                          onChanged: state.updateVolume,
                        ),
                        const SizedBox(height: 4),

                        // Sound selector
                        _SectionSubLabel('Alarm sound'),
                        const SizedBox(height: 8),
                        ...state.availableSounds.map((s) => _SoundOption(
                              label: s,
                              isSelected: state.selectedSound == s,
                              onTap: () {
                                if (s == 'Custom (MP3)...') {
                                  _showCustomSoundDialog(context);
                                } else {
                                  state.updateSound(s);
                                }
                              },
                            )),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Vibration section ─────────────────────────────────────
                    _SettingsCard(
                      children: [
                        _SettingsHeader(
                            icon: Icons.vibration_rounded,
                            title: 'Vibration'),
                        const SizedBox(height: 16),
                        _SliderRow(
                          label: 'Intensity',
                          value: state.vibrationLevel,
                          icon: Icons.vibration_rounded,
                          color: const Color(0xFFAA80FF),
                          onChanged: state.updateVibration,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: ['Off', 'Low', 'Medium', 'High'].map((l) {
                            return Text(
                              l,
                              style: GoogleFonts.dmSans(
                                fontSize: 10,
                                color: const Color(0xFFB0B0B0),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Challenge section ─────────────────────────────────────
                    _SettingsCard(
                      children: [
                        _SettingsHeader(
                            icon: Icons.psychology_rounded,
                            title: 'Challenge'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Random challenge',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFF1A0050),
                                    ),
                                  ),
                                  Text(
                                    'Pick a random challenge each time',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 11,
                                      color: const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            _PurpleSwitch(
                              value: state.randomChallenge,
                              onChanged: state.toggleRandomChallenge,
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── About card ────────────────────────────────────────────
                    _SettingsCard(
                      children: [
                        _SettingsHeader(
                            icon: Icons.info_outline_rounded,
                            title: 'About'),
                        const SizedBox(height: 12),
                        _InfoRow(label: 'App', value: 'WakeUpp'),
                        _InfoRow(label: 'Version', value: '1.0.0'),
                        _InfoRow(label: 'Build', value: 'Hackathon Edition'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCustomSoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Custom sound',
          style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700, color: const Color(0xFF1A0050)),
        ),
        content: Text(
          'Attach an MP3 file to use as your alarm sound.\n\n(File picker integration requires file_picker package — connect in production)',
          style: GoogleFonts.dmSans(
              fontSize: 13, color: const Color(0xFF6B6B8A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it',
                style: GoogleFonts.dmSans(
                    color: const Color(0xFF7C4DFF),
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SettingsHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color(0xFF7C4DFF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF7C4DFF), size: 18),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A0050),
          ),
        ),
      ],
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  final void Function(double) onChanged;

  const _SliderRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: color.withOpacity(0.15),
              thumbColor: color,
              overlayColor: color.withOpacity(0.1),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: value,
              onChanged: onChanged,
            ),
          ),
        ),
        Text(
          '${(value * 100).round()}%',
          style: GoogleFonts.dmSans(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _SoundOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF7C4DFF).withOpacity(0.08)
              : const Color(0xFFF8F8FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF7C4DFF).withOpacity(0.4)
                : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              label.contains('Custom')
                  ? Icons.attach_file_rounded
                  : Icons.music_note_rounded,
              size: 16,
              color: isSelected
                  ? const Color(0xFF7C4DFF)
                  : const Color(0xFFB0B0B0),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF7C4DFF)
                    : const Color(0xFF6B6B8A),
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF7C4DFF), size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionSubLabel extends StatelessWidget {
  final String text;
  const _SectionSubLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 0),
      child: Text(
        text,
        style: GoogleFonts.dmSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF9E9E9E),
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.dmSans(
                  fontSize: 13, color: const Color(0xFF9E9E9E))),
          Text(value,
              style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1A0050))),
        ],
      ),
    );
  }
}

class _PurpleSwitch extends StatelessWidget {
  final bool value;
  final void Function(bool) onChanged;
  const _PurpleSwitch({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF7C4DFF),
      activeTrackColor: const Color(0xFF7C4DFF).withOpacity(0.3),
      inactiveThumbColor: Colors.white,
      inactiveTrackColor: const Color(0xFFE0E0E0),
    );
  }
}
