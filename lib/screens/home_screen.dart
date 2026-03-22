import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/alarm_model.dart';
import '../state/app_state.dart';
import '../widgets/alarm_card.dart';
import 'add_alarm_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppState>(
      builder: (context, state, _) {
        final next = state.nextAlarm;
        return Scaffold(
          backgroundColor: const Color(0xFFF3EFFF),
          body: Stack(
            children: [
              // ── Background decoration ──────────────────────────────────────
              Positioned(
                top: -80,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF7C4DFF).withOpacity(0.08),
                  ),
                ),
              ),
              Positioned(
                top: 60,
                left: -80,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF9C6FFF).withOpacity(0.06),
                  ),
                ),
              ),

              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Top bar ──────────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 20, 0),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WakeUpp',
                                style: GoogleFonts.dmSans(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF1A0050),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              Text(
                                'Rise. Challenge. Conquer.',
                                style: GoogleFonts.dmSans(
                                  fontSize: 12,
                                  color:
                                      const Color(0xFF7C4DFF).withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              _fadeRoute(const SettingsScreen()),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF7C4DFF)
                                        .withOpacity(0.12),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.settings_outlined,
                                color: Color(0xFF7C4DFF),
                                size: 22,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Next alarm banner ────────────────────────────────────
                    if (next != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ScaleTransition(
                          scale: _pulseAnim,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF7C4DFF), Color(0xFFAA80FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      const Color(0xFF7C4DFF).withOpacity(0.35),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Next to do:',
                                        style: GoogleFonts.dmSans(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.75),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        next.label,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                          letterSpacing: -0.3,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        next.formattedTime,
                                        style: GoogleFonts.dmSans(
                                          fontSize: 13,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.alarm_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    if (next == null)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'No alarms enabled. Tap + to add one!',
                            style: GoogleFonts.dmSans(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),

                    const SizedBox(height: 28),

                    // ── Alarm list header ────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        children: [
                          Text(
                            'All Alarms',
                            style: GoogleFonts.dmSans(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1A0050),
                              letterSpacing: -0.3,
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${state.alarms.length} alarms',
                              style: GoogleFonts.dmSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF7C4DFF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // ── Alarm list ───────────────────────────────────────────
                    Expanded(
                      child: state.alarms.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.alarm_off_rounded,
                                    size: 64,
                                    color: const Color(0xFF7C4DFF)
                                        .withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No alarms yet',
                                    style: GoogleFonts.dmSans(
                                      fontSize: 16,
                                      color: const Color(0xFF9E9E9E),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.fromLTRB(24, 0, 24, 100),
                              itemCount: state.alarms.length,
                              itemBuilder: (_, i) => AlarmCard(
                                alarm: state.alarms[i],
                                onToggle: () =>
                                    state.toggleAlarm(state.alarms[i].id),
                                onDelete: () =>
                                    state.deleteAlarm(state.alarms[i].id),
                                onEdit: () async {
                                  final updated =
                                      await Navigator.push<AlarmModel>(
                                    context,
                                    _slideRoute(AddAlarmScreen(
                                        existing: state.alarms[i])),
                                  );
                                  if (updated != null)
                                    state.updateAlarm(updated);
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── FAB ────────────────────────────────────────────────────────────
          floatingActionButton: GestureDetector(
            onTap: () async {
              final alarm = await Navigator.push<AlarmModel>(
                context,
                _slideRoute(const AddAlarmScreen()),
              );
              if (alarm != null) {
                context.read<AppState>().addAlarm(alarm);
              }
            },
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFFAA80FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C4DFF).withOpacity(0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 30),
            ),
          ),
        );
      },
    );
  }
}

// Change <dynamic> to <T> to make it a generic helper
Route<T> _slideRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, anim, __) => page,
      transitionsBuilder: (_, anim, __, child) => SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 380),
    );

Route<T> _fadeRoute<T>(Widget page) => PageRouteBuilder<T>(
      pageBuilder: (_, anim, __) => page,
      transitionsBuilder: (_, anim, __, child) =>
          FadeTransition(opacity: anim, child: child),
      transitionDuration: const Duration(milliseconds: 250),
    );
