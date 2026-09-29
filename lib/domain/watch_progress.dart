class WatchProgress {
  final String episodeId;
  final double progress;

  const WatchProgress({
    required this.episodeId,
    required this.progress,
  });

  bool get completed => progress >= 1.0;

  WatchProgress copyWith({
    double? progress,
  }) {
    return WatchProgress(
      episodeId: episodeId,
      progress: progress ?? this.progress,
    );
  }
}