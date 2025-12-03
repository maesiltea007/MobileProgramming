import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../state/app_state.dart';

const Color _primaryColor = Color(0xFF3B2ECC);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _emailErrorText;
  String? _passwordErrorText;

  @override
  void initState() {
    super.initState();
    // 💡 입력이 시작되면 오류 메시지 초기화
    _emailController.addListener(_resetAsyncErrors);
    _passwordController.addListener(_resetAsyncErrors);
  }

  @override
  void dispose() {
    _emailController.removeListener(_resetAsyncErrors);
    _passwordController.removeListener(_resetAsyncErrors);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 💡 입력이 감지되면 비동기 오류 상태를 초기화합니다.
  void _resetAsyncErrors() {
    if (_emailErrorText != null || _passwordErrorText != null) {
      setState(() {
        _emailErrorText = null;
        _passwordErrorText = null;
      });
    }
  }


  // 💡 Firebase 로그인 로직
  void _login() async {
    // 폼 유효성 검사 (동기적 검사)
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 비동기 오류 상태 초기화
    setState(() {
      _emailErrorText = null;
      _passwordErrorText = null;
    });

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text.trim();
    final appState = Provider.of<AppState>(context, listen: false);

    /*
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("로그인 시도 중...")),
      );
    }
     */

    try {
      final userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        final userData = userDoc.data();

        final nickname = userData?['nickname'] ?? 'User';

        appState.login(user.uid, nickname);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${nickname}님 환영합니다!')),
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        setState(() {
          _emailErrorText = '등록되지 않은 이메일이거나 형식이 올바르지 않습니다.';
        });
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        setState(() {
          _passwordErrorText = '비밀번호가 일치하지 않습니다.';
        });
      } else {
        String errorMessage = '로그인 오류: ${e.message}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }

      _formKey.currentState?.validate();

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('알 수 없는 오류가 발생했습니다.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Align(
        alignment: const Alignment(0.0, -0.7),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),

            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Color Master',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                  const SizedBox(height: 80),

                  // 1. 이메일 (ID) 입력 필드
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'Email (id)',
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      errorText: _emailErrorText,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    validator: (value) {
                      if (_emailErrorText != null) return null;
                      if (value == null || value.isEmpty) {
                        return '이메일을 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  // 2. 비밀번호 입력 필드
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      contentPadding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      errorText: _passwordErrorText,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(3)),
                        borderSide: BorderSide(color: Colors.grey, width: 1.0),
                      ),
                    ),
                    validator: (value) {
                      if (_passwordErrorText != null) return null;
                      if (value == null || value.isEmpty) {
                        return '비밀번호를 입력해주세요.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. 로그인 버튼
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _login,
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          color: _primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 4. 회원가입
                  const Text(
                    "don't have an account?",
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'sign up',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}