import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true; // 로그인 모드인지 회원가입 모드인지 확인
  bool _isLoading = false;

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        // 로그인 시도
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        // 회원가입 시도
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("회원가입 성공! 로그인되었습니다.")));
        }
      }
    } on FirebaseAuthException catch (e) {
      String message = "오류가 발생했습니다.";

      if (e.code == 'user-not-found') {
        message = "존재하지 않는 계정입니다.";
      } else if (e.code == 'wrong-password') {
        message = "비밀번호가 틀렸습니다.";
      } else if (e.code == 'email-already-in-use') {
        message = "이미 사용 중인 이메일입니다.";
      } else if (e.code == 'weak-password') {
        message = "비밀번호는 6자리 이상이어야 합니다.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🛸 [여기!] 자물쇠 아이콘을 UFO 이미지로 교체했습니다.
              Image.asset(
                'assets/icon/ufo.png', // 👈 파일명을 확인해주세요! (ufo.png)
                width: 80, // 크기 조절 (기존 아이콘과 비슷하게 80으로 설정)
                height: 80,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 16),
              Text(
                _isLogin ? " GET SET " : "회원가입",
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC084FC),
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: "이메일",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "비밀번호",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              if (_isLoading)
                const CircularProgressIndicator(color: Color(0xFFC084FC))
              else
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC084FC),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(_isLogin ? "로그인" : "회원가입"),
                    ),
                    TextButton(
                      onPressed: () => setState(() => _isLogin = !_isLogin),
                      child: Text(
                        _isLogin ? "계정이 없으신가요? 회원가입" : "이미 계정이 있으신가요? 로그인",
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
