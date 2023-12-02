import 'dart:io';
import 'package:flutter/material.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String category;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category)),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image(
        image: FileImage(File(imagePath)),
        width: double.infinity,
        height: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            debugPrint('image loading null');
            return child;
          }
          debugPrint('image loading...');
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
