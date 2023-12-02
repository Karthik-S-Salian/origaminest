import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:origaminest/page/display_picture_screen.dart';

class CategoryScreen extends StatelessWidget {
  final CameraDescription camera;
  final List<String> categories;
  const CategoryScreen(
      {super.key, required this.camera, required this.categories});

  void onPress(BuildContext context, String category) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Center(
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _pickImageFromCamera(context, category);
                    },
                    child: const Text("From Camera"),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      _pickImageFromGallery(context, category);
                    },
                    child: const Text("From Gallery"),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void navigateToNext(BuildContext context, String path, String category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(
          imagePath: path,
          category: category,
        ),
      ),
    );
  }

  Future<void> _pickImageFromGallery(
      BuildContext context, String category) async {
    await ImagePicker()
        .pickImage(source: ImageSource.gallery)
        .then((returnedImage) {
      if (returnedImage == null) return;

      navigateToNext(context, returnedImage.path, category);
    });
  }

  Future<void> _pickImageFromCamera(
      BuildContext context, String category) async {
    await ImagePicker()
        .pickImage(source: ImageSource.camera)
        .then((returnedImage) {
      if (returnedImage == null) return;
      navigateToNext(context, returnedImage.path, category);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select the category')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final category in categories)
              ElevatedButton(
                  onPressed: () => {onPress(context, category)},
                  child: Text(category)),
          ],
        ),
      ),
    );
  }
}
