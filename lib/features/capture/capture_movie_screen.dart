import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:daily_exposures/constants/paddings.dart';
import 'package:daily_exposures/features/common/widgets/appbar_gradation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderRepaintBoundary;

// ⬇️ CaptionScreen, CaptureOrigin 불러오기
import 'caption_screen.dart';
import 'capture_origin.dart'; // MovieOrigin 사용
import 'package:daily_exposures/features/capture/widgets/media_result_card.dart';
import 'package:daily_exposures/features/capture/widgets/utils.dart';
import 'package:daily_exposures/features/capture/widgets/search_text_field.dart';

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
    print('Movie _goToCaption called for item: ${sel.title}');
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
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
      body: Padding(
        padding: EdgeInsetsGeometry.symmetric(
          horizontal: Paddings.screentHorizontal,
        ),
        child: Column(
          children: [
            // 검색 폼
            SearchTextField(
              controller: _controller,
              focusNode: _focusNode,
              hintText: 'Search movies or TV series by name',
              onSubmitted: _onSubmitted,
              onClear: () {
                setState(() {
                  _controller.clear();
                  _results = [];
                  _lastQuery = "";
                });
                _focusNode.requestFocus();
              },
              onChanged: (_) => setState(() {}),
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
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 36),
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
                                    return MediaResultCard(
                                      boundaryKey: key,
                                      heroTag: heroTag,
                                      title: item.title,
                                      typeLabel: item.isTvSeries
                                          ? 'TV series'
                                          : 'Movie',
                                      yearLabel: extractYear(item.releaseDate),
                                      imageUrl: item.posterUrl,
                                      isMovie: true,
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
                    child: AppbarGradation(height: 20, useThemeBg: true),
                  ),
                ],
              ),
            ),
          ],
        ),
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
        ? 'Search movies or TV series by title.'
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
