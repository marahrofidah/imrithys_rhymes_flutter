import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String _selectedRole = ''; // 'student' atau 'teacher'
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _isLoading = false;

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

  void _handleRegister() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = '$username @imrithys.local'; // Generate email dari username
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    // Validasi
    if (name.isEmpty ||
        username.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        _selectedRole.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Semua field harus diisi!')));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Password tidak cocok!')));
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final supabase = SupabaseService();

      // Check apakah username sudah ada
      final usernameExists = await supabase.isUsernameExists(username);
      if (usernameExists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Username sudah digunakan')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }

      // Register user
      final newUser = await supabase.register(
        email,
        username,
        password,
        _selectedRole,
        fullName: name,
      );

      if (!mounted) return;

      if (newUser == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal membuat akun')));
        setState(() => _isLoading = false);
        return;
      }

      // Auto login setelah register
      final authService = AuthService();
      final loggedIn = await authService.login(username, password);

      if (!mounted) return;

      if (loggedIn != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedRole == 'teacher'
                  ? 'Pendaftaran guru berhasil! Selamat datang'
                  : 'Pendaftaran murid berhasil! Selamat datang',
            ),
          ),
        );

        // Navigate ke login page (mana nanti akan deteksi role)
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Gagal login otomatis')));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
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
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      // Username
                      _buildTextField(
                        controller: _usernameController,
                        hintText: 'Username',
                        enabled: !_isLoading,
                      ),
                      const SizedBox(height: 16),
                      // Password
                      _buildTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        obscureText: !_showPassword,
                        isPassword: true,
                        showPassword: _showPassword,
                        enabled: !_isLoading,
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
                        enabled: !_isLoading,
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
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedRole = 'teacher';
                                      });
                                    },
                              child: Opacity(
                                opacity: _isLoading ? 0.6 : 1.0,
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
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedRole = 'student';
                                      });
                                    },
                              child: Opacity(
                                opacity: _isLoading ? 0.6 : 1.0,
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
                      onTap: _isLoading
                          ? null
                          : () {
                              Navigator.pushReplacementNamed(context, '/login');
                            },
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isLoading
                              ? Colors.grey.shade400
                              : const Color(0xFF65A6F1),
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
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
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
        SizedBox(
          width: 100,
          height: 100,
          child: Center(
            child: Image.asset(
              'assets/images/person.png',
              fit: BoxFit.contain,
              width: 100,
              height: 100,
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
    bool enabled = true,
    VoidCallback? onPasswordToggle,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
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
                onPressed: enabled ? onPasswordToggle : null,
              )
            : null,
      ),
      style: const TextStyle(fontSize: 13, color: Colors.black87),
    );
  }
}
