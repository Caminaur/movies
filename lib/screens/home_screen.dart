import 'package:flutter/material.dart';

import 'package:peliculas/widgets/widgets.dart';
import 'package:provider/provider.dart';

import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/search/search_delegate.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final moviesProvider = Provider.of<MoviesProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Peliculas en cines'),
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.search_outlined),
              onPressed: () =>
                  showSearch(context: context, delegate: MovieSearchDelegate()),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // targetas principales
              CardSwiper(movies: moviesProvider.onDisplayMovies),

              // slider de peliculas
              MovieSlider(
                movies: moviesProvider.popularMovies,
                titulo: 'Populares!',
                onNextPage: () => moviesProvider.getPopularMovies(),
              ),
              // final List genresId = [16, 35, 80, 99, 18];

              MovieSlider(
                movies: moviesProvider.animationResults,
                titulo: 'Animadas',
                onNextPage: () => moviesProvider.getAnimatedMovies(16),
              ),
              MovieSlider(
                movies: moviesProvider.comedyResults,
                titulo: 'Comedias',
                onNextPage: () => moviesProvider.getComedyMovies(99),
              ),
              // MovieSlider(
              //   movies: moviesProvider.comedyResults,
              //   titulo: 'Comedias',
              //   onNextPage: () => moviesProvider.getComedyMovies(99),
              // ),
            ],
          ),
        ));
  }
}
