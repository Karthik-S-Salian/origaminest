import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'page/my_home_page.dart';

Future<void> main() async {
  // Ensure that plugin services are initialized so that `availableCameras()`
  // can be called before `runApp()`
  WidgetsFlutterBinding.ensureInitialized();

  // Obtain a list of the available cameras on the device.
  final cameras = await availableCameras();

  // Get a specific camera from the list of available cameras.
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: App(camera: firstCamera),
    ),
  );
}

class App extends StatelessWidget {
  final CameraDescription camera;

  const App({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MyHomePage(
      title: 'Flutter Demo Home Page',
      camera: camera,
    );
  }
}
