import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../models/chat_message.dart';
import '../../models/design.dart';

class AIConsultingService {
  static String? _apiKey;

  static Future<void> loadApiKey() async {
    String raw = await rootBundle.loadString('assets/api_key.txt');
    raw = raw
        .replaceAll('\uFEFF', '')
        .replaceAll('\r', '')
        .replaceAll('\n', '')
        .trim();
    _apiKey = raw;
    print("Loaded API KEY: '$_apiKey'");
  }

  static const String _endpoint =
      "https://openrouter.ai/api/v1/chat/completions";
  static const String _model = "tngtech/deepseek-r1t2-chimera:free";

  /// 디자인 + 기존 히스토리 + 새 메시지 → AI 응답 텍스트
  /// 실패해도 예외를 던지지 않고, "에러 안내 문장"을 그대로 리턴한다.
  static Future<String> consult({
    required Design design,
    required List<ChatMessage> history,
    required String userMessage,
  }) async {
    // 최근 10개만 사용해서 토큰 절약
    final trimmedHistory =
    history.length > 10 ? history.sublist(history.length - 10) : history;

    final messages = _buildMessages(
      design: design,
      history: trimmedHistory,
      newUserMessage: userMessage,
    );

    try {
      // 혹시 아직 API 키를 안 읽었다면 여기서 로드
      if (_apiKey == null || _apiKey!.isEmpty) {
        await loadApiKey();
      }

      final response = await http
          .post(
        Uri.parse(_endpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $_apiKey",
          "HTTP-Referer":
          "https://github.com/maesiltea007/MobileProgramming",
          "X-Title": "Epic Design Helper",
        },
        body: jsonEncode({
          "model": _model,
          "messages": messages,
        }),
      )
          .timeout(const Duration(seconds: 30)); // 타임아웃 추가

      // 1) HTTP 상태코드 체크
      if (response.statusCode != 200) {
        debugPrint('🔥 AI HTTP error: ${response.statusCode}');
        debugPrint('🔥 body: ${response.body}');
        return 'I had trouble contacting the design AI. Please try again in a moment.';
      }

      // 2) JSON 파싱
      final data = jsonDecode(response.body);
      final choices = data['choices'];
      if (choices is! List || choices.isEmpty) {
        debugPrint('🔥 Unexpected AI response: $data');
        return 'The AI returned an unexpected response.';
      }

      final message = choices[0]['message'];
      final content = message?['content'];
      if (content is! String) {
        debugPrint('🔥 Unexpected AI message format: $message');
        return 'The AI response format was invalid.';
      }

      return content;
    } on SocketException catch (e, st) {
      // 네트워크 끊김 / DNS 문제 등
      debugPrint('🔥 Network error while calling AI: $e');
      debugPrint('🔥 stack: $st');
      return 'It seems your internet connection is down. Please check your network and try again.';
    } on TimeoutException catch (e, st) {
      // 타임아웃
      debugPrint('🔥 Timeout while calling AI API: $e');
      debugPrint('🔥 stack: $st');
      return 'The AI server is taking too long to respond. Please try again in a moment.';
    } catch (e, st) {
      // 그 밖의 모든 예외
      debugPrint('🔥 AIConsultingService.consult error: $e');
      debugPrint('🔥 stack: $st');
      return 'A technical error occurred while generating feedback. Please try again.';
    }
  }

  // system + history + userMessage
  static List<Map<String, dynamic>> _buildMessages({
    required Design design,
    required List<ChatMessage> history,
    required String newUserMessage,
  }) {
    final List<Map<String, dynamic>> msgs = [];

    // 1. ChatBot settings
    msgs.add({
      "role": "system",
      "content": """
You are an AI design consultant.

Current design:
- Background: ${_colorToHex(design.backgroundColor)}
- Font color: ${_colorToHex(design.fontColor)}
- Font family: ${design.fontFamily}
- Text: "${design.text}"

- Do NOT describe your reasoning process.
- Do NOT say things like "first I will analyze" or "the user probably wants".
- Just give direct, concise feedback to the user.
- Use at most 3 short paragraphs.
""",
    });

    // 2. past chatting history
    for (final msg in history) {
      msgs.add({
        "role": msg.isUser ? "user" : "assistant",
        "content": msg.text,
      });
    }

    // 3. given message
    msgs.add({
      "role": "user",
      "content": newUserMessage,
    });

    return msgs;
  }

  static String _colorToHex(Color color) {
    final v = color.value.toRadixString(16).padLeft(8, '0');
    return '#${v.substring(2).toUpperCase()}';
  }
}