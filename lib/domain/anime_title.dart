class AnimeTitle {
  final String id;
  final String slug;
  final String title;
  final String genre;
  final List<String> genres;
  final int? year;
  final double? rating;
  final String description;
  final int? episodes;
  final String? posterUrl;

  const AnimeTitle({
    required this.id,
    required this.slug,
    required this.title,
    required this.genre,
    this.genres = const [],
    required this.year,
    required this.rating,
    required this.description,
    required this.episodes,
    this.posterUrl,
  });

  String get yearLabel =>year?.toString() ?? 'Год выпуска не указан';
  String get ratingLabel => rating?.toStringAsFixed(1) ?? '-';

  factory AnimeTitle.fromJson(Map<String, dynamic> json){
    final genres= (json['genres'] as List).cast<String>();
    final seasons= json['seasons'] as List?;

    final episodeCount = seasons?.fold(0, (total,item){
      final season = item as Map<String,dynamic>;
      final episodes = season['episodes'] as List;
      return total + episodes.length;
    },);
    return AnimeTitle(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['name']as String,
      genre: genres.isEmpty
          ? 'Жанр не указан'
          : genres.join(', '),
      genres: List.unmodifiable(genres),
      year: (json ['startYear'] as num?)?.toInt(),
      rating: (json ['malMean'] as num?)?.toDouble(),
      description:  json['description'] as String? ?? 'Описание отсутствует',
      episodes: episodeCount,
      posterUrl: json['posterUrl'] as String?,
    );
  }
}