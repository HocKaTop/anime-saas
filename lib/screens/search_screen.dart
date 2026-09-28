import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/catalog_model.dart';
import '../router_names.dart';
import '../widgets/error_view.dart';
import '../widgets/title_card.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogModel>();
    Widget content;
    if (catalog.isLoading){
      content = const Center(
        child:CircularProgressIndicator(),
      );
    } else if (catalog.error != null){
      content= ErrorView(message: catalog.error!, onRetry: () { context.read<CatalogModel>().load();});
    } else {
      content = GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: catalog.titles.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          childAspectRatio: 0.52,
        ),
         itemBuilder:(context,index){
          final anime=catalog.titles[index];
          return TitleCard(anime: anime, onTap: (){
            context.pushNamed(RouteNames.titleDetails,
            pathParameters: {'slug':anime.slug,},);
          },);
         }
         );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Поиск")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: "Поиск",
              leading: const Icon(Icons.search),
              trailing: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
              ],
            ),
          ),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(
                  label: const Text("Все"),
                  selected: true,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Экшен"),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Фэнтези"),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Драма"),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text("Sci-Fi"),
                  selected: false,
                  onSelected: (_) {},
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: content,
          ),
        ],
      ),
    );
  }
}
