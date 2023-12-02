import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  // Example asynchronous operation that returns a Future<String>
  Future<String> fetchData() async {
    // Simulate a delay
    await Future.delayed(Duration(seconds: 2));

    // Return some data
    return 'Data from async operation';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Async FloatingActionButton'),
      ),
      body: FutureBuilder<String>(
        future: fetchData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.active:
            case ConnectionState.waiting:
              return Center(
                child: CircularProgressIndicator(),
              );
            case ConnectionState.done:
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Result: ${snapshot.data}'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: snapshot.hasData
                          ? () {
                              // Navigate to another page with the async data
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      AnotherPage(data: snapshot.data!),
                                ),
                              );
                            }
                          : null,
                      child: Text('Navigate to Another Page'),
                    ),
                  ],
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null, // Initially disabled
        child: Icon(Icons.refresh),
      ),
    );
  }
}

class AnotherPage extends StatelessWidget {
  final String data;

  const AnotherPage({Key? key, required this.data}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another Page'),
      ),
      body: Center(
        child: Text('Data from the first page: $data'),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: MyPage(),
  ));
}
