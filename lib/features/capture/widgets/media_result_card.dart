import 'package:daily_exposures/constants/borders.dart';
import 'package:daily_exposures/constants/rvalues.dart';
import 'package:daily_exposures/features/capture/capture_movie_screen.dart'
    show HeroSnapshotStore;
import 'package:flutter/material.dart';

class MediaResultCard extends StatelessWidget {
  const MediaResultCard({
    super.key,
    this.boundaryKey,
    required this.heroTag,
    required this.title,
    this.subtitle,
    required this.typeLabel,
    required this.yearLabel,
    this.imageUrl,
    required this.isMovie,
    this.onTap,
  });

  final GlobalKey? boundaryKey;
  final String heroTag;
  final String title;
  final String? subtitle;
  final String typeLabel;
  final String yearLabel;
  final String? imageUrl;
  final bool isMovie;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    print(
      'MediaResultCard build: heroTag=$heroTag, imageUrl=$imageUrl, onTap=${onTap != null}',
    );

    final cardContent = RepaintBoundary(
      key: boundaryKey,
      child: Container(
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF111111) : Colors.white,
          borderRadius: BorderRadius.circular(Rvalues.button),
          border: Border.all(
            color: isDarkMode ? Borders.lineColorDark : Borders.lineColorLight,
            width: 1,
          ),
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            // Image/Poster Area
            ClipRRect(
              borderRadius: BorderRadius.circular(Rvalues.button),
              child: SizedBox(
                width: isMovie ? 60 : 64,
                height: isMovie ? 90 : 64,
                child: imageUrl != null
                    ? Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, __, ___) => _Placeholder(
                          isMovie: isMovie,
                          isDarkMode: isDarkMode,
                        ),
                      )
                    : _Placeholder(isMovie: isMovie, isDarkMode: isDarkMode),
              ),
            ),
            SizedBox(width: isMovie ? 12 : 10),

            // Text Area
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: isMovie ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    textWidthBasis: TextWidthBasis.parent,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: isMovie ? 16 : null,
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textWidthBasis: TextWidthBasis.parent,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  SizedBox(height: isMovie ? 6 : 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? const Color(0xFF222222)
                              : (isMovie
                                    ? const Color(0xFFEFEFEF)
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          typeLabel,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black87,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        yearLabel,
                        textWidthBasis: TextWidthBasis.parent,
                        style: TextStyle(
                          color: isDarkMode ? Colors.white54 : Colors.black54,
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
          return (direction == HeroFlightDirection.push
              ? fromCtx.widget
              : toCtx.widget);
        },
        placeholderBuilder: (_, __, child) =>
            Opacity(opacity: 0.0, child: child),
        child: Material(type: MaterialType.transparency, child: cardContent),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isMovie, required this.isDarkMode});
  final bool isMovie;
  final bool isDarkMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isDarkMode ? const Color(0xFF2A2A2A) : Colors.white,
      child: Center(
        child: Icon(
          isMovie ? Icons.movie : Icons.music_note,
          color: isDarkMode ? Colors.white24 : Colors.black38,
        ),
      ),
    );
  }
}
