import 'package:flutter/material.dart';
import '../../models/class_model.dart';
import '../../services/auth_service.dart';

class TeacherProfilePage extends StatelessWidget {
  final String teacherName;
  final String teacherGender;
  final ClassModel? classModel;
  final int totalStudents;
  final VoidCallback onLogout;

  const TeacherProfilePage({
    super.key,
    required this.teacherName,
    required this.teacherGender,
    required this.classModel,
    required this.totalStudents,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final email = user?.email ?? '-';
    final username = user?.username ?? '-';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Profile Header Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFF65A6F1),
            borderRadius: BorderRadius.circular(40),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.white, width: 4),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                    ),
                  ],
                  image: DecorationImage(
                    image: AssetImage(
                      teacherGender == 'laki-laki'
                          ? 'assets/images/laki-laki.png'
                          : teacherGender == 'perempuan'
                          ? 'assets/images/perempuan.png'
                          : 'assets/images/person.png',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                teacherName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                teacherGender == 'laki-laki'
                    ? 'Ustadz (Guru)'
                    : 'Ustadzah (Guru)',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Personal Info Card
        _buildInfoCard(
          title: 'Informasi Akun',
          items: [
            _buildInfoRow(Icons.email_outlined, 'Email', email),
            _buildInfoRow(Icons.person_outline, 'Username', '@$username'),
            _buildInfoRow(
              Icons.transgender_outlined,
              'Jenis Kelamin',
              teacherGender == 'laki-laki'
                  ? 'Laki-laki'
                  : teacherGender == 'perempuan'
                  ? 'Perempuan'
                  : '-',
            ),
            _buildInfoRow(
              Icons.calendar_today_outlined,
              'Tanggal Bergabung',
              _formatDate(user?.createdAt),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Class Info Card
        _buildInfoCard(
          title: 'Informasi Kelas',
          items: [
            _buildInfoRow(
              Icons.class_outlined,
              'Nama Kelas',
              classModel?.name ?? 'Belum membuat kelas',
            ),
            _buildInfoRow(
              Icons.vpn_key_outlined,
              'Kode Kelas',
              classModel?.code ?? '------',
              isCode: true,
            ),
            _buildInfoRow(
              Icons.people_outline,
              'Total Murid',
              '$totalStudents Murid',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Logout Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onLogout,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
                SizedBox(width: 8),
                Text(
                  'Keluar dari Akun',
                  style: TextStyle(
                    color: Color(0xFFEF4444),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 140),
      ],
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> items}) {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 43, 113, 194),
            ),
          ),
          const SizedBox(height: 4),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String label,
    String value, {
    bool isCode = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF65A6F1), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isCode
                        ? const Color(0xFFFFA231)
                        : const Color(0xFF2D2D2D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return "${date.day} ${months[date.month - 1]} ${date.year}";
  }
}
