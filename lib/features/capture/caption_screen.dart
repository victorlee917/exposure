import 'dart:math' as math;
import 'package:daily_exposures/main.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

import 'package:daily_exposures/features/capture/capture_origin.dart';
import 'package:daily_exposures/features/capture/capture_music_screen.dart'
    show MusicItem;
import 'package:daily_exposures/features/capture/capture_movie_screen.dart'
    show MovieItem, HeroSnapshotStore;
import 'package:daily_exposures/features/capture/widgets/media_result_card.dart';
import 'package:daily_exposures/features/capture/widgets/utils.dart';

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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;


    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Hero(
          tag: 'appbar-hero',
          child: AppBar(
            elevation: 0,
            backgroundColor: isDarkMode ? Colors.black : Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Material(
              type: MaterialType.transparency,
              child: Align(
                alignment: _isPhoto ? Alignment.center : Alignment.centerLeft,
                widthFactor: 1,
                heightFactor: 1,
                child: _HeaderByOrigin(origin: widget.origin),
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
                            style: TextStyle(
                              color: isDarkMode ? Colors.white : Colors.black,
                              fontSize: 16,
                              height: 1.35,
                            ),
                            cursorColor:
                                isDarkMode ? Colors.white70 : Colors.black54,
                            scrollPadding: EdgeInsets.zero,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              isCollapsed: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Write a caption...',
                              hintStyle: TextStyle(
                                  color: isDarkMode
                                      ? Colors.white38
                                      : Colors.black38),
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
        return Hero(
          tag: origin.heroTag,
          child: SizedBox(
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
          ),
        );
      case MusicOrigin(:final item):
        return MediaResultCard(
          heroTag: origin.heroTag,
          title: item.title,
          subtitle: item.artist,
          typeLabel: item.isAlbum ? 'Album' : 'Track',
          yearLabel: extractYear(item.releaseDate),
          imageUrl: item.coverUrl,
          isMovie: false,
        );
      case MovieOrigin(:final item):
        return MediaResultCard(
          heroTag: origin.heroTag,
          title: item.title,
          typeLabel: item.isTvSeries ? 'TV series' : 'Movie',
          yearLabel: extractYear(item.releaseDate),
          imageUrl: item.posterUrl,
          isMovie: true,
        );
    }
  }
}

/// 스크롤 바운스 제거
class _NoBounceScrollBehavior extends ScrollBehavior {
  const _NoBounceScrollBehavior();
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) =>
      child;

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const ClampingScrollPhysics();
}

