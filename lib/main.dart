
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';
import 'package:file_picker/file_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(JustOneApp());

class JustOneApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Just One',
      theme: ThemeData(primarySwatch: Colors.orange),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => JustOneHome()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Just One',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = LinearGradient(
                colors: <Color>[Colors.red, Colors.orange, Colors.yellow, Colors.green, Colors.blue, Colors.purple],
              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
          ),
        ),
      ),
    );
  }
}

class JustOneHome extends StatefulWidget {
  @override
  _JustOneHomeState createState() => _JustOneHomeState();
}

class _JustOneHomeState extends State<JustOneHome> {
  String? directoryPath;
  File? selectedImage;
  List<File> images = [];
  final AudioPlayer audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _loadLastDirectory();
  }

  Future<void> _loadLastDirectory() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('lastDirectory');
    if (path != null && Directory(path).existsSync()) {
      setState(() {
        directoryPath = path;
        _loadImages();
      });
    }
  }

  Future<void> _pickDirectory() async {
    String? selected = await FilePicker.platform.getDirectoryPath();
    if (selected != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastDirectory', selected);
      setState(() {
        directoryPath = selected;
        _loadImages();
      });
    }
  }

  void _loadImages() {
    if (directoryPath == null) return;
    final dir = Directory(directoryPath!);
    final files = dir.listSync().whereType<File>().where((file) {
      final ext = file.path.toLowerCase();
      return ext.endsWith('.jpg') || ext.endsWith('.jpeg') || ext.endsWith('.png');
    }).toList();
    setState(() {
      images = files;
    });
  }

  void _showRandomImage() async {
    if (images.isNotEmpty) {
      final rand = Random().nextInt(images.length);
      await audioPlayer.play(AssetSource('shuffle.mp3'));
      setState(() {
        selectedImage = images[rand];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Just One'),
        actions: [
          IconButton(
            icon: Icon(Icons.folder_open),
            onPressed: _pickDirectory,
          ),
        ],
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showRandomImage,
            child: Text('Mostrar imagen aleatoria'),
          ),
          Expanded(
            child: selectedImage != null
                ? PhotoView(imageProvider: FileImage(selectedImage!))
                : Center(child: Text('Selecciona una carpeta para empezar')),
          ),
        ],
      ),
    );
  }
}
