class AnimeTitle {
  final String id;
  final String slug;
  final String title;
  final String genre;
  final int year;
  final double rating;
  final String description;
  final int episodes;

  const AnimeTitle({
    required this.id,
    required this.slug,
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.description,
    required this.episodes,
  });
}