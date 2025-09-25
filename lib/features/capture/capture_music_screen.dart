// lib/features/capture/capture_music_screen.dart
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

import 'caption_screen.dart';
import 'capture_origin.dart'; // MusicOrigin 사용
import 'capture_movie_screen.dart' show HeroSnapshotStore; // 스냅샷 저장소 재사용
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';

// 연도만 뽑기(YYYY 또는 YYYY-MM-DD 대응)
String _extractYear(String? date) {
  if (date == null || date.isEmpty) return 'Unknown';
  final m = RegExp(r'\b(\d{4})\b').firstMatch(date);
  return m != null ? m.group(1)! : 'Unknown';
}

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
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
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
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF171717),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        tooltip: 'Clear',
                        icon: const Icon(Icons.clear, color: Colors.white54),
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
              style: const TextStyle(color: Colors.white),
              cursorColor: Colors.white70,
              onChanged: (_) => setState(() {}),
            ),
          ),

          // 결과 영역
          Expanded(
            child: Stack(
              children: [
                _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.white70),
                      )
                    : _results.isEmpty
                    ? _EmptyState(lastQuery: _lastQuery)
                    : CustomScrollView(
                        physics: const BouncingScrollPhysics(),
                        slivers: [
                          const SliverToBoxAdapter(child: SizedBox(height: 16)),
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
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
                                return _ResultTile(
                                  boundaryKey: key,
                                  heroTag: heroTag,
                                  item: item,
                                  // ✅ 카드 탭 시 바로 이동
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

/// 결과 타일 (정사각 커버 + 제목/아티스트 + 타입&연도) + Hero + RepaintBoundary
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.boundaryKey,
    required this.heroTag,
    required this.item,
    required this.onTap,
  });

  final GlobalKey boundaryKey;
  final String heroTag;
  final MusicItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.isAlbum ? 'Album' : 'Track';
    final yearLabel = _extractYear(item.releaseDate);

    final card = RepaintBoundary(
      key: boundaryKey,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF111111),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10, width: 2),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // 정사각 커버 64x64
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 64,
                height: 64,
                child: item.coverUrl != null
                    ? Image.network(
                        item.coverUrl!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, __, ___) =>
                            const _SquarePlaceholder(icon: Icons.music_note),
                      )
                    : const _SquarePlaceholder(icon: Icons.music_note),
              ),
            ),
            const SizedBox(width: 10),

            // 텍스트
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if ((item.artist ?? '').isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        item.artist!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222222),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeLabel,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        yearLabel,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Hero(
        tag: heroTag,
        flightShuttleBuilder: (context, animation, direction, fromCtx, toCtx) {
          final bytes = HeroSnapshotStore.peek(heroTag);
          if (bytes != null) {
            return Image.memory(
              bytes,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            );
          }
          return direction == HeroFlightDirection.push
              ? fromCtx.widget
              : toCtx.widget;
        },
        placeholderBuilder: (_, __, child) =>
            Opacity(opacity: 0.0, child: child),
        child: Material(type: MaterialType.transparency, child: card),
      ),
    );
  }
}

class _SquarePlaceholder extends StatelessWidget {
  const _SquarePlaceholder({required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: Center(child: Icon(icon, color: Colors.white24)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.lastQuery});
  final String lastQuery;

  @override
  Widget build(BuildContext context) {
    final text = lastQuery.isEmpty
        ? 'Search music by title or artist.'
        : 'No results for “$lastQuery”.';
    return Center(
      child: Text(
        text,
        style: const TextStyle(color: Colors.white38),
        textAlign: TextAlign.center,
      ),
    );
  }
}
