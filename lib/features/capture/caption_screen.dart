// lib/features/capture/caption_screen.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:daily_exposures/features/capture/capture_origin.dart';
import 'package:daily_exposures/features/capture/capture_music_screen.dart'
    show MusicItem;
import 'package:daily_exposures/features/capture/capture_movie_screen.dart'
    show MovieItem, HeroSnapshotStore;

class CaptionScreen extends StatefulWidget {
  const CaptionScreen({super.key, required this.origin});
  final CaptureOrigin origin;

  @override
  State<CaptionScreen> createState() => _CaptionScreenState();
}

class _CaptionScreenState extends State<CaptionScreen> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  bool get _isPhoto => widget.origin is PhotoOrigin;

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

  @override
  Widget build(BuildContext context) {
    final heroTag = widget.origin.heroTag;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'appbar-hero',
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.black,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).maybePop(),
            ),
            title: const Text('Capture'),
            centerTitle: true,
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: const Text('Done'),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          Hero(
            tag: heroTag,
            flightShuttleBuilder:
                (context, animation, direction, fromCtx, toCtx) {
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
                Opacity(opacity: 0, child: child),
            child: Material(
              type: MaterialType.transparency,
              child: Align(
                alignment: _isPhoto ? Alignment.center : Alignment.centerLeft,
                widthFactor: 1,
                heightFactor: 1,
                child: _HeaderByOrigin(origin: widget.origin),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white12),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final kb = MediaQuery.of(context).viewInsets.bottom;

                return AnimatedPadding(
                  padding: EdgeInsets.only(bottom: kb),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  child: ScrollConfiguration(
                    behavior: const _NoBounceScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 24,
                        ),
                        child: TextField(
                          autocorrect: false,
                          controller: _controller,
                          focusNode: _focusNode,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                          maxLines: null,
                          expands: false,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.35,
                          ),
                          cursorColor: Colors.white70,
                          scrollPadding: EdgeInsets.zero,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isCollapsed: true,
                            contentPadding: EdgeInsets.zero,
                            hintText: 'Write a caption...',
                            hintStyle: TextStyle(color: Colors.white38),
                          ),
                          onEditingComplete: () => _focusNode.requestFocus(),
                          onTapOutside: (_) => _focusNode.requestFocus(),
                        ),
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

/// ===== 상단 미니 프리뷰 =====
class _HeaderByOrigin extends StatelessWidget {
  const _HeaderByOrigin({required this.origin});
  final CaptureOrigin origin;

  @override
  Widget build(BuildContext context) {
    switch (origin) {
      case PhotoOrigin(:final entity):
        final double width = math.min(
          MediaQuery.of(context).size.width * 0.6,
          180,
        );
        return SizedBox(
          width: width,
          child: AspectRatio(
            aspectRatio: 2 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AssetEntityImage(
                entity,
                isOriginal: false,
                thumbnailSize: const ThumbnailSize(1500, 1500),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      case MusicOrigin(:final item):
        return _MusicMiniCard(item: item);
      case MovieOrigin(:final item):
        return _MovieMiniCard(item: item);
    }
  }
}

/// ===== Mini Cards =====
/// ===== Mini Cards =====
class _MusicMiniCard extends StatelessWidget {
  const _MusicMiniCard({required this.item});
  final MusicItem item;

  @override
  Widget build(BuildContext context) {
    final typeLabel = item.isAlbum ? 'Album' : 'Track';
    final yearLabel = _extractYear(item.releaseDate);

    return _CardShell(
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

          // 텍스트 + 타입/연도
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textWidthBasis: TextWidthBasis.parent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                // 아티스트
                if ((item.artist ?? '').isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      item.artist!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textWidthBasis: TextWidthBasis.parent,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                const SizedBox(height: 6),
                // 타입 & 연도
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
    );
  }
}

class _MovieMiniCard extends StatelessWidget {
  const _MovieMiniCard({required this.item});
  final MovieItem item;

  @override
  Widget build(BuildContext context) {
    final year = _extractYear(item.releaseDate);
    final typeLabel = item.isTvSeries ? 'TV series' : 'Movie';

    return _CardShell(
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              width: 60,
              height: 90,
              child: item.posterUrl != null
                  ? Image.network(
                      item.posterUrl!,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.medium,
                      errorBuilder: (_, __, ___) => const _PosterPlaceholder(),
                    )
                  : const _PosterPlaceholder(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
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
                      year,
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
    );
  }
}

/// 공통 카드 껍데기
class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width - 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10, width: 2),
      ),
      padding: const EdgeInsets.all(10),
      child: child,
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

String _extractYear(String? date) {
  if (date == null || date.isEmpty) return 'Unknown';
  final m = RegExp(r'\b(\d{4})\b').firstMatch(date);
  return m != null ? m.group(1)! : 'Unknown';
}

/// 스크롤 바운스 제거
class _NoBounceScrollBehavior extends ScrollBehavior {
  const _NoBounceScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) => child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}
