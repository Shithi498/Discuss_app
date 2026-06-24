import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';
import '../services/odoo_discuss_service.dart';
import 'home_page.dart';
import 'inbox_page.dart';




class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late final OdooDiscussService service;
  bool _rememberMe = false;
  bool _autoLoggingIn = true;
  bool _didNavigate = false;

  @override
  void initState() {
    super.initState();
    _tryAutoLogin();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _tryAutoLogin() async {
    try {
      final auth = context.read<AuthProvider>();

     final ok = await auth.tryAutoLogin(db: 'discuss_helpdesk', baseUrl: 'https://demo.kendroo.com');
    // final ok = await auth.tryAutoLogin(db: 'discuss_db', baseUrl: 'http://localhost:8017');

      if (!mounted) return;

      if (ok) {
        _didNavigate = true;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) =>  HomePage()),
        );
      }
    } catch (_) {
    } finally {
      if (mounted && !_didNavigate) {
        setState(() => _autoLoggingIn = false);
      }
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();

    await auth.login(
      db: 'discuss_helpdesk',
      login: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.trim(),
    );

    if (!mounted) return;

    if (auth.isLoggedIn && auth.error == null) {
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(builder: (_) =>  HomePage()),
       );
      print("Login Successful");
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    const bgBlue = Color(0xFF1F6FC1);
    const orangeGradient = Color(0xFFF45A1D);

    if (_autoLoggingIn) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgBlue,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = MediaQuery.of(context).size.width;
            final h = constraints.maxHeight;

            final cardWidth = math.min(w * 0.86, 380.0);
            final cardPadding = (w * 0.045).clamp(14.0, 20.0);
            final headerHeight = (h * 0.20).clamp(95.0, 140.0);
            final logoSize = (headerHeight * 0.70).clamp(60.0, 100.0);

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: h),
                    child: Center(
                      child: Container(
                        width: cardWidth,
                        padding: EdgeInsets.all(cardPadding),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(22),
                                child: SizedBox(
                                  height: headerHeight,
                                  child: Center(
                                    child: Image.asset(
                                      "assets/assets/images/images.png",
                                      width: logoSize,
                                      height: logoSize,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: (h * 0.02).clamp(8.0, 14.0)),
                              _UnderlinedField(
                                label: 'Email Address',
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) =>
                                (v == null || v.isEmpty) ? 'Enter login/email' : null,
                              ),
                              SizedBox(height: (h * 0.025).clamp(10.0, 16.0)),
                              _UnderlinedField(
                                label: 'Password',
                                controller: _passwordCtrl,
                                obscureText: true,
                                validator: (v) =>
                                (v == null || v.length < 3) ? 'Enter a valid password' : null,
                              ),
                              SizedBox(height: (h * 0.02).clamp(8.0, 12.0)),
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe,
                                    onChanged: (v) =>
                                        setState(() => _rememberMe = v ?? false),
                                    materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  const Text(
                                    'Remember me',
                                    style: TextStyle(fontSize: 13),
                                  ),
                                  const Spacer(),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Forgot Password?',
                                      style: TextStyle(fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                              if (auth.error != null) ...[
                                const SizedBox(height: 6),
                                Text(
                                  auth.error!,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              ],
                              SizedBox(height: (h * 0.02).clamp(8.0, 12.0)),
                              SizedBox(
                                height: (h * 0.07).clamp(46.0, 56.0),
                                child: auth.loading
                                    ? const Center(
                                  child: CircularProgressIndicator(),
                                )
                                    : ElevatedButton(
                                  onPressed: _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: orangeGradient,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    'LOGIN',
                                    style: TextStyle(
                                      letterSpacing: 1.2,
                                      fontWeight: FontWeight.w700,
                                      color: bgBlue,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  top: 8,
                  child: IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _UnderlinedField extends StatelessWidget {
  const _UnderlinedField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withOpacity(0.55),
            fontWeight: FontWeight.w600,
          ),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
            border: const UnderlineInputBorder(),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black.withOpacity(0.15)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFFF4B400), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}





