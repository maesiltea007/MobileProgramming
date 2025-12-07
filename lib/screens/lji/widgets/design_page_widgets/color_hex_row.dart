import 'package:flutter/material.dart';

class ColorHexRow extends StatelessWidget {
  final String label;
  final Color color;
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCircleTap;

  const ColorHexRow({
    super.key,
    required this.label,
    required this.color,
    required this.controller,
    required this.onSubmitted,
    required this.onCircleTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onCircleTap,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              border: Border.all(color: Colors.black, width: 2),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              TextField(
                controller: controller,
                maxLength: 7,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  counterText: '',
                  contentPadding: EdgeInsets.only(top: 2),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black54),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(width: 1.2, color: Colors.black),
                  ),
                ),
                onSubmitted: onSubmitted,
              ),
            ],
          ),
        ),
      ],
    );
  }
}