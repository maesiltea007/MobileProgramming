import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../services/design_repository.dart';
import '../../services/ranking_service.dart';
import '../../models/rank_item.dart';
import '../../state/app_state.dart';
import 'package:provider/provider.dart';
import 'design_preview_box.dart';
import '../../models/design.dart';


class RankPage extends StatefulWidget {
  const RankPage({super.key});

  @override
  State<RankPage> createState() => _RankPageState();
}

class _RankPageState extends State<RankPage> with SingleTickerProviderStateMixin{
  int tab = 0; // 0 = 전체, 1 = 내 디자인

  late TabController _tabController;
  late Future<List<RankItem>> _rankFuture;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;

      setState(() {
        tab = _tabController.index;
        _rankFuture = (tab == 0) ? _loadRanking() : _loadMyRanking();
      });
    });

    _rankFuture = _loadRanking();
  }


  // -------------------------------------------------------------------------
  // 전체 랭킹 불러오기
  // -------------------------------------------------------------------------
  Future<List<RankItem>> _loadRanking() async {
    final box = DesignRepository.box;

    // 1) 전체 디자인 로드 (map → Design + id 함께 저장)
    final List<MapEntry<String, Design>> designs = [];

    for (var key in box.keys) {
      final raw = box.get(key);

      if (raw is Map) {
        final map = Map<String, dynamic>.from(raw);
        final design = Design.fromMap(map);

        designs.add(MapEntry(key.toString(), design));
      }
    }

    // 2) 최신(createdAt) 순으로 정렬
    designs.sort((a, b) => b.value.createdAt.compareTo(a.value.createdAt));

    // 3) RankItem 리스트로 변환
    return designs.map((entry) {
      final id = entry.key;
      final d = entry.value;

      return RankItem(
        id: id,
        design: d,
        score: RankingService.getScore(id),
        isLiked: RankingService.isLiked(id),
      );
    }).toList();
  }


  // -------------------------------------------------------------------------
  // 내가 올린 디자인 랭킹 불러오기 (+ 전체 등수 계산)
  // -------------------------------------------------------------------------
  Future<List<RankItem>> _loadMyRanking() async {
    final all = await _loadRanking();
    final myId = Provider
        .of<AppState>(context, listen: false)
        .currentUserId;

    final mine = <RankItem>[];

    for (final item in all) {
      if (item.design.ownerId == myId) {
        mine.add(
          RankItem(
            id: item.id,
            design: item.design,
            score: item.score,
            isLiked: item.isLiked,
            rank: RankingService.getOverallRank(item.id), // 🔥 전체 기준 등수
          ),
        );
      }
    }

    return mine;
  }


  void _toggleLike(String designId) {
    RankingService.toggleLike(designId);
    setState(() {
      if (tab == 0) {
        _rankFuture = _loadRanking();
      } else {
        _rankFuture = _loadMyRanking();
      }
    });
  }

  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.white,
        title: const SizedBox.shrink(),
        // 제목 제거

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400),

            // 🔥 두 탭을 좌우로 꽉 채우는 핵심 옵션
            indicatorSize: TabBarIndicatorSize.tab,

            indicator: const UnderlineTabIndicator(
              borderSide: BorderSide(width: 2.5, color: Colors.black),
            ),

            tabs: const [
              Tab(text: "전체 랭킹"),
              Tab(text: "내 디자인"),
            ],
          ),
        ),

      ),


      body: FutureBuilder(
        future: _rankFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final list = snapshot.data as List<RankItem>;

          if (list.isEmpty) {
            return const Center(child: Text("표시할 디자인이 없습니다."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, index) {
              final item = list[index];
              final d = item.design;

              // 전체 랭킹일 때만 등수 표시
              final rankLabel = (tab == 1) ? "${item.rank}" : null;

              return GestureDetector(
                onDoubleTap: () => _toggleLike(item.id),

                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: (tab == 1 && item.rank != null && item.rank! <= 10)
                          ? Colors.blueAccent
                          : Colors.transparent,
                      width: (tab == 1 && item.rank != null && item.rank! <= 10)
                          ? 2
                          : 0,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        DesignPreviewBox(design: d),

                        const SizedBox(height: 12),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [

                            // 🔥 내 디자인 탭일 때만 등수 출력
                            if (tab == 1)
                              Row(
                                children: [
                                  // 1~3등 트로피
                                  if (item.rank != null && item.rank! <= 10)
                                    Icon(
                                      Icons.emoji_events,
                                      color: rankColor(item.rank!),
                                      size: 22,
                                    ),

                                  // #등수 표시
                                  Text(
                                    "#${item.rank}",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: rankColor(item.rank ?? 0),
                                    ),
                                  ),
                                ],
                              ),

                            // 좋아요 버튼
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.favorite,
                                    color: item.isLiked ? Colors.red : Colors
                                        .grey,
                                  ),
                                  onPressed: () => _toggleLike(item.id),
                                ),
                                Text("${item.score}"),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

Color rankColor(int r) {
  if (r == 1) return const Color(0xffFFD700); // 금
  if (r == 2) return const Color(0xffC0C0C0); // 은
  if (r == 3) return const Color(0xffCD7F32); // 동
  return Colors.black; // 기본 텍스트 색
}
