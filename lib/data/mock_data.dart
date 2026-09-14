class AnimeTitle {
  final String title;
  final String genre;
  final int year;
  final double rating;

  const AnimeTitle({
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
  });
}

const mockTitles = [
  AnimeTitle(
    title: 'Frieren: Beyond Journey\'s End',
    genre: 'Fantasy',
    year: 2023,
    rating: 9.3,
  ),
  AnimeTitle(
    title: 'Attack on Titan',
    genre: 'Action',
    year: 2013,
    rating: 9.1,
  ),
  AnimeTitle(
    title: 'Cyberpunk: Edgerunners',
    genre: 'Sci-Fi',
    year: 2022,
    rating: 8.6,
  ),
  AnimeTitle(
    title: 'Chainsaw Man',
    genre: 'Action',
    year: 2022,
    rating: 8.4,
  ),
  AnimeTitle(
    title: 'Vinland Saga',
    genre: 'Drama',
    year: 2019,
    rating: 8.8,
  ),
  AnimeTitle(
    title: 'Jujutsu Kaisen',
    genre: 'Action',
    year: 2020,
    rating: 8.6,
  ),
  AnimeTitle(
    title: 'Steins;Gate',
    genre: 'Sci-Fi',
    year: 2011,
    rating: 9.0,
  ),
  AnimeTitle(
    title: 'Made in Abyss',
    genre: 'Adventure',
    year: 2017,
    rating: 8.7,
  ),
];