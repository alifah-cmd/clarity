import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../../utils/app_routes.dart';
import '../../widgets/custom_input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final authRes = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authRes.user != null) {
        await SupabaseService().registerUser(
          fullName: _nameController.text.trim(),
        );
      }

      if (mounted) {
        Get.snackbar(
          'Registrasi Berhasil',
          'Periksa email Anda untuk verifikasi akun.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        Get.offAllNamed(AppRoutes.login);
      }
    } on AuthException catch (e) {
      _showErrorSnackbar('Registrasi Gagal', e.message);
    } catch (e) {
      _showErrorSnackbar('Terjadi Kesalahan', 'Tidak dapat menghubungi server.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackbar(String title, String message) {
    if (!mounted) return;
    Get.snackbar(
      title,
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F2F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.home_outlined, color: Colors.black54),
          onPressed: () => Get.offAllNamed(AppRoutes.welcome), 
       ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/clarity.png', height: 80),
                  const SizedBox(height: 48),
                  _buildNameField(),
                  const SizedBox(height: 20),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 20),
                  _buildConfirmPasswordField(),
                  const SizedBox(height: 40),
                  _buildRegisterButton(),
                  const SizedBox(height: 24),
                  _buildLoginRedirect(),
                  const SizedBox(height: 24),
                  Image.asset('assets/images/bag.png', height: 100),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return CustomInputField(
      controller: _nameController,
      labelText: 'Full Name',
      validator: (val) => val == null || val.isEmpty ? 'Nama wajib diisi' : null,
    );
  }

  Widget _buildEmailField() {
    return CustomInputField(
      controller: _emailController,
      labelText: 'Email',
      keyboardType: TextInputType.emailAddress,
      validator: (val) => val == null || !GetUtils.isEmail(val) ? 'Email tidak valid' : null,
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isPasswordObscured,
      decoration: InputDecoration(
        labelText: 'Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordObscured = !_isPasswordObscured;
            });
          },
        ),
      ),
      validator: (val) => val == null || val.length < 6 ? 'Password minimal 6 karakter' : null,
    );
  }

  Widget _buildConfirmPasswordField() {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: _isConfirmPasswordObscured,
      decoration: InputDecoration(
        labelText: 'Confirm Password',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordObscured ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordObscured = !_isConfirmPasswordObscured;
            });
          },
        ),
      ),
      validator: (val) => val != _passwordController.text ? 'Password tidak cocok' : null,
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _register,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFE57373),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            )
          : const Text(
              'Register',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => Get.toNamed(AppRoutes.login), 
          child: const Text(
            'Login', 
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

