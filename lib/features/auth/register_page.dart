import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _selectedRole = ''; // 'student' atau 'teacher'
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty ||
        _selectedRole.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi!')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password tidak cocok!')));
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Pendaftaran berhasil!')));
    Navigator.pushReplacementNamed(context, '/teacher-dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Register title
                const SizedBox(height: 32),
                // Logo section
                _buildLogoSection(),
                const SizedBox(height: 32),
                // Form card
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF65A6F1),
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // Nama Lengkap
                      _buildTextField(
                        controller: _nameController,
                        hintText: 'Nama Lengkap',
                      ),
                      const SizedBox(height: 16),
                      // Username
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Username',
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: !_showPassword,
                        isPassword: true,
                        showPassword: _showPassword,
                        onPasswordToggle: () {
                          setState(() {
                            _showPassword = !_showPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Konfirmasi Password
                      _buildTextField(
                        controller: _confirmPasswordController,
                        hintText: 'Konfirmasi Password',
                        obscureText: !_showConfirmPassword,
                        isPassword: true,
                        showPassword: _showConfirmPassword,
                        onPasswordToggle: () {
                          setState(() {
                            _showConfirmPassword = !_showConfirmPassword;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      // Pilih Role
                      Text(
                        'Pilih Role',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = 'teacher';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'teacher'
                                      ? const Color(0xFF4CAF50)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    'Guru',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'teacher'
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRole = 'student';
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: _selectedRole == 'student'
                                      ? const Color(0xFFFFC107)
                                      : Colors.grey.shade300,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    'Murid',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: _selectedRole == 'student'
                                          ? Colors.white
                                          : Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Sudah punya akun
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF65A6F1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Sign up button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF65A6F1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _handleRegister,
                    child: const Text(
                      'Sign up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFE8F1FC),
          ),
          child: Center(
            child: Image.asset(
              'assets/images/person.png',
              fit: BoxFit.contain,
              width: 80,
              height: 80,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Image.asset(
          'assets/images/imrithys_rhymes.png',
          width: 150,
          height: 60,
          fit: BoxFit.contain,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onPasswordToggle,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: const Color(0xFF65A6F1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  showPassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
                onPressed: onPasswordToggle,
              )
            : null,
      ),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
    );
  }
}
