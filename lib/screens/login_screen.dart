import 'package:flutter/material.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.authProvider});

  final AuthProvider authProvider;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;

    final ok = _isSignUp
        ? await widget.authProvider.signUp(email, password)
        : await widget.authProvider.signIn(email, password);

    if (!mounted) return;
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.authProvider.error ?? '인증 실패')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_isSignUp ? '회원가입/로그인 성공' : '로그인 성공')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('5분 홈트 루틴')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('로그인/회원가입', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Supabase Auth 이메일 로그인 + 회원가입을 지원합니다.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            key: const Key('emailField'),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(labelText: '이메일'),
          ),
          const SizedBox(height: 8),
          TextField(
            key: const Key('passwordField'),
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(labelText: '비밀번호'),
          ),
          const SizedBox(height: 10),
          FilledButton(
            key: const Key('authSubmitButton'),
            onPressed: widget.authProvider.loading ? null : _submit,
            child: Text(_isSignUp ? '회원가입 후 로그인' : '로그인'),
          ),
          TextButton(
            onPressed: () => setState(() => _isSignUp = !_isSignUp),
            child: Text(_isSignUp ? '이미 계정이 있으신가요? 로그인' : '계정이 없으신가요? 회원가입'),
          ),
          if (widget.authProvider.loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
