import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/design.dart';
import 'design_page.dart';

import '../../models/chat_message.dart';
import '../../state/app_state.dart';
import '../../../services/ai_consulting_services/ai_consulting_service.dart';
import '../../../services/ai_consulting_services/chat_repository.dart';

import 'widgets/consulting_page_widgets/chat_input_bar.dart';
import 'widgets/consulting_page_widgets/message_bubble.dart';
import 'widgets/consulting_page_widgets/typing_indicator_bubble.dart';

class ConsultingPage extends StatefulWidget {
  final Design? design;

  const ConsultingPage({super.key, this.design});

  @override
  State<ConsultingPage> createState() => _ConsultingPageState();
}

class _ConsultingPageState extends State<ConsultingPage> {
  late Design _design;

  late String _userId;
  late String _designId;

  final List<ChatMessage> _messages = [];

  final TextEditingController _inputController = TextEditingController();

  bool _isProcessing = false;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _design =
        widget.design ??
        Design(
          id: 'default-preview',
          text: 'hello',
          fontFamily: 'Roboto',
          fontColor: Colors.white,
          backgroundColor: Colors.black,
          ownerId: 'new',
          createdAt: DateTime.fromMillisecondsSinceEpoch(0),
        );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return; // 👉 CHATS: 여러 번 초기화되지 않도록 가드

    final app = Provider.of<AppState>(context, listen: false);
    _userId = app.currentUserId ?? 'guest';

    // 👉 CHATS: 디자인 id가 없을 수도 있으니 임시 id 생성
    _designId =
        _design.id ??
        'temp-${_userId}-${_design.createdAt?.millisecondsSinceEpoch}';

    // 👉 CHATS: 기존 채팅 기록 로드
    final thread = ChatRepository.getThread(_userId, _designId);
    _messages.addAll(thread.messages);

    _initialized = true;
  }

  @override
  void dispose() {
    _inputController.dispose(); // 👉 CHATS: 컨트롤러 정리
    super.dispose();
  }

  // ✅ 기존 함수 (색 → hex) 그대로 유지, 위치만 State로 이동
  String _colorToHex(Color color) {
    final v = color.value.toRadixString(16).padLeft(8, '0');
    return '#${v.substring(2).toUpperCase()}';
  }

  Future<void> _handleSend() async {
    if (_isProcessing) return;

    final text = _inputController.text.trim();
    if (text.isEmpty) return;

    _inputController.clear();

    final userMsg = ChatMessage(isUser: true, text: text);
    setState(() {
      _messages.add(userMsg);
      _isProcessing = true;
    });
    ChatRepository.addMessage(_userId, _designId, userMsg);

    // ❗ 예외 안 던지고 항상 String 반환
    final replyText = await AIConsultingService.consult(
      design: _design,
      history: List<ChatMessage>.from(_messages),
      userMessage: text,
    );

    final aiMsg = ChatMessage(isUser: false, text: replyText);
    if (!mounted) return;
    setState(() {
      _messages.add(aiMsg);
      _isProcessing = false;
    });
    ChatRepository.addMessage(_userId, _designId, aiMsg);
  }

  // 👉 CHATS: reset 버튼용, 해당 디자인의 채팅 기록 삭제
  Future<void> _handleReset() async {
    ChatRepository.clearThread(_userId, _designId);
    setState(() {
      _messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    final d = _design;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),

            // Design it 버튼
            ElevatedButton(
              // 🔥 변경점: AI가 답변 생성 중이면 버튼 비활성화
              onPressed: _isProcessing
                  ? null                              // 비활성화
                  : () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => DesignPage(design: d),
                    transitionsBuilder: (_, animation, __, child) {
                      final tween = Tween<Offset>(
                        begin: const Offset(-1.0, 0.0),
                        end: Offset.zero,
                      ).chain(CurveTween(curve: Curves.easeInOut));
                      return SlideTransition(
                        position: animation.drive(tween),
                        child: child,
                      );
                    },
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                minimumSize: const Size(0, 0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Design it',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
              ),
            ),

            const Spacer(),

            // 🔥 변경점: 홈 아이콘 완전히 제거
            // (여기 있던 IconButton(Icons.home_outlined, ...) 블록 삭제)
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(
            height: 0.5,
            color: Colors.black.withOpacity(0.2),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🔥 여기까지 프리뷰 영역도 기존 코드 그대로
          Hero(
            tag: 'design-preview-${d.id ?? 'temp'}',
            child: Material(
              color: Colors.transparent,
              child: Container(
                height: 120,
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                decoration: BoxDecoration(
                  color: d.backgroundColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Center(
                  child: Text(
                    d.text,
                    style: TextStyle(
                      fontFamily: d.fontFamily,
                      color: d.fontColor,
                      fontSize: 32,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              '${_colorToHex(d.backgroundColor)} · '
              '${_colorToHex(d.fontColor)} · '
              '${d.fontFamily}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),

          const SizedBox(height: 24),

          // 👉 CHATS: reset 버튼은 "채팅 영역"에 속하니까 여기 추가
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _handleReset,
                child: const Text('Reset chat', style: TextStyle(fontSize: 13)),
              ),
            ),
          ),

          // 🔄 기존: const Expanded( ... 'chating UI will be here.' ...)
          //    → 실제 채팅 리스트로 교체
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              itemCount: _messages.length + (_isProcessing ? 1 : 0),
              itemBuilder: (context, index) {
                // 👉 CHATS: 마지막 아이템을 typing indicator로 사용
                if (_isProcessing && index == _messages.length) {
                  return const TypingIndicatorBubble();
                }

                final msg = _messages[index];
                return MessageBubble(message: msg);
              },
            ),
          ),

          // 👉 CHATS: 하단 입력바 (processing 상태일 때 비활성화)
          ChatInputBar(
            controller: _inputController,
            isProcessing: _isProcessing,
            onSend: _handleSend,
          ),
        ],
      ),
    );
  }
}