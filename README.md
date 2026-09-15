# AnimeSaaS - онлайн кинотеатр

**Oleg Slobodeniuc CR-232 PAM Project**

**Домен** - Стриминговая платформа, доставка контента

**Описание** - Онлайн сервис для просмотра видео, отслеживание прогресса просмотра и возможностью совместного просмотра.

## Обязательные экраны:

1. Вход/Регистрация
2. Поиск
3. Детальный экран произведения
4. Просмотр серии
5. Запланированные произведения
6. Главная с популярными/рекомендациями
7. Профиль пользователя

## Обязательная функциональность по этапам:

- **L2:** статические экраны каталога, поиска, списка просмотра, карточки тайтла, просмотра эпизода, профиля, входа и регистрации с «зашитыми» данными (Material 3); переиспользуемые карточки тайтлов и эпизодов.
- **L3:** навигация каталог → карточка тайтла → просмотр эпизода через go_router; навигация между каталогом, поиском, списком просмотра и профилем; формы входа и регистрации с валидацией.
- **L4:** состояние поиска, списка просмотра, текущего тайтла и прогресса просмотра; добавление и удаление тайтлов из списка; Repository с mock-тайтлами, эпизодами, профилем и прогрессом просмотра.
- **L5:** интеграция с backend-ом: регистрация и JWT-аутентификация через /api/auth/register, /api/auth/login, /api/auth/refresh, /api/auth/me; каталог и поиск через /api/titles, /api/titles/{slug}, /api/search/titles; получение эпизодов и HLS-видео через /api/episodes/{episodeId} и /api/playback/...; синхронизация прогресса через /api/progress/...; работа со списком просмотра через /api/watchlist; профиль пользователя, комментарии и рейтинги через /api/users, /api/comments и /api/ratings.
- **L6:** локальный кэш каталога и данных тайтлов для offline-режима, сохранение списка просмотра и прогресса локально, восстановление состояния после перезапуска приложения, тесты и release-сборка; дополнительная интеграция совместного просмотра через /api/watch-party, MyAnimeList через /api/integrations/mal, а также Premium и

## Модель данных backend:

User(id, email, nickname, role), Title(id, slug, name, description, posterUrl, bannerUrl, status, ageRating, genres), Season(id, titleId, number, name), Episode(id, seasonId, number, name, description, durationSec, releaseAt), WatchProgress(id, userId, episodeId, positionSec, durationSec, completed), WatchlistItem(id, userId, titleId), Comment(id, userId, titleId, episodeId, parentId, body), Rating(id, userId, titleId, value).

## Endpoint-ы:

GET /api/titles, GET /api/titles/{slug}, GET /api/episodes/{id}, GET /api/search/titles; GET/POST /api/progress/episodes/{id}; GET /api/watchlist, POST/DELETE /api/watchlist/titles/{id}; GET/POST /api/comments/titles/{id}, GET/POST /api/comments/episodes/{id}; GET/PUT /api/ratings/titles/{id}; GET /api/playback/episodes/{id}/manifest. Аутентификация: POST /api/auth/register, POST /api/auth/login, POST /api/auth/refresh, GET /api/auth/me, POST /api/auth/logout. Защищённые endpoint-ы используют Authorization: Bearer {accessToken}.
