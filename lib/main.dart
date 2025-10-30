import 'package:flutter/material.dart';

import 'screens/kyh/home_page.dart';
import 'screens/kyh/rank_page.dart';
import 'screens/ljh/scan_page.dart';
import 'screens/ljh/color_picker_page.dart';
import 'screens/lji/library_page.dart';
import 'screens/lji/consulting_page.dart';
import 'screens/csw/login_page.dart';
import 'screens/csw/signup_page.dart';
import 'screens/csw/my_page.dart';
import 'screens/lji/design_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Project App',
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

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, '/mypage'),
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
