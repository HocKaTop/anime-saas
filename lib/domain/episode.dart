class Episode {
  final String id;
  final String titleSlug;
  final int seasonNumber;
  final int number;
  final String title;
  final String duration;
  final int? durationSec;
  final String description;
  final String? playbackStatus;

  const Episode({
    required this.id,
    required this.titleSlug,
    required this.number,
    required this.title,
    required this.duration,
    required this.description,
    this.seasonNumber = 1,
    this.durationSec,
    this.playbackStatus,
  });

  // Готовность видео. Доступ пользователя проверяется отдельно.
  bool get canWatch => playbackStatus == 'ready';

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    required String titleSlug,
    required int seasonNumber,
  }) {
    final durationSec = (json['durationSec'] as num?)?.toInt();
    final playback = json['playback'] as Map<String, dynamic>?;

    return Episode(
      id: json['id'] as String,
      titleSlug: titleSlug,
      seasonNumber: seasonNumber,
      number: (json['number'] as num).toInt(),
      title: json['name'] as String,
      duration: _formatDuration(durationSec),
      durationSec: durationSec,
      description:
          json['description'] as String? ?? 'Описание отсутствует',
      playbackStatus: playback?['status'] as String?,
    );
  }

  static String _formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) {
      return 'Длительность не указана';
    }

    final minutes = seconds ~/ 60;
    final remainder = (seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$remainder';
  }
}