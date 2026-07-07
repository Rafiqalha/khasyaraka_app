import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scout_os_app/features/auth/logic/auth_controller.dart';
import 'package:scout_os_app/core/widgets/duo_button.dart';
import 'login_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _gudepController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _gudepController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty ||
        _usernameController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama, username, dan password wajib diisi.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final authController = context.read<AuthController>();
    final success = await authController.register(
      name: _nameController.text,
      username: _usernameController.text,
      password: _passwordController.text,
      gugusDepan: _gudepController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authController.errorMessage ?? 'Gagal register'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Consumer<AuthController>(
        builder: (context, authController, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 12),
                Text(
                  'Buat Akun Baru',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00695C),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Scout 4.0 siap menemani petualanganmu.',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.blueGrey.shade600,
                  ),
                ),
                const SizedBox(height: 24),
                if (authController.errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFCDD2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE57373)),
                    ),
                    child: Text(
                      authController.errorMessage!,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFB71C1C),
                      ),
                    ),
                  ),
                if (authController.errorMessage != null)
                  const SizedBox(height: 16),
                _buildDuoInput(
                  controller: _nameController,
                  enabled: !authController.isLoading,
                  labelText: 'Nama Lengkap',
                  icon: Icons.badge_rounded,
                ),
                const SizedBox(height: 16),
                _buildDuoInput(
                  controller: _usernameController,
                  enabled: !authController.isLoading,
                  labelText: 'Username',
                  icon: Icons.person_rounded,
                ),
                const SizedBox(height: 16),
                _buildDuoInput(
                  controller: _passwordController,
                  enabled: !authController.isLoading,
                  labelText: 'Password',
                  icon: Icons.lock_rounded,
                  isPassword: true,
                  obscureText: _obscurePassword,
                  onTogglePassword: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
                const SizedBox(height: 16),
                _buildDuoInput(
                  controller: _gudepController,
                  enabled: !authController.isLoading,
                  labelText: 'Gugus Depan (Opsional)',
                  icon: Icons.flag_rounded,
                ),
                const SizedBox(height: 24),
                if (authController.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  DuoButton(
                    text: 'DAFTAR SEKARANG',
                    variant: DuoButtonVariant.green,
                    onPressed: _handleRegister,
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: GoogleFonts.poppins(
                        color: Colors.blueGrey.shade600,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Masuk',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF00695C),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDuoInput({
    required TextEditingController controller,
    required bool enabled,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool? obscureText,
    VoidCallback? onTogglePassword,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0xFFE5E5E5),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        enabled: enabled,
        obscureText: obscureText ?? false,
        style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: GoogleFonts.nunito(
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w700,
          ),
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    (obscureText ?? false)
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    color: Colors.grey.shade500,
                  ),
                  onPressed: onTogglePassword,
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
