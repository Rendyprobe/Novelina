import 'package:flutter/material.dart';
import '../../../core/widgets/night_sky_background.dart';
import '../../../core/widgets/gradient_button.dart';
import '../../../routes/routes.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(text: 'Hasan@gmail.com');
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _hide1 = true;
  bool _hide2 = true;
  bool _processing = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _onSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _processing = true);
    
    // Simulate database operations
    await Future.delayed(const Duration(milliseconds: 900));
    

    if (mounted) {
      setState(() => _processing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account created successfully! Please login.')),
      );
      Navigator.popAndPushNamed(context, AppRoutes.login);
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
                    Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: size.width < 380 ? 34 : 40,
                        fontWeight: FontWeight.w800,
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
                    const SizedBox(height: 24),
                    Text(
                      'buat akun anda untuk menyimpan perkembangan',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                    ),
                    const SizedBox(height: 18),

                    Form(
                      key: _formKey,
                      child: Column(children: [
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
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
                          controller: _pass,
                          obscureText: _hide1,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _hide1 = !_hide1),
                              icon: Icon(_hide1 ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return 'Password wajib diisi';
                            if ((v ?? '').length < 6) return 'Minimal 6 karakter';
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _confirm,
                          obscureText: _hide2,
                          decoration: InputDecoration(
                            labelText: 'Confirm Password',
                            prefixIcon: const Icon(Icons.lock_reset_outlined),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _hide2 = !_hide2),
                              icon: Icon(_hide2 ? Icons.visibility_off : Icons.visibility),
                            ),
                          ),
                          validator: (v) {
                            if ((v ?? '').isEmpty) return 'Ulangi password';
                            if (v != _pass.text) return 'Password tidak sama';
                            return null;
                          },
                        ),
                      ]),
                    ),

                    const SizedBox(height: 18),
                    GradientButton(
                      onPressed: _processing ? null : _onSignUp,
                      height: 54,
                      borderRadius: 18,
                      child: _processing
                          ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4))
                          : const Text('SIGN UP', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 1.1)),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                      child: const Text('Sudah Punya Akun? Login'),
                    ),
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