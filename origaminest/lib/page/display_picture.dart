import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:origaminest/page/video_player.dart';

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String category;

  const DisplayPictureScreen(
      {super.key, required this.imagePath, required this.category});

  Future<(String?, String?)> _sendImageToServer(File? imageFile) async {
    try {
      if (imageFile == null) {
        throw Exception('Image file is null');
      }
      //showLoadingDialog(context); // Show loading indicator
      final uri = Uri.parse('${dotenv.env['BACKEND_BASE_URL']}/predict');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(http.MultipartFile(
            'image', imageFile.readAsBytes().asStream(), imageFile.lengthSync(),
            filename: "image" //basename(imageFile.path),
            ))
        ..fields.addAll({"category": category});

      final response = await http.Response.fromStream(await request.send());

      if (response.statusCode != 200) {
        throw Exception('response status not good');
      }

      print(response.body);
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data["videoUrl"]);
      return (data["videoUrl"].toString(), data["cls"].toString());
    } catch (e) {
      print('Error: $e');
      return (null, null);
      //showErrorDialog(context, 'Error sending image to server');
    } finally {
      //Navigator.pop(context); // Dismiss loading indicator
    }
  }

  void navigateToNext(BuildContext context, String videoUrl, String cls) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (context) => VideoPlayerScreen(
                videoUrl: videoUrl,
                cls: cls,
              )),
    );
  }

  void onPress(BuildContext context) async {
    final (videoUrl, cls) = await _sendImageToServer(File(imagePath));
    if (videoUrl != null && cls != null) {
      navigateToNext(context, videoUrl, cls);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text(category)),
        body: Column(
          children: [
            Expanded(
              child: Image(
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
            ),
            ElevatedButton(
              onPressed: () => {onPress(context)},
              child: const Text("Upload"),
            ),
          ],
        ));
  }
}
