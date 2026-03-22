import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/alarm_model.dart';

const _uuid = Uuid();

class AppState extends ChangeNotifier {
  // ── Alarms ────────────────────────────────────────────────────────────────
  final List<AlarmModel> _alarms = [
    AlarmModel(
      id: _uuid.v4(),
      label: 'Good morning',
      time: const TimeOfDay(hour: 7, minute: 0),
      isEnabled: true,
      repeatDays: [true, true, true, true, true, false, false],
      challengeType: ChallengeType.math,
      difficulty: Difficulty.medium,
    ),
    AlarmModel(
      id: _uuid.v4(),
      label: 'Gym time',
      time: const TimeOfDay(hour: 6, minute: 30),
      isEnabled: false,
      repeatDays: [false, false, false, false, false, true, true],
      challengeType: ChallengeType.pattern,
      difficulty: Difficulty.hard,
    ),
    AlarmModel(
      id: _uuid.v4(),
      label: 'Meditation',
      time: const TimeOfDay(hour: 8, minute: 15),
      isEnabled: true,
      challengeType: ChallengeType.wordTyping,
      difficulty: Difficulty.easy,
    ),
  ];

  List<AlarmModel> get alarms => List.unmodifiable(_alarms);

  AlarmModel? get nextAlarm {
    final enabled = _alarms.where((a) => a.isEnabled).toList();
    if (enabled.isEmpty) return null;
    enabled.sort((a, b) {
      int toMins(TimeOfDay t) => t.hour * 60 + t.minute;
      return toMins(a.time).compareTo(toMins(b.time));
    });
    return enabled.first;
  }

  void addAlarm(AlarmModel alarm) {
    _alarms.add(alarm);
    notifyListeners();
  }

  void updateAlarm(AlarmModel alarm) {
    final i = _alarms.indexWhere((a) => a.id == alarm.id);
    if (i != -1) {
      _alarms[i] = alarm;
      notifyListeners();
    }
  }

  void toggleAlarm(String id) {
    final i = _alarms.indexWhere((a) => a.id == id);
    if (i != -1) {
      _alarms[i] = _alarms[i].copyWith(isEnabled: !_alarms[i].isEnabled);
      notifyListeners();
    }
  }

  void deleteAlarm(String id) {
    _alarms.removeWhere((a) => a.id == id);
    notifyListeners();
  }

  // ── Settings ──────────────────────────────────────────────────────────────
  double volume = 0.8;
  double vibrationLevel = 0.6; // 0=off, 0.5=medium, 1=high
  String selectedSound = 'Default Bell';
  bool randomChallenge = false;

  final List<String> availableSounds = [
    'Default Bell',
    'Digital Beep',
    'Gentle Chime',
    'Rooster',
    'Custom (MP3)...',
  ];

  void updateVolume(double v) {
    volume = v;
    notifyListeners();
  }

  void updateVibration(double v) {
    vibrationLevel = v;
    notifyListeners();
  }

  void updateSound(String s) {
    selectedSound = s;
    notifyListeners();
  }

  void toggleRandomChallenge(bool v) {
    randomChallenge = v;
    notifyListeners();
  }
}
