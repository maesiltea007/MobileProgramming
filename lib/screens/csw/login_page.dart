import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../state/app_state.dart';
import 'dart:async';

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

  bool _isLoginDisabled = false;
  Timer? _disableTimer;
  static const int _disableDurationSeconds = 10;

  @override
  void initState() {
    super.initState();
    // 입력이 시작되면 오류 메시지 초기화
    _emailController.addListener(_resetAsyncErrors);
    _passwordController.addListener(_resetAsyncErrors);
  }

  @override
  void dispose() {
    _emailController.removeListener(_resetAsyncErrors);
    _passwordController.removeListener(_resetAsyncErrors);
    _emailController.dispose();
    _passwordController.dispose();
    _disableTimer?.cancel();
    super.dispose();
  }

  // 입력이 시작되면 오류 상태 초기화
  void _resetAsyncErrors() {
    if (_emailErrorText != null || _passwordErrorText != null) {
      setState(() {
        _emailErrorText = null;
        _passwordErrorText = null;
      });
    }
  }


  // Firebase 로그인 로직
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
            SnackBar(content: Text('Welcome, ${nickname}!')),
          );
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        setState(() {
          _emailErrorText = 'Invalid email address.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _passwordErrorText = 'Incorrect password.';
        });
      } else if (e.code == 'invalid-credential') {
        setState(() {
          _passwordErrorText = 'Incorrect email or password.';
        });
      } else if (e.code == 'network-request-failed') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Network connection failed. Please try again.')),
          );
        }
      } else if (e.code == 'too-many-requests') {
        if (mounted) {
          setState(() {
            _isLoginDisabled = true;
          });

          _disableTimer?.cancel();
          _disableTimer = Timer(
            const Duration(seconds: _disableDurationSeconds),
                () {
              if (mounted) {
                setState(() {
                  _isLoginDisabled = false;
                });
              }
            },
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Too many requests. Try again later.')),
          );
        }
      }
      else {
        String errorMessage = 'Login Failed: ${e.message}';
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
          const SnackBar(content: Text('An unknown error has occurred.')),
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
                    'Color Snap',
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
                      prefixIcon: const Icon(Icons.email, color: Colors.grey),
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
                        return 'Please enter your email.';
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
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
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
                        return 'Please enter your password.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 3. 로그인 버튼
                  Align(
                    alignment: Alignment.center,
                    child: TextButton(
                      onPressed: _isLoginDisabled ? null : _login,
                      child: Text(
                        'Log in',
                        style: TextStyle(
                          fontSize: 16,
                          color: _isLoginDisabled ? Colors.grey : _primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),

                  // 4. 회원가입
                  const Text(
                    "Don't have an account?",
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
                      'Sign up',
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