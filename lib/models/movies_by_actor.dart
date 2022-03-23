// To parse this JSON data, do
//
//     final moviesByActor = moviesByActorFromMap(jsonString);

import 'dart:convert';

import 'package:peliculas/models/models.dart';

class MoviesByActor {
  MoviesByActor({
    required this.cast,
    required this.crew,
    required this.id,
  });

  List<Movie> cast;
  List<Movie> crew;
  int id;

  factory MoviesByActor.fromJson(String str) =>
      MoviesByActor.fromMap(json.decode(str));

  factory MoviesByActor.fromMap(Map<String, dynamic> json) => MoviesByActor(
        cast: List<Movie>.from(json["cast"].map((x) => Movie.fromMap(x))),
        crew: List<Movie>.from(json["crew"].map((x) => Movie.fromMap(x))),
        id: json["id"],
      );
}
