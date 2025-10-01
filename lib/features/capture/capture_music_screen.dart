import 'dart:ui' as ui;
import 'package:daily_exposures/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

import 'caption_screen.dart';
import 'capture_origin.dart'; // MusicOrigin 사용
import 'capture_movie_screen.dart' show HeroSnapshotStore; // 스냅샷 저장소 재사용
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:daily_exposures/features/capture/widgets/media_result_card.dart';
import 'package:daily_exposures/features/capture/widgets/utils.dart';

/// ===== 데이터 모델 & 리포지토리 인터페이스 =====

class MusicItem {
  final String id;
  final String title;
  final String? artist;
  final String? coverUrl;

  final bool isAlbum; // true: Album, false: Track/Song
  final String? releaseDate; // YYYY 또는 YYYY-MM-DD

  const MusicItem({
    required this.id,
    required this.title,
    this.artist,
    this.coverUrl,
    this.isAlbum = false,
    this.releaseDate,
  });
}

abstract class MusicRepository {
  Future<List<MusicItem>> search(String query);
}

/// 임시 목: 실제 API(Apple Music/Spotify 등)로 교체하면 됨
class _MockMusicRepository implements MusicRepository {
  static const _mock = <MusicItem>[
    MusicItem(
      id: '1',
      title: 'Blinding Lights',
      artist: 'The Weeknd',
      coverUrl:
          'https://is1-ssl.mzstatic.com/image/thumb/Music124/v4/ce/2d/88/ce2d8886-1b35-8a5a-8a07-1e3a2a9d5c16/source/600x600bb.jpg',
      isAlbum: false,
      releaseDate: '2019-11-29',
    ),
    MusicItem(
      id: '2',
      title: 'Anti-Hero',
      artist: 'Taylor Swift',
      coverUrl:
          'https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/9f/2f/89/9f2f892e-2d8a-1b0f-4f0b-9c8b6a0a8b5f/source/600x600bb.jpg',
      isAlbum: false,
      releaseDate: '2022-10-21',
    ),
    MusicItem(
      id: '3',
      title: 'As It Was',
      artist: 'Harry Styles',
      coverUrl:
          'https://is1-ssl.mzstatic.com/image/thumb/Music122/v4/2f/1f/0e/2f1f0e7d-0a1d-c3c9-3b89-0d5e4b9a1f3c/source/600x600bb.jpg',
      isAlbum: false,
      releaseDate: '2022-04-01',
    ),
    // 검색 테스트용
    MusicItem(
      id: 't1',
      title: 'Test Drive',
      artist: 'Joji',
      coverUrl:
          'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/1d/7d/4d/1d7d4d84-0d7d-54f5-6a61-8a4f2da1f2a5/source/600x600bb.jpg',
      isAlbum: false,
      releaseDate: '2018-05-30',
    ),
    MusicItem(
      id: 't2',
      title: 'Speed Test',
      artist: 'DJ Sample',
      coverUrl:
          'https://is1-ssl.mzstatic.com/image/thumb/Music125/v4/78/77/0d/78770d8e-1d2a-5d8c-9f4a-1a3aaf6e9b0c/source/600x600bb.jpg',
      isAlbum: true,
      releaseDate: '2021-02-10',
    ),
  ];

  @override
  Future<List<MusicItem>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _mock
        .where(
          (e) =>
              e.title.toLowerCase().contains(q) ||
              (e.artist?.toLowerCase().contains(q) ?? false),
        )
        .toList(growable: false);
  }
}

/// ===== 화면 =====

class CaptureMusicScreen extends StatefulWidget {
  const CaptureMusicScreen({super.key, this.repository});
  final MusicRepository? repository;

  @override
  State<CaptureMusicScreen> createState() => _CaptureMusicScreenState();
}

class _CaptureMusicScreenState extends State<CaptureMusicScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _loading = false;
  String _lastQuery = '';
  List<MusicItem> _results = [];

  // 각 타일의 RepaintBoundary 키(스냅샷용)
  final Map<String, GlobalKey> _tileBoundaryKeys = {};

  MusicRepository get _repo => widget.repository ?? _MockMusicRepository();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _search(String raw) async {
    final query = raw.trim();
    if (query.isEmpty) return;

    setState(() {
      _loading = true;
      _lastQuery = query;
    });

    try {
      final items = await _repo.search(query);
      setState(() => _results = items);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onSubmitted(String value) {
    _focusNode.unfocus();
    _search(value);
  }

  // 선택된 카드 스냅샷을 찍고 CaptionScreen으로 이동
  Future<void> _goToCaption(MusicItem sel) async {
    print('Music _goToCaption called for item: ${sel.title}');
    final heroTag = 'music-card-${sel.id}';
    final key = _tileBoundaryKeys[heroTag];

    if (key != null) {
      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          final byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final bytes = byteData?.buffer.asUint8List();
          if (bytes != null) {
            HeroSnapshotStore.put(heroTag, bytes);
          }
        }
      } catch (_) {
        // 스냅샷 실패해도 기본 Hero로 진행
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CaptionScreen(origin: MusicOrigin(sel)),
        transitionDuration: const Duration(milliseconds: 320),
        reverseTransitionDuration: const Duration(milliseconds: 280),
        transitionsBuilder: (context, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );
          return FadeTransition(opacity: curved, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text('Capture'),
        centerTitle: true,
        // ✅ Next 버튼 제거
        actions: const [],
      ),
      body: Column(
        children: [
          // 검색 폼
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              autocorrect: false,
              controller: _controller,
              focusNode: _focusNode,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onSubmitted: _onSubmitted,
              decoration: InputDecoration(
                hintText: 'Search music by title or artist',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38),
                filled: true,
                fillColor: isDarkMode ? const Color(0xFF171717) : Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white12 : Colors.black12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white12 : Colors.black12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                      color: isDarkMode ? Colors.white54 : Colors.black54),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: Icon(Icons.clear,
                            color: isDarkMode ? Colors.white54 : Colors.black54),
                        onPressed: () {
                          setState(() {
                            _controller.clear();
                            _results = [];
                            _lastQuery = '';
                          });
                          _focusNode.requestFocus();
                        },
                      )
                    : IconButton(
                        tooltip: 'Search',
                        icon: const Icon(Icons.search),
                        onPressed: () {
                          _focusNode.unfocus();
                          _onSubmitted(_controller.text);
                        },
                      ),
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              cursorColor: Colors.white70,
              onChanged: (_) => setState(() {}),
            ),
          ),

          // 결과 영역
          Expanded(
            child: Stack(
              children: [
                _loading
                    ? Center(
                        child: CircularProgressIndicator(color: isDarkMode ? Colors.white70 : Colors.black54),
                      )
                    : _results.isEmpty
                        ? _EmptyState(lastQuery: _lastQuery)
                        : CustomScrollView(
                            physics: const BouncingScrollPhysics(),
                            slivers: [
                              const SliverToBoxAdapter(child: SizedBox(height: 16)),
                              SliverPadding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 0, 16, 36),
                                sliver: SliverList.separated(
                                  itemCount: _results.length,
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 10),
                                  itemBuilder: (context, index) {
                                    final item = _results[index];
                                    final heroTag = 'music-card-${item.id}';
                                    final key = _tileBoundaryKeys.putIfAbsent(
                                      heroTag,
                                      () => GlobalKey(),
                                    );
                                    return MediaResultCard(
                                      boundaryKey: key,
                                      heroTag: heroTag,
                                      title: item.title,
                                      subtitle: item.artist,
                                      typeLabel: item.isAlbum ? 'Album' : 'Track',
                                      yearLabel: extractYear(item.releaseDate),
                                      imageUrl: item.coverUrl,
                                      isMovie: false,
                                      onTap: () => _goToCaption(item),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),

                // 검색 폼 바로 아래 깔리는 고정 그라데이션
                const Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: AppbarGradation(
                    height: 20,
                    useThemeBg: false,
                    intensity: 0.9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.lastQuery});
  final String lastQuery;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final text = lastQuery.isEmpty
        ? 'Search music by title or artist.'
        : 'No results for “$lastQuery”.';
    return Center(
      child: Text(
        text,
        style: TextStyle(color: isDarkMode ? Colors.white38 : Colors.black38),
        textAlign: TextAlign.center,
      ),
    );
  }
}
