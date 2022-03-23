// To parse this JSON data, do
//
//     final moviesByGenre = moviesByGenreFromMap(jsonString);

import 'dart:convert';

import 'models.dart';

class MoviesByGenre {
  MoviesByGenre({
    required this.page,
    required this.results,
    required this.totalPages,
    required this.totalResults,
  });

  int page;
  List<Movie> results;
  int totalPages;
  int totalResults;

  factory MoviesByGenre.fromJson(String str) =>
      MoviesByGenre.fromMap(json.decode(str));

  factory MoviesByGenre.fromMap(Map<String, dynamic> json) => MoviesByGenre(
        page: json["page"],
        results: List<Movie>.from(json["results"].map((x) => Movie.fromMap(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );
}
