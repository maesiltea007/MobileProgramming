import 'package:flutter/material.dart';
import '../../models/design.dart';

class DesignPage extends StatelessWidget {
  final Design design;
  const DesignPage({super.key, required this.design});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Design Page")),
      body: Center(
        child: Text(
          // DesignPage로 design 데이터가 잘 넘어왔는지 테스트 출력
          'text: ${design.text}\n'
              'font: ${design.fontFamily}\n'
              'fontColor: ${design.fontColor}\n'
              'background: ${design.backgroundColor}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}