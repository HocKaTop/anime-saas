class AnimeTitle {
  final String slug;
  final String title;
  final String genre;
  final int year;
  final double rating;
  final String description;
  final int episodes;

  const AnimeTitle({
    required this.slug,
    required this.title,
    required this.genre,
    required this.year,
    required this.rating,
    required this.description,
    required this.episodes,
  });
}

class Episode {
  final String id;
  final String titleSlug;
  final int number;
  final String title;
  final String duration;
  final String description;

  const Episode({
    required this.id,
    required this.titleSlug,
    required this.number,
    required this.title,
    required this.duration,
    required this.description,
  });
}

const mockTitles = [
  AnimeTitle(
    title: 'Frieren: Beyond Journey\'s End',
    slug: "frieren-beyond-journey",
    genre: 'Fantasy',
    year: 2023,
    rating: 9.3,
    episodes: 28,
    description:
        'После победы над Королём демонов эльфийка Фрирен отправляется '
        'в новое путешествие, пытаясь лучше понять людей и своих бывших спутников.',
  ),
  AnimeTitle(
    title: 'Attack on Titan',
    slug: "attack-on-titan",
    genre: 'Action',
    year: 2013,
    rating: 9.1,
    episodes: 87,
    description:
        'Человечество скрывается за огромными стенами от титанов. '
        'После разрушения одной из стен Эрен начинает борьбу за свободу.',
  ),
  AnimeTitle(
    title: 'Cyberpunk: Edgerunners',
    slug: "cyberpunk-edgerunners",
    genre: 'Sci-Fi',
    year: 2022,
    rating: 8.6,
    episodes: 10,
    description:
        'История подростка из Найт-Сити, который после трагических событий '
        'становится наёмником и погружается в опасный мир киберпанка.',
  ),
  AnimeTitle(
    title: 'Chainsaw Man',
    slug: "chainsaw-man",
    genre: 'Action',
    year: 2022,
    rating: 8.4,
    episodes: 12,
    description:
        'Дэндзи охотится на демонов ради выплаты долгов, пока встреча '
        'с демоном Почитой полностью не меняет его жизнь.',
  ),
  AnimeTitle(
    title: 'Vinland Saga',
    slug: "vinland-saga",
    genre: 'Drama',
    year: 2019,
    rating: 8.8,
    episodes: 48,
    description:
        'Молодой Торфинн оказывается среди викингов и посвящает жизнь '
        'мести за своего отца.',
  ),
  AnimeTitle(
    title: 'Jujutsu Kaisen',
    slug: "jujutsu-kaisen",
    genre: 'Action',
    year: 2020,
    rating: 8.6,
    episodes: 47,
    description:
        'Юдзи Итадори оказывается втянут в мир проклятий после того, '
        'как получает силу чрезвычайно опасного духа.',
  ),
  AnimeTitle(
    title: 'Steins;Gate',
    slug: "steins-gate",
    genre: 'Sci-Fi',
    year: 2011,
    rating: 9.0,
    episodes: 24,
    description:
        'Группа друзей случайно создаёт способ отправлять сообщения '
        'в прошлое и сталкивается с последствиями изменения времени.',
  ),
  AnimeTitle(
    title: 'Made in Abyss',
    slug: "made-in-abyss",
    genre: 'Adventure',
    year: 2017,
    rating: 8.7,
    episodes: 25,
    description:
        'Юная исследовательница Рико отправляется в загадочную Бездну '
        'в поисках своей пропавшей матери.',
  ),
];

const _frierenEpisodes = [
  Episode(
    id: 'frieren-beyond-journey-1',
    titleSlug: 'frieren-beyond-journey',
    number: 1,
    title: 'Конец путешествия',
    duration: '24 мин',
    description: 'Герои возвращаются домой после победы над Королём демонов.',
  ),
  Episode(
    id: 'frieren-beyond-journey-2',
    titleSlug: 'frieren-beyond-journey',
    number: 2,
    title: 'Не обязательно была магия',
    duration: '24 мин',
    description: 'Фрирен отправляется в новое путешествие.',
  ),
  Episode(
    id: 'frieren-beyond-journey-3',
    titleSlug: 'frieren-beyond-journey',
    number: 3,
    title: 'Убийственная магия',
    duration: '24 мин',
    description: 'Прошлое Фрирен начинает влиять на настоящее.',
  ),
  Episode(
    id: 'frieren-beyond-journey-4',
    titleSlug: 'frieren-beyond-journey',
    number: 4,
    title: 'Земля, где покоятся души',
    duration: '24 мин',
    description: 'Путешествие группы продолжается на север.',
  ),
  Episode(
    id: 'frieren-beyond-journey-5',
    titleSlug: 'frieren-beyond-journey',
    number: 5,
    title: 'Призраки мёртвых',
    duration: '24 мин',
    description: 'Герои сталкиваются с новой угрозой.',
  ),
  Episode(
    id: 'frieren-beyond-journey-6',
    titleSlug: 'frieren-beyond-journey',
    number: 6,
    title: 'Герой деревни',
    duration: '24 мин',
    description: 'Группа прибывает в небольшую деревню.',
  ),
];

final List<Episode> mockEpisodes = List<Episode>.unmodifiable([
  for (final anime in mockTitles)
    for (var number = 1; number <= anime.episodes; number++)
      if (anime.slug == 'frieren-beyond-journey' &&
          number <= _frierenEpisodes.length)
        _frierenEpisodes[number - 1]
      else
        Episode(
          id: '${anime.slug}-$number',
          titleSlug: anime.slug,
          number: number,
          title: 'Серия $number',
          duration: '24 мин',
          description:
              'Демонстрационный эпизод $number тайтла «${anime.title}».',
        ),
]);

AnimeTitle? findTitleBySlug(String slug) {
  for (final anime in mockTitles) {
    if (anime.slug == slug) {
      return anime;
    }
  }

  return null;
}

Episode? findEpisodeById(String id) {
  for (final episode in mockEpisodes) {
    if (episode.id == id) {
      return episode;
    }
  }

  return null;
}

List<Episode> episodesForTitle(String slug) {
  return mockEpisodes.where((episode) => episode.titleSlug == slug).toList();
}
