import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/alarm_model.dart';

class ChallengeScreen extends StatefulWidget {
  final AlarmModel alarm;
  const ChallengeScreen({super.key, required this.alarm});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen>
    with SingleTickerProviderStateMixin {
  final _rng = Random();
  late AnimationController _shakeCtrl;
  late Animation<double> _shakeAnim;

  bool _solved = false;
  String _feedbackMsg = '';
  bool _isError = false;

  // Math challenge
  late int _mathA, _mathB;
  late String _mathOp;
  late int _mathAnswer;
  final _mathCtrl = TextEditingController();

  // Word typing challenge
  late String _wordTarget;
  final _wordCtrl = TextEditingController();

  // Pattern challenge
  late List<int> _patternSequence;
  final List<int> _userPattern = [];
  bool _showingPattern = false;
  int _highlightedIndex = -1;

  @override
  void initState() {
    super.initState();
    _shakeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _shakeAnim = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _shakeCtrl, curve: Curves.elasticIn));
    _generateChallenge();
  }

  @override
  void dispose() {
    _shakeCtrl.dispose();
    _mathCtrl.dispose();
    _wordCtrl.dispose();
    super.dispose();
  }

  void _generateChallenge() {
    final d = widget.alarm.difficulty;
    switch (widget.alarm.challengeType) {
      case ChallengeType.math:
        _generateMath(d);
        break;
      case ChallengeType.wordTyping:
        _generateWord(d);
        break;
      case ChallengeType.pattern:
        _generatePattern(d);
        break;
    }
  }

  void _generateMath(Difficulty d) {
    final ops = d == Difficulty.easy
        ? ['+']
        : d == Difficulty.medium
            ? ['+', '-', '*']
            : ['+', '-', '*', '/'];
    _mathOp = ops[_rng.nextInt(ops.length)];
    final max = d == Difficulty.easy ? 10 : d == Difficulty.medium ? 50 : 99;
    _mathA = _rng.nextInt(max) + 1;
    _mathB = _rng.nextInt(max) + 1;
    if (_mathOp == '/') {
      _mathAnswer = _mathA;
      _mathA = _mathA * _mathB;
    } else if (_mathOp == '+') {
      _mathAnswer = _mathA + _mathB;
    } else if (_mathOp == '-') {
      if (_mathB > _mathA) {
        final tmp = _mathA;
        _mathA = _mathB;
        _mathB = tmp;
      }
      _mathAnswer = _mathA - _mathB;
    } else {
      _mathAnswer = _mathA * _mathB;
    }
  }

  void _generateWord(Difficulty d) {
    const easy = ['ALARM', 'AWAKE', 'RISE', 'SHINE', 'GOOD'];
    const medium = ['MORNING', 'CHALLENGE', 'FLUTTER', 'ANDROID', 'SUNRISE'];
    const hard = ['PERSEVERANCE', 'DETERMINATION', 'PRODUCTIVITY', 'DISCIPLINE'];
    final list = d == Difficulty.easy
        ? easy
        : d == Difficulty.medium
            ? medium
            : hard;
    _wordTarget = list[_rng.nextInt(list.length)];
  }

  void _generatePattern(Difficulty d) {
    final len = d == Difficulty.easy ? 4 : d == Difficulty.medium ? 6 : 9;
    _patternSequence = List.generate(len, (_) => _rng.nextInt(9));
    _userPattern.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) => _playPattern());
  }

  Future<void> _playPattern() async {
    setState(() => _showingPattern = true);
    await Future.delayed(const Duration(milliseconds: 500));
    for (final idx in _patternSequence) {
      setState(() => _highlightedIndex = idx);
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _highlightedIndex = -1);
      await Future.delayed(const Duration(milliseconds: 250));
    }
    setState(() => _showingPattern = false);
  }

  void _checkMath() {
    final input = int.tryParse(_mathCtrl.text.trim());
    if (input == _mathAnswer) {
      _onSuccess();
    } else {
      _onError('Wrong! Try again.');
      _mathCtrl.clear();
    }
  }

  void _checkWord() {
    if (_wordCtrl.text.trim().toUpperCase() == _wordTarget) {
      _onSuccess();
    } else {
      _onError('Not quite! Try again.');
      _wordCtrl.clear();
    }
  }

  void _tapPattern(int idx) {
    if (_showingPattern || _solved) return;
    setState(() => _userPattern.add(idx));
    if (_userPattern.length == _patternSequence.length) {
      if (_listsEqual(_userPattern, _patternSequence)) {
        _onSuccess();
      } else {
        _onError('Wrong pattern! Watch again.');
        _userPattern.clear();
        Future.delayed(const Duration(milliseconds: 600), _playPattern);
      }
    }
  }

  bool _listsEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _onSuccess() {
    setState(() {
      _solved = true;
      _feedbackMsg = '🎉 Alarm dismissed!';
      _isError = false;
    });
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) Navigator.pop(context);
    });
  }

  void _onError(String msg) {
    setState(() {
      _feedbackMsg = msg;
      _isError = true;
    });
    _shakeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EFFF),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // ── Alarm info ─────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7C4DFF), Color(0xFFAA80FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_rounded,
                        color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alarm.formattedTime,
                          style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          widget.alarm.label,
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    _DiffBadge(difficulty: widget.alarm.difficulty),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ── Challenge prompt ──────────────────────────────────────────
              Text(
                'Complete the challenge to dismiss',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: const Color(0xFF6B6B8A),
                ),
              ),

              const SizedBox(height: 20),

              // ── Challenge body ────────────────────────────────────────────
              Expanded(
                child: AnimatedBuilder(
                  animation: _shakeAnim,
                  builder: (_, child) => Transform.translate(
                    offset: Offset(
                        sin(_shakeAnim.value * pi * 6) * 8 * (1 - _shakeAnim.value),
                        0),
                    child: child,
                  ),
                  child: _buildChallenge(),
                ),
              ),

              // ── Feedback ──────────────────────────────────────────────────
              if (_feedbackMsg.isNotEmpty)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: _isError
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _isError
                          ? const Color(0xFFE53935).withOpacity(0.3)
                          : const Color(0xFF4CAF50).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    _feedbackMsg,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      color: _isError
                          ? const Color(0xFFE53935)
                          : const Color(0xFF4CAF50),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChallenge() {
    switch (widget.alarm.challengeType) {
      case ChallengeType.math:
        return _buildMath();
      case ChallengeType.wordTyping:
        return _buildWord();
      case ChallengeType.pattern:
        return _buildPattern();
    }
  }

  // ── Math Challenge ──────────────────────────────────────────────────────────
  Widget _buildMath() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C4DFF).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            '$_mathA $_mathOp $_mathB = ?',
            style: GoogleFonts.dmSans(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1A0050),
              letterSpacing: -1,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _mathCtrl,
          keyboardType: TextInputType.number,
          autofocus: true,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF7C4DFF),
          ),
          decoration: InputDecoration(
            hintText: 'Your answer',
            hintStyle: GoogleFonts.dmSans(
                color: const Color(0xFFB0B0B0), fontSize: 18),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF7C4DFF), width: 2),
            ),
          ),
          onSubmitted: (_) => _checkMath(),
        ),
        const SizedBox(height: 16),
        _ActionButton(label: 'Check answer', onTap: _checkMath),
      ],
    );
  }

  // ── Word Typing Challenge ───────────────────────────────────────────────────
  Widget _buildWord() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Type this word:',
          style: GoogleFonts.dmSans(
              fontSize: 14, color: const Color(0xFF6B6B8A)),
        ),
        const SizedBox(height: 12),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C4DFF).withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(
            _wordTarget,
            style: GoogleFonts.dmSans(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF7C4DFF),
              letterSpacing: 6,
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _wordCtrl,
          autofocus: true,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.characters,
          style: GoogleFonts.dmSans(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: 4,
            color: const Color(0xFF1A0050),
          ),
          decoration: InputDecoration(
            hintText: 'Type here...',
            hintStyle: GoogleFonts.dmSans(
                color: const Color(0xFFB0B0B0), fontSize: 16),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: Color(0xFF7C4DFF), width: 2),
            ),
          ),
          onSubmitted: (_) => _checkWord(),
        ),
        const SizedBox(height: 16),
        _ActionButton(label: 'Submit', onTap: _checkWord),
      ],
    );
  }

  // ── Pattern Challenge ───────────────────────────────────────────────────────
  Widget _buildPattern() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _showingPattern
              ? 'Watch the pattern...'
              : 'Repeat the pattern! (${_userPattern.length}/${_patternSequence.length})',
          style: GoogleFonts.dmSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B6B8A),
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1,
          ),
          itemCount: 9,
          itemBuilder: (_, i) {
            final isHighlighted = _highlightedIndex == i;
            final isUserSelected = _userPattern.contains(i);
            return GestureDetector(
              onTap: () => _tapPattern(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? const Color(0xFF7C4DFF)
                      : isUserSelected
                          ? const Color(0xFF7C4DFF).withOpacity(0.3)
                          : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: isHighlighted
                          ? const Color(0xFF7C4DFF).withOpacity(0.5)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: isHighlighted ? 16 : 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.circle,
                    size: 20,
                    color: isHighlighted
                        ? Colors.white
                        : isUserSelected
                            ? const Color(0xFF7C4DFF)
                            : const Color(0xFFE0E0E0),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 20),
        if (!_showingPattern)
          TextButton.icon(
            onPressed: () {
              _userPattern.clear();
              _playPattern();
            },
            icon: const Icon(Icons.replay_rounded,
                color: Color(0xFF7C4DFF)),
            label: Text(
              'Replay pattern',
              style: GoogleFonts.dmSans(
                  color: const Color(0xFF7C4DFF),
                  fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ActionButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7C4DFF), Color(0xFFAA80FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiffBadge extends StatelessWidget {
  final Difficulty difficulty;
  const _DiffBadge({required this.difficulty});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (difficulty) {
      Difficulty.easy => ('Easy', const Color(0xFF4CAF50)),
      Difficulty.medium => ('Medium', const Color(0xFFFF9800)),
      Difficulty.hard => ('Hard', const Color(0xFFE53935)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
