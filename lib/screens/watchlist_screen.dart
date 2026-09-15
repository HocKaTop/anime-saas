import 'package:flutter/material.dart';

import '../data/mock_data.dart';
import '../widgets/title_card.dart';
import './titile_details_screen.dart';


class WatchllistScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final watchlist = mockTitles.take(6).toList();
    return  Scaffold(
      appBar: AppBar(
        title: const Text("Мой список"),
      ),
      body:  Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text('${watchlist.length}  тайтлов',
          style: Theme.of(context).textTheme.bodyMedium,
          ),
          ),
          
          const SizedBox(height: 12,),
          
          SizedBox( 
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                FilterChip(label: const Text ("Все",), selected: true, onSelected: (_){}),
                FilterChip(label: const Text ("Смотрю",), selected: true, onSelected: (_){}),
                FilterChip(label: const Text ("Запланированные",), selected: true, onSelected: (_){}),
                FilterChip(label: const Text ("Просмотрено",), selected: true, onSelected: (_){}),
              ],
            ),
          ),
          Expanded(child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: watchlist.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.52
              ),
            itemBuilder:(context, index){
              return TitleCard(anime: watchlist[index],
              onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (_)=> TitileDetailsScreen(anime: watchlist[index])));
                  },
              );
            },
            ),
          )
        ],
      ),
    );
  }
}