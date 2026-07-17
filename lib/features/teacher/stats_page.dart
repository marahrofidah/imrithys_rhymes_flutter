import 'package:flutter/material.dart';

class TeacherStatsPage extends StatelessWidget {
  final List<Map<String, dynamic>> students;
  final Map<String, Map<String, dynamic>> studentProgressMap;

  const TeacherStatsPage({
    super.key,
    required this.students,
    required this.studentProgressMap,
  });

  @override
  Widget build(BuildContext context) {
    final totalStudents = students.length;
    double avgQuizProgress = 0.0;
    int maxStreak = 0;

    if (totalStudents > 0) {
      int totalQuizPassed = 0;
      for (final s in students) {
        final id = s['id'] as String? ?? '';
        final progress = studentProgressMap[id];
        totalQuizPassed += progress?['quiz_passed'] as int? ?? 0;
        final streak = progress?['streak'] as int? ?? 0;
        if (streak > maxStreak) maxStreak = streak;
      }
      avgQuizProgress = totalQuizPassed / totalStudents;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Stats Overview Cards
        Row(
          children: [
            Expanded(
              child: _buildDetailStatCard(
                icon: Icons.assignment_turned_in_outlined,
                value: avgQuizProgress.toStringAsFixed(1),
                label: 'Rata-rata Kuis',
                subtitle: 'dari 33 kuis',
                color: const Color(0xFF65A6F1),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildDetailStatCard(
                icon: Icons.local_fire_department_outlined,
                value: '$maxStreak',
                label: 'Streak Tertinggi',
                subtitle: 'hari aktif berturut',
                color: const Color(0xFFFFA231),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Class Progress Section
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Perkembangan Kuis Kelas',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 43, 113, 194),
                ),
              ),
              const SizedBox(height: 4),
              students.isEmpty
                  ? const Center(
                      child: Text(
                        'Belum ada murid di kelas ini.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : Column(
                      children: List.generate(students.length, (index) {
                        final student = students[index];
                        final id = student['id'] as String? ?? '';
                        final name =
                            student['full_name'] as String? ??
                            student['username'] as String? ??
                            'Murid';
                        final progress = studentProgressMap[id];
                        final quizPassed =
                            progress?['quiz_passed'] as int? ?? 0;
                        final percent = quizPassed / 33.0;

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2D2D2D),
                                    ),
                                  ),
                                  Text(
                                    '$quizPassed/33 kuis (${(percent * 100).toStringAsFixed(0)}%)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percent,
                                  minHeight: 10,
                                  backgroundColor: Colors.grey.shade100,
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                        Color(0xFF65A6F1),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
            ],
          ),
        ),
        const SizedBox(height: 140),
      ],
    );
  }

  Widget _buildDetailStatCard({
    required IconData icon,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D2D2D),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }
}
