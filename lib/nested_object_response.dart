import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_networking/model/movie.dart';
import 'package:http/http.dart' as http;

class NestedObjectResponse extends StatefulWidget {
  final String title;

  const NestedObjectResponse({Key key, this.title}) : super(key: key);
  @override
  _ArrayResponseState createState() => _ArrayResponseState();
}

class _ArrayResponseState extends State<NestedObjectResponse> {
  Future<List<Movie>> futureMovies;
  /*
* Although it’s convenient, it’s not recommended to put an API call in a build() method.

Flutter calls the build() method every time it needs to change anything in the view,
*  and this happens surprisingly often.
*  Leaving the fetch call in your build() method floods the API with unnecessary calls
* and slows down your app.
* https://flutter.dev/docs/cookbook/networking/fetch-data

*/
  @override
  void initState() {
    super.initState();
    futureMovies = fetchMovies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
     
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Movie>>(
        future: futureMovies,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final movies = snapshot.data;
            return ListView.builder(
                itemCount: movies.length,
                itemBuilder: (ctx, index) {
                  final movie = movies[index];
                  return Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Image.network(
                                movie.image,
                                width: 100,
                                fit: BoxFit.fill,
                              ),
                              Expanded(
                                  child: Container(
                                      padding: EdgeInsets.all(2),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Text(
                                            movie.title,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            "Released on  " +
                                                "${movie.releaseYear}",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          new Wrap(
                                              spacing: 3.0,
                                              runSpacing: 4.0,
                                              direction: Axis.horizontal,
                                              children: movie.genre
                                                  .map((e) =>
                                                      Chip(label: Text(e)))
                                                  .toList()),
                                        ],
                                      )))
                            ])),
                  );
                });
          } else if (snapshot.hasError) {
            return Center(
              child: Text(snapshot.error),
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

Future<List<Movie>> fetchMovies() async {
  final response =
      await http.get('https://api.androidhive.info/json/movies.json');
  if (response.statusCode == 200) {
    print(response.body);
    return movieFromJson(response.body);
  } else {
    throw Exception('FAILED TO LOAD POST');
  }
}
