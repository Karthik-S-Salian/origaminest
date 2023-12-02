import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:origaminest/page/category_screen.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.camera});

  final String title;
  final CameraDescription camera;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<Category>> futureCategories;

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: FutureBuilder<List<Category>>(
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
      floatingActionButton: FutureBuilder<List<Category>>(
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

class Category {
  final String category;
  final List<String> classes;

  const Category({
    required this.category,
    required this.classes,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // try {
    //   return switch (json) {
    //     {
    //       'category': String category,
    //       'classes': List<String> classes,
    //     } =>
    //       Category(
    //         category: category,
    //         classes: classes,
    //       ),
    //     _ => throw const FormatException('Failed to load data.'),
    //   };
    // } catch (e) {
    //   print('Exception during Album.fromJson: $e');
    //   print('Problematic JSON: $json');
    //   rethrow;
    // }

    try {
      return Category(
        category: json['category'] as String,
        classes: List<String>.from(json['classes'] as List),
      );
    } catch (e) {
      print('Exception during Category.fromJson: $e');
      print('Problematic JSON: $json');
      rethrow;
    }
  }

  static List<Category> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) => Category.fromJson(json)).toList();
  }
}

Future<List<Category>> fetchCategories() async {
  final response = await http.get(Uri.parse('http://192.168.1.2:8000/classes'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Category.fromJsonList(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load album ${response.statusCode}');
  }
}

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  // Example asynchronous operation that returns a Future<String>
  Future<String> fetchData() async {
    // Simulate a delay
    await Future.delayed(const Duration(seconds: 2));

    // Return some data
    return 'Data from async operation';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Async FloatingActionButton'),
      ),
      body: const Center(
        child: Text('Content of your page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show a Snackbar while the async operation is in progress
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Performing an async operation...'),
            ),
          );

          // Use FutureBuilder to handle the asynchronous operation
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return FutureBuilder<String>(
                future: fetchData(),
                builder: (context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.active:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      }
                      return Center(
                        child: Text('Result: ${snapshot.data}'),
                      );
                  }
                },
              );
            },
          );
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
