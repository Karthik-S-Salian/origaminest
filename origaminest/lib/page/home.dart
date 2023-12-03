import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:origaminest/page/category.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Home extends StatefulWidget {
  const Home({super.key, required this.title, required this.camera});

  final String title;
  final CameraDescription camera;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late Future<List<_Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
  }

  Future<List<_Category>> fetchCategories() async {
    final response =
        await http.get(Uri.parse('${dotenv.env['BACKEND_BASE_URL']}/classes'));

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return _Category.fromJsonList(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load album ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<_Category>>(
          future: futureCategories,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Column(
                children: [
                  for (final category in snapshot.data!) Text(category.category)
                ],
              );
            } else if (snapshot.hasError) {
              return Text('${snapshot.error}');
            }

            // By default, show a loading spinner.
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FutureBuilder<List<_Category>>(
        future: futureCategories,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return FloatingActionButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => CategoryScreen(
                      camera: widget.camera,
                      categories:
                          snapshot.data!.map((e) => e.category).toList(),
                    ),
                  ),
                );
              },
              tooltip: 'scan',
              child: const Icon(Icons.camera_alt_outlined),
            );
          } else if (snapshot.hasError) {
            return const FloatingActionButton(onPressed: null);
          }

          // By default, show a loading spinner.
          return const FloatingActionButton(onPressed: null);
        },
      ),
    );
  }
}

class _Category {
  final String category;
  final List<String> classes;

  const _Category({
    required this.category,
    required this.classes,
  });

  factory _Category.fromJson(Map<String, dynamic> json) {
    try {
      return _Category(
        category: json['category'] as String,
        classes: List<String>.from(json['classes'] as List),
      );
    } catch (e) {
      print('Exception during Category.fromJson: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  static List<_Category> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => _Category.fromJson(json)).toList();
  }
}
