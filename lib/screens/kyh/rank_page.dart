import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/app_state.dart';

class RankPage extends StatelessWidget {
  const RankPage({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 20),

          Text(
            '📊 이번 주 랭킹',
            style: TextStyle(
              fontSize: app.fontSize + 2,
              fontWeight: FontWeight.bold,
              color: app.mainColor,
            ),
          ),

          const SizedBox(height: 20),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: app.playerLikes.length,
              itemBuilder: (context, index) {
                final liked = app.playerLiked[index];

                return GestureDetector(
                  onDoubleTap: () {
                    app.likeByDoubleTap(index);
                  },
                  child: Card(
                    elevation: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: app.mainColor.withOpacity(0.9),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),

                      title: Text(
                        '사용자 ${index + 1}',
                        style: TextStyle(
                          fontSize: app.fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Text(
                        '좋아요: ${app.playerLikes[index]}개',
                        style: TextStyle(fontSize: app.fontSize * 0.8),
                      ),

                      trailing: IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: liked ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          app.toggleLike(index);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
