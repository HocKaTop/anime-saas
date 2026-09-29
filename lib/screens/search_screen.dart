import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

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
  String _query = '';
  String _selectedGenre = 'Все';

  static const List<String> _genres = [
    'Все',
    'Action',
    'Fantasy',
    'Drama',
    'Sci-Fi',
    'Adventure',
  ];

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    Widget content;

    if (catalog.isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } else if (catalog.error != null) {
      content = ErrorView(
        message: catalog.error!,
        onRetry: () => context.read<CatalogModel>().load(),
      );
    } else {
      final query = _query.trim().toLowerCase();
      final filteredTitles = catalog.titles.where((anime) {
        final matchesQuery = anime.title.toLowerCase().contains(query);
        final matchesGenre =
            _selectedGenre == 'Все' || anime.genre == _selectedGenre;
        return matchesQuery && matchesGenre;
      }).toList();

      if (filteredTitles.isEmpty) {
        content = const Center(child: Text('Ничего не найдено'));
      } else {
        content = GridView.builder(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          itemCount: filteredTitles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.52,
          ),
          itemBuilder: (context, index) {
            final anime = filteredTitles[index];
            return TitleCard(
              anime: anime,
              onTap: () {
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
              hintText: 'Найти аниме...',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
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
