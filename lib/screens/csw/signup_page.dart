import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

const Color _primaryColor = Color(0xFF3B2ECC);

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  // 입력값을 관리할 컨트롤러들
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  String? _emailErrorText;
  String? _nicknameErrorText;

  @override
  void initState() {
    super.initState();
    // 💡 입력 변경 시 기존 오류 메시지 초기화
    _emailController.addListener(_resetAsyncErrors);
    _nicknameController.addListener(_resetAsyncErrors);
  }

  @override
  void dispose() {
    _emailController.removeListener(_resetAsyncErrors);
    _nicknameController.removeListener(_resetAsyncErrors);
    _emailController.dispose();
    _nicknameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 💡 입력이 시작되면 오류 메시지 초기화
  void _resetAsyncErrors() {
    if (_emailErrorText != null || _nicknameErrorText != null) {
      _formKey.currentState?.validate();
      setState(() {
        _emailErrorText = null;
        _nicknameErrorText = null;
      });
    }
  }


  // 텍스트 폼 필드
  Widget _buildFormField({
    required String labelText,
    required String hintText,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? asyncErrorText,
  }) {
    final bool hasError = asyncErrorText != null || (validator != null && validator(controller.text) != null);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: (value) {
            if (asyncErrorText != null) return null;
            return validator?.call(value);
          },
          decoration: InputDecoration(
            hintText: hintText,
            errorText: asyncErrorText,

            enabledBorder: OutlineInputBorder(
              borderSide:
              const BorderSide(color: Color(0xFFE0E0E0), width: 1.0),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  color: asyncErrorText != null ? Colors.red : _primaryColor,
                  width: 1.8
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.0),
              borderRadius: BorderRadius.circular(6),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.red, width: 1.8),
              borderRadius: BorderRadius.circular(6),
            ),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // 회원가입 버튼 클릭
  void _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // 💡 오류 상태 초기화
    setState(() {
      _emailErrorText = null;
      _nicknameErrorText = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final nickname = _nicknameController.text.trim();

    /*
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입 처리 중...')),
      );
    }
     */

    final appState = Provider.of<AppState>(context, listen: false);

    try {
      // 1. 닉네임 중복 확인
      final nicknameCheck = await FirebaseFirestore.instance
          .collection('users')
          .where('nickname', isEqualTo: nickname)
          .limit(1)
          .get();

      if (nicknameCheck.docs.isNotEmpty) {
        setState(() {
          _nicknameErrorText = 'This nickname is already in use.';
        });
        return; // 중복이므로 중단
      }

      // 2. 계정 생성
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        // 3. Firestore에 사용자 정보 (닉네임) 저장
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'email': email,
          'nickname': nickname,
          'uid': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // 4. AppState에 로그인 상태 반영 및 페이지 이동
        appState.login(user.uid, nickname);

        if (mounted) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You have successfully signed up and logged in!')),
          );
          Navigator.popUntil(context, ModalRoute.withName('/'));
        }
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Password is too weak. Must be at least 6 characters.')),
          );
        }
      } else if (e.code == 'email-already-in-use') {
        setState(() {
          _emailErrorText = 'This email is already taken.';
        });
      } else {
        String errorMessage = 'Error: ${e.message}';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage)),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An unexpected error occurred.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Sign Up"),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 이메일 입력
                _buildFormField(
                  labelText: "Email",
                  hintText: 'Enter your email for login',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email.';
                    }
                    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'This is not a valid email address.';
                    }
                    return null;
                  },
                  asyncErrorText: _emailErrorText,
                ),

                // 2. 닉네임 입력
                _buildFormField(
                  labelText: "Nickname",
                  hintText: 'Enter your nickname',
                  controller: _nicknameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your nickname';
                    }
                    if (value.length < 2) {
                      return 'Your nickname must be at least 2 characters.';
                    }
                    return null;
                  },
                  asyncErrorText: _nicknameErrorText,
                ),

                // 3. 비밀번호 입력
                _buildFormField(
                  labelText: "Password (6+ characters)",
                  hintText: 'Enter your password',
                  controller: _passwordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password.';
                    }
                    if (value.length < 6) {
                      return 'Your password must be at least 6 characters.';
                    }
                    return null;
                  },
                ),

                // 4. 비밀번호 확인
                _buildFormField(
                  labelText: "Confirm Password",
                  hintText: 'Confirm your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password again.';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                // 5. 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    child: const Text(
                      "Sign Up",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}