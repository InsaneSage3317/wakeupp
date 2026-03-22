import 'package:flutter/material.dart'; // Add this line

enum ChallengeType { math, wordTyping, pattern }

enum Difficulty { easy, medium, hard }

class AlarmModel {
  final String id;
  String label;
  TimeOfDay time;
  bool isEnabled;
  List<bool> repeatDays; // Mon–Sun
  ChallengeType challengeType;
  Difficulty difficulty;

  AlarmModel({
    required this.id,
    required this.label,
    required this.time,
    this.isEnabled = true,
    List<bool>? repeatDays,
    this.challengeType = ChallengeType.math,
    this.difficulty = Difficulty.medium,
  }) : repeatDays = repeatDays ?? List.filled(7, false);

  String get formattedTime {
    final h = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final m = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String get repeatLabel {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    final active = <String>[];
    for (int i = 0; i < 7; i++) {
      if (repeatDays[i]) active.add(days[i]);
    }
    if (active.isEmpty) return 'No repeat';
    if (active.length == 7) return 'Every day';
    if (active.length == 5 &&
        repeatDays.sublist(0, 5).every((d) => d) &&
        !repeatDays[5] &&
        !repeatDays[6]) return 'Weekdays';
    return active.join(', ');
  }

  String get challengeLabel {
    switch (challengeType) {
      case ChallengeType.math:
        return 'Math';
      case ChallengeType.wordTyping:
        return 'Word Typing';
      case ChallengeType.pattern:
        return 'Pattern';
    }
  }

  String get difficultyLabel {
    switch (difficulty) {
      case Difficulty.easy:
        return 'Easy';
      case Difficulty.medium:
        return 'Medium';
      case Difficulty.hard:
        return 'Hard';
    }
  }

  AlarmModel copyWith({
    String? label,
    TimeOfDay? time,
    bool? isEnabled,
    List<bool>? repeatDays,
    ChallengeType? challengeType,
    Difficulty? difficulty,
  }) {
    return AlarmModel(
      id: id,
      label: label ?? this.label,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      repeatDays: repeatDays ?? List.from(this.repeatDays),
      challengeType: challengeType ?? this.challengeType,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
