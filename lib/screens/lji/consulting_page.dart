import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/design.dart';
import 'design_page.dart';

import '../../models/chat_message.dart'; // 👉 CHATS: 채팅 메시지 모델
import '../../state/app_state.dart'; // 👉 CHATS: userId 가져오기
import '../../../services/ai_consulting_services/ai_consulting_service.dart'; // 👉 CHATS: OpenRouter 호출
import '../../../services/ai_consulting_services/chat_repository.dart'; // 👉 CHATS: Hive 저장소

import 'widgets/consulting_page_widgets/chat_input_bar.dart'; // 👉 CHATS: 입력바 위젯
import 'widgets/consulting_page_widgets/message_bubble.dart'; // 👉 CHATS: 말풍선 위젯
import 'widgets/consulting_page_widgets/typing_indicator_bubble.dart'; // 👉 CHATS: ... 타이핑 인디케이터

// 🔄 기존: class ConsultingPage extends StatelessWidget
//    → 채팅 상태를 관리해야 하니까 StatefulWidget 으로 변경
class ConsultingPage extends StatefulWidget {
  final Design? design;

  const ConsultingPage({super.key, this.design});

  @override
  State<ConsultingPage> createState() => _ConsultingPageState();
}

class _ConsultingPageState extends State<ConsultingPage> {
  // 👉 CHATS: 실제로 화면에서 사용할 Design 인스턴스
  late Design _design;

  // 👉 CHATS: 채팅방 식별용 키 (userId + designId)
  late String _userId;
  late String _designId;

  // 👉 CHATS: 채팅 메시지 리스트
  final List<ChatMessage> _messages = [];

  // 👉 CHATS: 입력창 컨트롤러
  final TextEditingController _inputController = TextEditingController();

  // 👉 CHATS: AI가 답을 생성하는 중인지 여부
  bool _isProcessing = false;

  // 👉 CHATS: didChangeDependencies에서 한 번만 초기화하기 위한 플래그
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // 🔄 기존: build 안에서 d = design ?? ... 하던 부분을 여기로 이동
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
    // 🔄 기존: final d = design ?? ... → initState에서 _design 세팅 후 여기서는 그대로 사용
    final d = _design;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 12),

            // 🔥 여기부터 AppBar 영역은 너 코드 그대로 (UI/기능 변경 없음)
            ElevatedButton(
              onPressed: () {
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

            IconButton(
              icon: const Icon(Icons.home_outlined),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: Colors.black.withOpacity(0.2)),
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
