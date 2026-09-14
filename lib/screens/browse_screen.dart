import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../widgets/title_card.dart';

class BrowseScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Creepy Oleg"),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical:16),
        children:[
          _buildSection(
            context,
            title: 'Популярное сейчас',
            titles: mockTitles,
          ),

          const SizedBox( height:24),
          _buildSection(
            context,
            title: 'Новые релизы',
            titles: mockTitles.reversed.toList(),
          ),

          const SizedBox(height:24),
          _buildSection(
            context,
            title: 'Рекомендуем',
            titles: mockTitles,
          ),
        ],
      ),
    );
  }
  Widget _buildSection(
    BuildContext context, {
      required String title,
      required List<AnimeTitle> titles,
    }) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal:18),
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
              ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 300,
            child:ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal : 16),
              itemCount: titles.length,
              separatorBuilder:(context, index ){
                return const SizedBox(width: 8);
              },
              itemBuilder: (context, index){
                return TitleCard(
                  anime: titles[index],
                  );
              },
            )
          )
        ],
      );
    }
}