// lib/features/capture/capture_origin.dart
import 'package:photo_manager/photo_manager.dart';

// 너의 프로젝트에 있는 모델로 import 경로 맞춰줘
import 'package:daily_exposures/features/capture/capture_music_screen.dart'
    show MusicItem;
import 'package:daily_exposures/features/capture/capture_movie_screen.dart'
    show MovieItem;

sealed class CaptureOrigin {
  const CaptureOrigin();
  String get heroTag;
}

class PhotoOrigin extends CaptureOrigin {
  final AssetEntity entity;
  const PhotoOrigin(this.entity);

  @override
  String get heroTag => 'preview-${entity.id}';
}

class MusicOrigin extends CaptureOrigin {
  final MusicItem item;
  const MusicOrigin(this.item);

  @override
  String get heroTag => 'music-card-${item.id}';
}

class MovieOrigin extends CaptureOrigin {
  final MovieItem item;
  const MovieOrigin(this.item);

  @override
  String get heroTag => 'movie-card-${item.id}';
}
