class AnimeTitle {
  final String title;
  final String genre;
  final int year;
  final String description;
  final int episodes;
  final double rating;

  const AnimeTitle({
    required this.title,
    required this.genre,
    required this.year,
    required this.description,
    required this.episodes,
    required this.rating,
  });
}

class Episode {
  final int number;
  final String title;
  final String duration;
  final String description;

  const Episode({
    required this.number,
    required this.title,
    required this.duration,
    required this.description,
  });
}


const mockTitles = [
  AnimeTitle(
    title: 'Frieren: Beyond Journey\'s End',
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
    genre: 'Adventure',
    year: 2017,
    rating: 8.7,
    episodes: 25,
    description:
        'Юная исследовательница Рико отправляется в загадочную Бездну '
        'в поисках своей пропавшей матери.',
  ),
];

const mockEpisodes = [
  Episode(
    number: 1,
    title: 'Конец путешествия',
    duration: '24 мин',
    description: 'Герои возвращаются домой после победы над Королём демонов.',
  ),
  Episode(
    number: 2,
    title: 'Не обязательно была магия',
    duration: '24 мин',
    description: 'Фрирен отправляется в новое путешествие.',
  ),
  Episode(
    number: 3,
    title: 'Убийственная магия',
    duration: '24 мин',
    description: 'Прошлое Фрирен начинает влиять на настоящее.',
  ),
  Episode(
    number: 4,
    title: 'Земля, где покоятся души',
    duration: '24 мин',
    description: 'Путешествие группы продолжается на север.',
  ),
  Episode(
    number: 5,
    title: 'Призраки мёртвых',
    duration: '24 мин',
    description: 'Герои сталкиваются с новой угрозой.',
  ),
  Episode(
    number: 6,
    title: 'Герой деревни',
    duration: '24 мин',
    description: 'Группа прибывает в небольшую деревню.',
  ),
];