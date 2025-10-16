import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '명예의 전당 앱',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MainNavigator(),
      routes: {
        '/mypage': (context) => const MyPage(),
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/colorpicker': (context) => const ColorPickerPage(),
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RankPage(),
    ScanPage(),
    LibraryPage(),
    ConsultingPage(),
  ];

  final List<String> _titles = [
    '홈',
    '랭크',
    '스캔',
    '라이브러리',
    '컨설팅',
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/mypage'); // → My Page로 이동
            },
          ),
        ],
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '랭크'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: '스캔'),
          BottomNavigationBarItem(icon: Icon(Icons.library_books), label: '라이브러리'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: '컨설팅'),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('홈 (명예의 전당)'));
}

class RankPage extends StatelessWidget {
  const RankPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('랭크 페이지'));
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('라이브러리 페이지'));
}

class ConsultingPage extends StatelessWidget {
  const ConsultingPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const Center(child: Text('컨설팅 페이지'));
}

// ---------------------------
// 스캔 → 컬러픽커 연결
// ---------------------------
class ScanPage extends StatelessWidget {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        icon: const Icon(Icons.camera_alt),
        label: const Text('카메라 찍기'),
        onPressed: () {
          Navigator.pushNamed(context, '/colorpicker'); // → Color Picker 이동
        },
      ),
    );
  }
}

class ColorPickerPage extends StatelessWidget {
  const ColorPickerPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Color Picker')),
    body: const Center(child: Text('색상 선택 페이지')),
  );
}

// ---------------------------
// 마이페이지 → 로그인 → 회원가입 연결
// ---------------------------
class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Page')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('마이페이지'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login'); // → Login
            },
            child: const Text('로그인 하러 가기'),
          ),
        ],
      ),
    ),
  );
}

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Login')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('로그인 페이지'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // 로그인 완료 후 뒤로가기(홈 복귀)
            },
            child: const Text('로그인'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamed(context, '/signup'); // → 회원가입
            },
            child: const Text('회원가입'),
          ),
        ],
      ),
    ),
  );
}

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sign Up')),
    body: const Center(child: Text('회원가입 페이지')),
  );
}
