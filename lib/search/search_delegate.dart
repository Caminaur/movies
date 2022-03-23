import 'package:flutter/material.dart';
import 'package:peliculas/models/models.dart';

import 'package:peliculas/providers/movies_provider.dart';
import 'package:peliculas/models/movie.dart';
import 'package:provider/provider.dart';

class MovieSearchDelegate extends SearchDelegate {
  final int? actorId;
  List<Movie>? moviesByActor;
  final int? actor1;

  // ignore: avoid_init_to_null
  MovieSearchDelegate([
    this.actorId,
    this.moviesByActor,
    this.actor1,
  ]);

  @override
  String get searchFieldLabel => 'Buscar';
  @override
  List<Widget> buildActions(BuildContext context) {
    MoviesProvider moviesProvider = Provider.of<MoviesProvider>(context);
    // query = '';

    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = '';
            moviesProvider.resetMoviesByActor();
            moviesProvider.setQuery(false);
            moviesProvider.setQuery(true);
          }),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(
          context,
          null,
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(
      child: Image(
        fit: BoxFit.cover,
        image: AssetImage('assets/no-image.jpg'),
      ),
    );
  }

  Widget _emptyContainer() {
    return Container(
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: Colors.black38,
          size: 180.0,
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final MoviesProvider moviesProvider =
        Provider.of<MoviesProvider>(context, listen: true);
    if (query.isEmpty && actorId == null) {
      return _emptyContainer();
    }
    if (moviesProvider.queryInfo == false) {
      return _emptyContainer();
    }
    if (actorId == null) {
      moviesProvider.getSuggestionByQuery(query);
      return StreamBuilder(
        stream: moviesProvider.suggestionStream,
        builder: (_, AsyncSnapshot<List<Movie>> snapshot) {
          if (!snapshot.hasData) return _emptyContainer();

          final movies = snapshot.data!;

          return ListView.builder(
            itemCount: movies.length,
            itemBuilder: (_, index) => _MovieItem(movies[index]),
          );
        },
      );
    } else if (actorId != null && moviesProvider.moviesByActor != []) {
      moviesProvider.getMoviesByActor(actorId!);
      this.moviesByActor = moviesProvider.moviesByActor;
      return ListView.builder(
        itemCount: this.moviesByActor!.length,
        itemBuilder: (_, index) => _MovieItem(this.moviesByActor![index]),
      );
    } else {
      return _emptyContainer();
    }
  }
}

class _MovieItem extends StatelessWidget {
  final Movie movie;

  const _MovieItem(this.movie);

  @override
  Widget build(BuildContext context) {
    movie.heroId = 'search-${movie.id}';

    return ListTile(
      leading: Hero(
        tag: movie.heroId!,
        child: FadeInImage(
          placeholder: AssetImage('assets/no-image.jpg'),
          image: NetworkImage(movie.fullPosterMovie),
          width: 50,
          fit: BoxFit.contain,
        ),
      ),
      title: Text(
        movie.title,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        movie.originalTitle,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          'details',
          arguments: movie,
        );
      },
    );
  }
}
