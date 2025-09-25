// lib/features/capture/capture_movie_screen.dart
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

// ⬇️ CaptionScreen, CaptureOrigin 불러오기
import 'caption_screen.dart';
import 'capture_origin.dart'; // MovieOrigin 사용

String extractYear(String? date) {
  if (date == null || date.isEmpty) return '—';
  final m = RegExp(r'\b(\d{4})\b').firstMatch(date);
  return m != null ? m.group(1)! : '—';
}

/// ⬇️ Hero 비행 동안 사용할 스냅샷 저장소 (간단 공유 메모리)
class HeroSnapshotStore {
  static final Map<String, Uint8List> _map = {};
  static void put(String tag, Uint8List bytes) => _map[tag] = bytes;
  static Uint8List? take(String tag) => _map.remove(tag);
  static Uint8List? peek(String tag) => _map[tag];
}

class CaptureMovieScreen extends StatefulWidget {
  const CaptureMovieScreen({super.key, this.repository});

  final MovieRepository? repository;

  @override
  State<CaptureMovieScreen> createState() => _CaptureMovieScreenState();
}

class _CaptureMovieScreenState extends State<CaptureMovieScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool _loading = false;
  String _lastQuery = "";
  List<MovieItem> _results = [];

  // ⬇️ 각 타일의 RepaintBoundary 키를 보관 (스냅샷용)
  final Map<String, GlobalKey> _tileBoundaryKeys = {};

  MovieRepository get _repo => widget.repository ?? _MockMovieRepository();

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

  // ⬇️ 카드 스냅샷을 찍고 CaptionScreen으로 이동
  Future<void> _goToCaption(MovieItem sel) async {
    final heroTag = 'movie-card-${sel.id}';
    final key = _tileBoundaryKeys[heroTag];

    if (key != null) {
      try {
        final boundary =
            key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
        if (boundary != null) {
          final ui.Image image = await boundary.toImage(pixelRatio: 2.0);
          final ByteData? byteData = await image.toByteData(
            format: ui.ImageByteFormat.png,
          );
          final bytes = byteData?.buffer.asUint8List();
          if (bytes != null) {
            HeroSnapshotStore.put(heroTag, bytes);
          }
        }
      } catch (_) {
        // 스냅샷 실패 시에도 그냥 진행 (기본 Hero 동작으로)
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => CaptionScreen(origin: MovieOrigin(sel)),
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
                hintText: 'Search movies or TV series by name',
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
                            _lastQuery = "";
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
                // 스크롤 콘텐츠
                Positioned.fill(
                  child: _loading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Colors.white70,
                          ),
                        )
                      : _results.isEmpty
                      ? _EmptyState(lastQuery: _lastQuery)
                      : CustomScrollView(
                          physics: const BouncingScrollPhysics(),
                          slivers: [
                            // 리스트 시작 전 상단 간격
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 16),
                            ),

                            SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 36),
                              sliver: SliverList.separated(
                                itemCount: _results.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final item = _results[index];
                                  final heroTag = 'movie-card-${item.id}';
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

/// 결과 타일 (포스터, 제목, 타입, 개봉일) + Hero + RepaintBoundary(스냅샷)
class _ResultTile extends StatelessWidget {
  const _ResultTile({
    required this.boundaryKey,
    required this.heroTag,
    required this.item,
    required this.onTap,
  });

  final GlobalKey boundaryKey;
  final String heroTag;

  final MovieItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.isTvSeries ? 'TV series' : 'Movie';
    final yearLabel = item.releaseDate?.isNotEmpty == true
        ? extractYear(item.releaseDate)
        : 'Unknown';

    final card = RepaintBoundary(
      // ⬅️ 비행 전 스냅샷 채취 대상
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
            // 포스터
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 60,
                height: 90, // 2:3 비율
                child: item.posterUrl != null
                    ? Image.network(
                        item.posterUrl!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, __, ___) =>
                            const _PosterPlaceholder(),
                      )
                    : const _PosterPlaceholder(),
              ),
            ),
            const SizedBox(width: 12),

            // 텍스트 영역
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 제목
                  Text(
                    item.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // 타입 & 개봉일
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
                        textWidthBasis: TextWidthBasis.parent,
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
        // ⬇️ 비행 동안 '스냅샷'으로만 그리기 → 텍스트 재줄바꿈/덜컹 없음
        flightShuttleBuilder: (context, animation, direction, fromCtx, toCtx) {
          final bytes = HeroSnapshotStore.peek(heroTag);
          if (bytes != null) {
            return Image.memory(
              bytes,
              gaplessPlayback: true,
              filterQuality: FilterQuality.medium,
            );
          }
          // 스냅샷이 없으면 기본 위젯 (fallback)
          return (direction == HeroFlightDirection.push
              ? fromCtx.widget
              : toCtx.widget);
        },
        placeholderBuilder: (_, __, child) =>
            Opacity(opacity: 0.0, child: child),
        child: Material(type: MaterialType.transparency, child: card),
      ),
    );
  }
}

class _PosterPlaceholder extends StatelessWidget {
  const _PosterPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(child: Icon(Icons.movie, color: Colors.white24)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.lastQuery});
  final String lastQuery;

  @override
  Widget build(BuildContext context) {
    final text = lastQuery.isEmpty
        ? 'Search movies or TV series by title.'
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

/// ===== 데이터 모델 & 리포지토리 인터페이스 =====

class MovieItem {
  final String id;
  final String title;
  final bool isTvSeries;
  final String? releaseDate; // YYYY-MM-DD 등 문자열 그대로 표시
  final String? posterUrl;

  MovieItem({
    required this.id,
    required this.title,
    required this.isTvSeries,
    this.releaseDate,
    this.posterUrl,
  });
}

abstract class MovieRepository {
  Future<List<MovieItem>> search(String query);
}

/// 임시 목: 실제 API(TMDB 등)로 교체하면 됨
class _MockMovieRepository implements MovieRepository {
  static final _mock = <MovieItem>[
    // ▼ 기존 샘플
    MovieItem(
      id: '1',
      title: 'Inception',
      isTvSeries: false,
      releaseDate: '2010-07-16',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/qmDpIHrmpJINaRKAfWQfftjCdyi.jpg',
    ),
    MovieItem(
      id: '2',
      title: 'The Last of Us',
      isTvSeries: true,
      releaseDate: '2023-01-15',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/uKvVjHNqB5VmOrdxqAt2F7J78ED.jpg',
    ),
    MovieItem(
      id: '3',
      title: 'Interstellar',
      isTvSeries: false,
      releaseDate: '2014-11-07',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg',
    ),
    // ▼ test 샘플들
    MovieItem(
      id: 't1',
      title: 'The Test',
      isTvSeries: false,
      releaseDate: '2019-05-10',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/9gk7adHYeDvHkCSEqAvQNLV5Uge.jpg',
    ),
    MovieItem(
      id: 't2',
      title: 'A/B Test',
      isTvSeries: true,
      releaseDate: '2021-02-01',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/8UlWHLMpgZm9bx6Qh0NFoq67TZ.jpg',
    ),
    MovieItem(
      id: 't3',
      title: 'Stress Test',
      isTvSeries: false,
      releaseDate: '2016-09-23',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/6ELCZlTA5lGUops70hKdB83WJxH.jpg',
    ),
    MovieItem(
      id: 't4',
      title: 'Beta Test',
      isTvSeries: false,
      releaseDate: '2016-07-22',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/3T19XSr6yqaLNK8uJWFImPgRax0.jpg',
    ),
    MovieItem(
      id: 't5',
      title: 'Contest',
      isTvSeries: true,
      releaseDate: '2013-10-04',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/5KCVkau1HEl7ZzfPsKAPM0sMiKc.jpg',
    ),
    MovieItem(
      id: 't6',
      title: 'Protest',
      isTvSeries: false,
      releaseDate: '2018-03-12',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/cezWGskPY5x7GaglTTRN4Fugfb8.jpg',
    ),
    MovieItem(
      id: 't7',
      title: 'Detestable',
      isTvSeries: false,
      releaseDate: '2015-01-17',
      posterUrl:
          'https://image.tmdb.org/t/p/w342/2CAL2433ZeIihfX1Hb2139CX0pW.jpg',
    ),
  ];

  @override
  Future<List<MovieItem>> search(String query) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final q = query.toLowerCase();
    return _mock
        .where((e) => e.title.toLowerCase().contains(q))
        .toList(growable: false);
  }
}
