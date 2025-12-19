import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

// 👇 [핵심 1] 애니메이션을 쓰려면 'with SingleTickerProviderStateMixin'을 꼭 붙여야 합니다!
class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  bool _isLoading = false;

  // 👇 [핵심 2] 애니메이션을 제어할 변수들 선언
  late AnimationController _animationController;
  late Animation<Offset> _hoverAnimation;

  @override
  void initState() {
    super.initState();

    // 👇 [핵심 3] 애니메이션 설정 (2초 간격으로 위아래 반복)
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // 속도 조절: 숫자가 클수록 느려짐
      vsync: this,
    )..repeat(reverse: true); // reverse: true -> 위로 갔다가 다시 아래로 내려옴 (무한 반복)

    _hoverAnimation =
        Tween<Offset>(
          begin: Offset.zero, // 시작 위치 (제자리)
          end: const Offset(0, -0.15), // 끝 위치 (위로 살짝 이동, 0.15만큼)
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeInOut, // 부드럽게 출발하고 멈추는 곡선 효과
          ),
        );
  }

  @override
  void dispose() {
    // 👇 [중요] 화면이 꺼질 때 애니메이션 기계도 같이 꺼줘야 메모리가 안 샙니다.
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      if (_isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
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
              // 👇 [핵심 4] UFO 이미지를 SlideTransition으로 감싸서 움직이게 만듦
              SlideTransition(
                position: _hoverAnimation,
                child: Image.asset(
                  'assets/icon/ufo.png',
                  width: 100, // 조금 더 잘 보이게 크기를 80 -> 100으로 키웠습니다!
                  height: 100,
                  fit: BoxFit.contain,
                ),
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
