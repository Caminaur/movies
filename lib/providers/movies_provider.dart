import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:peliculas/config/keys.dart';
import 'package:peliculas/helpers/debouncer.dart';
import 'package:peliculas/models/models.dart';
import 'package:peliculas/models/movies_by_actor.dart';
import 'package:peliculas/models/movies_by_genre_response.dart';

class MoviesProvider extends ChangeNotifier {
  String _apiKey = ApiKey;
  String _baseUrl = 'api.themoviedb.org';
  String _language = 'es-ES';

  List<Movie> onDisplayMovies = [];
  List<Movie> popularMovies = [];
  List<Movie> animationResults = [];
  List<Movie> comedyResults = [];

  Map<int, List<Movie>> controladorPeliculas = {};
  Map<int, int> contadorDePaginas = {};

  Map<int, Map<String, dynamic>> moviesControls = {};

  Map<int, List<Cast>> moviesCast = {};

  List<Movie> moviesByActor = [];

  int _popularPage = 0;
  int _animationPage = 0;
  int _comedyPage = 0;
  bool queryInfo = true;

  final debouncer = Debouncer(
    duration: Duration(milliseconds: 500),
    // onValue: (value){}
  );

  // ignore: close_sinks
  final StreamController<List<Movie>> _suggestionStreamController =
      new StreamController.broadcast();
  Stream<List<Movie>> get suggestionStream =>
      this._suggestionStreamController.stream;

  MoviesProvider() {
    this.getOnDisplayMovies();
    this.getPopularMovies();
    this.getAnimatedMovies(16);
    this.getComedyMovies(35);
  }
  void setQuery(booleano) {
    this.queryInfo = booleano;
    notifyListeners();
  }

  Future<String> _getJsonData(String endpoint, [page = 1, genre = 0]) async {
    if (genre != 0) {
      final url = Uri.https(
        _baseUrl,
        endpoint,
        {
          'api_key': _apiKey,
          'language': _language,
          'page': '$page',
          'with_genres': '$genre',
        },
      );
      final response = await http.get(url);
      return response.body;
    } else {
      final url = Uri.https(
        _baseUrl,
        endpoint,
        {
          'api_key': _apiKey,
          'language': _language,
          'page': '$page',
        },
      );
      final response = await http.get(url);
      return response.body;
    }
  }

  void getOnDisplayMovies() async {
    final jsonData = await this._getJsonData('3/movie/now_playing');
    final nowPlayingResponse = NowPlayingResponse.fromJson(jsonData);
    onDisplayMovies = nowPlayingResponse.results;
    // notifyListeners se encargara de decirle a todos los widgets de los cambios realizados para que se redibujen
    notifyListeners();
  }

  void getPopularMovies() async {
    _popularPage++;
    final jsonData = await this._getJsonData('3/movie/popular', _popularPage);
    final popularResponse = PopularResponse.fromJson(jsonData);
    popularMovies = [...popularMovies, ...popularResponse.results];
    // notifyListeners se encargara de decirle a todos los widgets de los cambios realizados para que se redibujen
    notifyListeners();
  }

  void getComedyMovies(int genreId) async {
    _comedyPage++;
    if (contadorDePaginas[genreId] == null) {
      contadorDePaginas[genreId] = 1;
    } else {
      contadorDePaginas[genreId] = contadorDePaginas[genreId]! + 1;
    }
    final jsonData = await this
        ._getJsonData('3/discover/movie', contadorDePaginas[genreId], genreId);
    final comedyResponse = MoviesByGenre.fromJson(jsonData);
    comedyResults = [...comedyResults, ...comedyResponse.results];
    notifyListeners();
  }

  void getAnimatedMovies(int genreId) async {
    _animationPage++;
    final jsonData =
        await this._getJsonData('3/discover/movie', _animationPage, genreId);
    final genreResponse = MoviesByGenre.fromJson(jsonData);
    animationResults = [...animationResults, ...genreResponse.results];
    // notifyListeners se encargara de decirle a todos los widgets de los cambios realizados para que se redibujen
    notifyListeners();
  }

  void getMoviesByActor(int actorId) async {
    final jsonData = await this._getJsonData('3/person/$actorId/movie_credits');
    final movies = MoviesByActor.fromJson(jsonData);

    moviesByActor = movies.cast;

    notifyListeners();
  }

  void resetMoviesByActor() {
    moviesByActor = [];
    notifyListeners();
  }

  Future<List<Cast>> getMovieCast(int movieId) async {
    if (moviesCast.containsKey(movieId)) return moviesCast[movieId]!;

    final jsonData = await this._getJsonData('3/movie/$movieId/credits');
    final creditsResponse = CreditsResponse.fromJson(jsonData);

    moviesCast[movieId] = creditsResponse.cast;

    return creditsResponse.cast;
  }

  Future<List<Movie>> searchMovies(String query) async {
    final url = Uri.https(
      _baseUrl,
      '3/search/movie',
      {
        'api_key': _apiKey,
        'language': _language,
        'query': query,
      },
    );
    final response = await http.get(url);
    final searchResponse = SearchResponse.fromJson(response.body);

    return searchResponse.results;
  }

  void getSuggestionByQuery(String searchTerm) {
    debouncer.value = '';
    debouncer.onValue = (value) async {
      final results = await this.searchMovies(value);
      this._suggestionStreamController.add(results);
    };

    final timer = Timer.periodic(Duration(milliseconds: 300), (_) {
      debouncer.value = searchTerm;
    });

    Future.delayed(Duration(milliseconds: 301)).then((_) => timer.cancel());
  }
}
