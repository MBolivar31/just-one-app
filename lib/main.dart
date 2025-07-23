
import 'dart:io';
import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  runApp(const JustOneApp());
}

class JustOneApp extends StatelessWidget {
  const JustOneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just One',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
      ),
      home: const JustOneViewer(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JustOneViewer extends StatefulWidget {
  const JustOneViewer({super.key});

  @override
  State<JustOneViewer> createState() => _JustOneViewerState();
}

class _JustOneViewerState extends State<JustOneViewer> {
  List<File> imageFiles = [];
  File? currentImage;
  String? folderPath;
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> selectFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      final dir = Directory(selectedDirectory);
      final images = dir
          .listSync()
          .where((f) => f.path.endsWith('.jpg') || f.path.endsWith('.png'))
          .map((f) => File(f.path))
          .toList();

      setState(() {
        folderPath = selectedDirectory;
        imageFiles = images;
        currentImage = null;
      });
    }
  }

  void showRandomImage() async {
    if (imageFiles.isEmpty) return;

    final random = Random();
    final image = imageFiles[random.nextInt(imageFiles.length)];

    await _audioPlayer.play(AssetSource("sounds/card_shuffle.mp3"));

    setState(() {
      currentImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Just One'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          if (currentImage != null)
            Expanded(
              child: PhotoView(
                imageProvider: FileImage(currentImage!),
                backgroundDecoration: const BoxDecoration(color: Colors.white),
              ),
            )
          else
            Expanded(
              child: Center(
                child: Text(
                  folderPath == null
                      ? 'Selecciona una carpeta para comenzar'
                      : 'Presiona el botón para mostrar una imagen',
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: selectFolder,
                  child: const Text('Seleccionar carpeta'),
                ),
                ElevatedButton(
                  onPressed: showRandomImage,
                  child: const Text('Mostrar imagen'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
