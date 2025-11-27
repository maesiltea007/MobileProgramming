import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class ScanPage extends StatefulWidget {
  final VoidCallback? onBackToHome; // 🔹 추가
  const ScanPage({
    super.key,
    this.onBackToHome,
  });

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _error;

  CameraImage? _lastImage;

  Color _selectedColor = Colors.grey;
  String _hexCode = '# FFFFFF';

  int? _prevR, _prevG, _prevB; // 🔹 이전 RGB (±2 이하면 업데이트 안 함)

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    if (kIsWeb) {
      setState(() {
        _error = '웹(Chrome)에서는 camera 패키지가 동작하지 않습니다.\n'
            '안드로이드 기기에서 실행해 주세요.';
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = '사용 가능한 카메라가 없습니다.');
        return;
      }

      final backCamera = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );

      _initFuture = controller.initialize();
      await _initFuture;

      bool _isProcessing = false;
      DateTime? _lastProcessed;

      /// initState 밑쪽에 위 두 변수를 필드로 추가해두고,

      await controller.startImageStream((image) async {
        if (_isProcessing) return; // 이미 처리 중이면 스킵

        final now = DateTime.now();
        if (_lastProcessed != null &&
            now.difference(_lastProcessed!) < const Duration(milliseconds: 80)) {
          // 80ms 이내(대략 10~12fps)는 스킵해서 부하 줄이기
          return;
        }

        _isProcessing = true;
        _lastImage = image;
        _updateColorFromImage();
        _lastProcessed = now;
        _isProcessing = false;
      });


      setState(() {
        _controller = controller;
      });
    } catch (e) {
      setState(() => _error = '카메라 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    if (_controller?.value.isStreamingImages == true) {
      _controller!.stopImageStream();
    }
    _controller?.dispose();
    super.dispose();
  }

  // 🔥 YUV420 이미지에서 가운데 근처 7×7 픽셀 평균 색 + ±2 임계값 필터
  void _updateColorFromImage() {
    final image = _lastImage;
    if (image == null) return;

    if (image.format.group != ImageFormatGroup.yuv420 ||
        image.planes.length < 3) {
      return;
    }

    final imgW = image.width;
    final imgH = image.height;

    // 십자가 중심을 프레임 중앙으로 가정
    final centerX = (imgW / 2).round();
    final centerY = (imgH / 2).round();

    const int radius = 3; // 7x7

    int sumR = 0, sumG = 0, sumB = 0, count = 0;

    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final yRowStride = yPlane.bytesPerRow;
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;

    for (int dy = -radius; dy <= radius; dy++) {
      for (int dx = -radius; dx <= radius; dx++) {
        final x = (centerX + dx).clamp(0, imgW - 1);
        final y = (centerY + dy).clamp(0, imgH - 1);

        // Y
        final yIndex = y * yRowStride + x;
        final int Y = yPlane.bytes[yIndex];

        // U, V (2x2 블럭)
        final uvX = x ~/ 2;
        final uvY = y ~/ 2;
        final uvIndex = uvY * uvRowStride + uvX * uvPixelStride;
        final int U = uPlane.bytes[uvIndex];
        final int V = vPlane.bytes[uvIndex];

        double yf = Y.toDouble();
        double uf = (U - 128).toDouble();
        double vf = (V - 128).toDouble();

        int r = (yf + 1.402 * vf).round();
        int g = (yf - 0.344136 * uf - 0.714136 * vf).round();
        int b = (yf + 1.772 * uf).round();

        r = r.clamp(0, 255);
        g = g.clamp(0, 255);
        b = b.clamp(0, 255);

        sumR += r;
        sumG += g;
        sumB += b;
        count++;
      }
    }

    if (count == 0) return;

    int r = (sumR / count).round().clamp(0, 255);
    int g = (sumG / count).round().clamp(0, 255);
    int b = (sumB / count).round().clamp(0, 255);

    // 🔹 변화가 거의 없으면(±2 이내) 업데이트 안 함
    if (_prevR != null &&
        (r - _prevR!).abs() <= 2 &&
        (g - _prevG!).abs() <= 2 &&
        (b - _prevB!).abs() <= 2) {
      return;
    }

    _prevR = r;
    _prevG = g;
    _prevB = b;

    if (!mounted) return;

    setState(() {
      _selectedColor = Color.fromARGB(255, r, g, b);
      _hexCode =
      '# ${r.toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${g.toRadixString(16).padLeft(2, '0').toUpperCase()}'
          '${b.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_controller == null || _initFuture == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Container(
          color: Colors.white,
          child: Column(
            children: [
              // ── 카메라 프리뷰(위쪽 전체 꽉 채우기) + 십자가
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Stack(
                      fit: StackFit.expand, // <- 중요: 영역 전체를 프리뷰가 꽉 채우도록
                      children: [
                        // 카메라 프리뷰 전체 채움
                        CameraPreview(_controller!),

                        // 십자가 중앙 배치
                        Center(
                          child: SizedBox(
                            width: 80,
                            height: 160,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(width: 2, height: 160, color: Colors.white),
                                Container(width: 80, height: 2, color: Colors.white),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),



              const SizedBox(height: 8),

              // ── 색 박스 + HEX + Save
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 32,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.black26),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 32,
                        alignment: Alignment.centerLeft,
                        padding:
                        const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: Text(
                          _hexCode,
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 32,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: 색 저장 로직
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black87,
                          elevation: 1,
                          padding:
                          const EdgeInsets.symmetric(horizontal: 14),
                        ),
                        child: const Text('Save'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // ── camera 버튼만
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        if (_controller == null || !_controller!.value.isInitialized) return;
                        try {
                          if (_controller!.value.isStreamingImages) {
                            await _controller!.stopImageStream();
                          }
                          final file = await _controller!.takePicture();

                          if (!mounted) return;
                          Navigator.pushNamed(
                            context,
                            '/colorpicker',
                            arguments: file.path,
                          );
                        } catch (e) {
                          debugPrint('takePicture error: $e');
                        }
                      },
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],            // 🔹 회색 원
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                              color: Colors.black.withOpacity(0.15),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,                 // 🔹 카메라 아이콘
                            size: 36,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),

                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }
}