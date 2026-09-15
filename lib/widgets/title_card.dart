import 'package:flutter/material.dart';
import '../data/mock_data.dart';


class TitleCard extends StatelessWidget {
  final AnimeTitle anime;
  final VoidCallback? onTap;

  const TitleCard({
    super.key,
    required this.anime,
    this.onTap

  });


  @override
  Widget build(BuildContext context) {
    final scheme =Theme.of(context).colorScheme;
    
    return  SizedBox(
      width:150,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Container(
              height:120,
              width: double.infinity,
              color: scheme.primaryContainer,
              child:Icon(
                Icons.movie_outlined,
                size:64,
                color: scheme.onPrimaryContainer,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    anime.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),

                  const SizedBox(height: 6),

                  Text(
                    '${anime.year} · ${anime.genre}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size:16,
                      ),
                      const  SizedBox(width:4),
                      Text(
                        anime.rating.toString(),
                        style: Theme.of(context).textTheme.bodySmall,
                      )
                    ]
                  )

                ], // children внутреннего Column
              ), // внутренний Column
            ), // Padding
          ], // children внешнего Column
        ), // внешний Column
      ), // Card
      ),
    ); // SizedBox
  } // build
} // TitleCard