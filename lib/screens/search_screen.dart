import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/api_client.dart';
import '../data/result.dart';
import '../data/search_api.dart';
import '../domain/anime_title.dart';
import '../models/catalog_model.dart';
import '../router_names.dart';
import '../widgets/error_view.dart';
import '../widgets/title_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();

  late final SearchApi _searchApi;

  Timer? _debounce;
  int _requestVersion = 0;

  String _query = '';
  String _selectedGenre = 'Все';

  bool _isSearching = false;
  String? _searchError;
  List<AnimeTitle> _searchResults = const [];

  static const _genres = [
    'Все',
    'Action',
    'Fantasy',
    'Drama',
    'Sci-Fi',
    'Adventure',
  ];

  @override
  void initState() {
    super.initState();
    _searchApi = SearchApi(context.read<ApiClient>());
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();

    // Сразу делаем предыдущие запросы неактуальными,
    // включая время ожидания перед новым запросом.
    final version = ++_requestVersion;
    final query = value.trim();

    setState(() {
      _query = query;
      _searchError = null;
      _searchResults = const [];
      _isSearching = query.isNotEmpty;
    });

    if (query.isEmpty) {
      return;
    }

    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => _search(query, version),
    );
  }

  Future<void> _search(String query, int version) async {
    final result = await _searchApi.search(query);

    if (!mounted || version != _requestVersion) {
      return;
    }

    setState(() {
      switch (result) {
        case Ok(:final value):
          _searchResults = value;

        case Err(:final msg):
          _searchError = msg;
      }

      _isSearching = false;
    });
  }

  void _clearSearch() {
    _controller.clear();
    _onQueryChanged('');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _requestVersion++;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    final hasQuery = _query.isNotEmpty;

    final isLoading = hasQuery
        ? _isSearching
        : catalog.isLoading;

    final error = hasQuery
        ? _searchError
        : catalog.error;

    final titles = hasQuery
        ? _searchResults
        : catalog.titles;

    Widget content;

    if (isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    } else if (error != null) {
      content = ErrorView(
        message: error,
        onRetry: () {
          if (hasQuery) {
            _onQueryChanged(_controller.text);
          } else {
            context.read<CatalogModel>().load();
          }
        },
      );
    } else {
      final filteredTitles = titles.where((anime) {
        if (_selectedGenre == 'Все') {
          return true;
        }

        return anime.genres.isEmpty
            ? anime.genre == _selectedGenre
            : anime.genres.contains(_selectedGenre);
      }).toList();

      if (filteredTitles.isEmpty) {
        content = const Center(
          child: Text('Ничего не найдено'),
        );
      } else {
        content = GridView.builder(
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: filteredTitles.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, index) {
            final result = filteredTitles[index];

            // В ответе поиска нет года и рейтинга MAL.
            // Если тайтл уже загружен в каталог,
            // используем его полные данные для карточки.
            final anime =
                catalog.bySlug(result.slug) ?? result;

            return TitleCard(
              anime: anime,
              onTap: () {
                FocusScope.of(context).unfocus();

                context.pushNamed(
                  RouteNames.titleDetails,
                  pathParameters: {'slug': anime.slug},
                );
              },
            );
          },
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Поиск')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              controller: _controller,
              hintText: 'Найти аниме...',
              leading: const Icon(Icons.search),
              onChanged: _onQueryChanged,
              trailing: [
                if (_controller.text.isNotEmpty)
                  IconButton(
                    tooltip: 'Очистить поиск',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final genre = _genres[index];

                return FilterChip(
                  label: Text(genre),
                  selected: _selectedGenre == genre,
                  onSelected: (_) {
                    setState(() {
                      _selectedGenre = genre;
                    });
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Expanded(child: content),
        ],
      ),
    );
  }
}