import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';

class QuizSessionPage extends StatefulWidget {
  final String studentId;
  final String babKey;
  final String babLabel;
  final int babNumber;

  const QuizSessionPage({
    super.key,
    required this.studentId,
    required this.babKey,
    required this.babLabel,
    required this.babNumber,
  });

  @override
  State<QuizSessionPage> createState() => _QuizSessionPageState();
}

class _QuizSessionPageState extends State<QuizSessionPage> {
  List<Map<String, dynamic>> _questions = [];
  bool _loading = true;
  int _currentIndex = 0;
  String? _selectedAnswer;
  bool _answered = false;
  int _correctCount = 0;
  bool _quizDone = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    final questions = await SupabaseService().getQuizQuestions(widget.babKey);
    if (mounted) {
      setState(() {
        _questions = questions;
        _loading = false;
      });
    }
  }

  void _selectAnswer(String answer) {
    if (_answered) return;
    final correct = _questions[_currentIndex]['correct_answer'] as String;
    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (answer == correct) _correctCount++;
    });

    // Auto-next setelah 1.2 detik
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _answered = false;
        });
      } else {
        setState(() => _quizDone = true);
        _saveResult();
      }
    });
  }

  Future<void> _saveResult() async {
    setState(() => _saving = true);
    final score = (_correctCount * 10);
    final error = await SupabaseService().saveQuizResult(
      studentId: widget.studentId,
      babKey: widget.babKey,
      babLabel: widget.babLabel,
      babNumber: widget.babNumber,
      score: score,
      correctCount: _correctCount,
    );

    if (mounted) {
      setState(() => _saving = false);
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan hasil: $error'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 8),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return _buildLoading();
    if (_questions.isEmpty) return _buildNoQuestions();
    if (_quizDone) return _buildResult();
    return _buildQuestion();
  }

  // ── LOADING ───────────────────────────────────────────────
  Widget _buildLoading() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFF66893)),
            const SizedBox(height: 16),
            Text(
              'Memuat soal ${widget.babLabel}...',
              style: const TextStyle(color: Color(0xFF697B91)),
            ),
          ],
        ),
      ),
    );
  }

  // ── NO QUESTIONS ──────────────────────────────────────────
  Widget _buildNoQuestions() {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF2D2D2D),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('😔', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text(
              'Soal belum tersedia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Soal untuk ${widget.babLabel}\nbelum dimasukkan',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF697B91)),
            ),
          ],
        ),
      ),
    );
  }

  // ── SOAL ─────────────────────────────────────────────────
  Widget _buildQuestion() {
    final q = _questions[_currentIndex];
    final correct = q['correct_answer'] as String;
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Header: back + progress text
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _showQuitDialog(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF2D2D2D),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.babLabel,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF697B91),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFF66893),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_currentIndex + 1}/${_questions.length}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFF66893),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Kartu pertanyaan
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFF66893),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFF66893).withValues(alpha: 0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  q['question_text'] as String,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Pilihan jawaban
              Expanded(
                child: ListView(
                  children: ['a', 'b', 'c', 'd'].map((opt) {
                    final text = q['option_$opt'] as String;
                    return _buildOption(opt, text, correct);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String opt, String text, String correct) {
    Color bgColor = Colors.white;
    Color borderColor = Colors.grey.shade200;
    Color textColor = const Color(0xFF2D2D2D);
    IconData? icon;

    if (_answered && _selectedAnswer == opt) {
      if (opt == correct) {
        bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.12);
        borderColor = const Color(0xFF4CAF50);
        textColor = const Color(0xFF2E7D32);
        icon = Icons.check_circle_rounded;
      } else {
        bgColor = const Color(0xFFEF4444).withValues(alpha: 0.10);
        borderColor = const Color(0xFFEF4444);
        textColor = const Color(0xFFB71C1C);
        icon = Icons.cancel_rounded;
      }
    } else if (_answered && opt == correct) {
      bgColor = const Color(0xFF4CAF50).withValues(alpha: 0.08);
      borderColor = const Color(0xFF4CAF50);
      textColor = const Color(0xFF2E7D32);
      icon = Icons.check_circle_rounded;
    }

    return GestureDetector(
      onTap: () => _selectAnswer(opt),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _answered && (opt == correct || opt == _selectedAnswer)
                    ? Colors.transparent
                    : const Color(0xFFF66893).withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? Icon(
                      icon,
                      color: opt == correct
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFEF4444),
                      size: 22,
                    )
                  : Center(
                      child: Text(
                        opt.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFF66893),
                          fontSize: 14,
                        ),
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 14,
                  color: textColor,
                  fontWeight: _answered && opt == correct
                      ? FontWeight.bold
                      : FontWeight.normal,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── HASIL ─────────────────────────────────────────────────
  Widget _buildResult() {
    final score = _correctCount * 10;
    final passed = score >= 80;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              // Badge lulus/belum
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: passed
                      ? const Color(0xFF4CAF50).withValues(alpha: 0.08)
                      : const Color(0xFFF66893).withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(
                    color: passed
                        ? const Color(0xFF4CAF50).withValues(alpha: 0.3)
                        : const Color(0xFFF66893).withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      passed ? '🎉' : '💪',
                      style: const TextStyle(fontSize: 64),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      passed ? 'Selamat! Kamu Lulus!' : 'Belum Lulus',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: passed
                            ? const Color(0xFF2E7D32)
                            : const Color(0xFFF66893),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.babLabel,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF697B91),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Skor besar
                    Text(
                      '$score',
                      style: TextStyle(
                        fontSize: 72,
                        fontWeight: FontWeight.bold,
                        color: passed
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF66893),
                      ),
                    ),
                    Text(
                      '$_correctCount dari ${_questions.length} soal benar',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF697B91),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: passed
                            ? const Color(0xFF4CAF50)
                            : const Color(0xFFF66893),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Text(
                        passed
                            ? '✓ Bab ini sudah terkunci (lolos)'
                            : 'Kamu bisa coba lagi',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // Tombol selesai
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving
                      ? null
                      : () => Navigator.pop(context, true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF66893),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFFF66893).withValues(alpha: 0.4),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Selesai',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _showQuitDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar dari kuis?'),
        content: const Text(
          'Progress kuis ini tidak akan disimpan jika kamu keluar sekarang.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Lanjutkan',
              style: TextStyle(color: Color(0xFFF66893)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Keluar',
              style: TextStyle(color: Color(0xFF697B91)),
            ),
          ),
        ],
      ),
    );
  }
}
