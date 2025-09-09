import 'package:flutter/material.dart';
import '../../../core/widgets/night_sky_background.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../core/widgets/divider_with_text.dart';
import '../../../routes/routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'Hasan@gmail.com');
  final _password = TextEditingController();
  bool _obscure = true;
  bool _signingIn = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _onSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _signingIn = true);
    
    // Simulate database operations and session management
    await Future.delayed(const Duration(milliseconds: 900));
    
    if (mounted) {
      setState(() => _signingIn = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed in successfully! Redirecting to home...')),
      );
      // Navigate to home screen after successful login
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(children: [
        const NightSkyBackground(),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),


                    // Logo UNESA
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'images/Logo_Unesa.JPG',
                          width: 120,
                          height: 120,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            // Fallback jika logo tidak ditemukan
                            return Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.school,
                                size: 60,
                                color: Colors.white70,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),

                    Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: size.width < 380 ? 34 : 40,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 3,
                      width: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF64B5F6), Color(0xFF4DD0E1)]),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    const SizedBox(height: 28),

                    Form(
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: InputDecoration(
                            labelText: 'Email',
                            hintText: 'nama@email.com',
                            prefixIcon: const Icon(Icons.email_outlined),
                            suffixIcon: Container(
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.mark_email_unread_outlined),
                            ),
                          ),
                          validator: (v) {
                            final value = (v ?? '').trim();
                            if (value.isEmpty) return 'Email wajib diisi';
                            final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
                            if (!ok) return 'Format email tidak valid';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _password,
                          obscureText: _obscure,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                              tooltip: _obscure ? 'Tampilkan' : 'Sembunyikan',
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return 'Password wajib diisi';
                            if ((v ?? '').length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                      ]),
                    ),

                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(content: Text('Fitur lupa sandi (coming soon)'))),
                        child: const Text('Lupa Kata Sandi?'),
                      ),
                    ),

                    const SizedBox(height: 8),
                    GradientButton(
                      onPressed: _signingIn ? null : _onSignIn,
                      height: 54,
                      borderRadius: 18,
                      child: _signingIn
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                          : const Text('SIGN IN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    ),

                    const SizedBox(height: 22),
                    const DividerWithText(text: 'OR'),
                    const SizedBox(height: 16),

                    SizedBox(
                      height: 52,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.g_mobiledata, size: 28),
                        label: const Text('Continue With Google'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 22),
                    Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 6,
                      children: [
                        const Text('Belum punya akun?'),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, AppRoutes.signup),
                          child: const Text('Sign Up', style: TextStyle(fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ]),
    );
  }
}