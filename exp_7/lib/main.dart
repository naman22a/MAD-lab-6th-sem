import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:share_plus/share_plus.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MultimediaApp(),
    );
  }
}

class MultimediaApp extends StatefulWidget {
  const MultimediaApp({super.key});

  @override
  State<MultimediaApp> createState() => _MultimediaAppState();
}

class _MultimediaAppState extends State<MultimediaApp> {
  final ImagePicker _picker = ImagePicker();

  File? _image;
  File? _video;

  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // 📸 Capture Image
  Future<void> captureImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  // 🎥 Record Video
  Future<void> recordVideo() async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.camera);
    if (pickedFile != null) {
      _video = File(pickedFile.path);

      _videoController?.dispose();
      _videoController = VideoPlayerController.file(_video!)
        ..initialize().then((_) {
          setState(() {});
          _videoController!.play();
        });
    }
  }

  // 🔊 Play Audio (from URL or local asset)
  Future<void> playAudio() async {
    await _audioPlayer.play(
      UrlSource(
          "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
    );
  }

  // 📤 Share File
  void shareFile() {
    if (_image != null) {
      Share.shareXFiles([XFile(_image!.path)]);
    } else if (_video != null) {
      Share.shareXFiles([XFile(_video!.path)]);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Multimedia App"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text("📸 Image",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _image != null
                  ? Image.file(_image!, height: 200)
                  : const Text("No image captured"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: captureImage,
                child: const Text("Capture Image"),
              ),
              const SizedBox(height: 20),
              const Text("🎥 Video",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              _videoController != null && _videoController!.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : const Text("No video recorded"),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: recordVideo,
                child: const Text("Record Video"),
              ),
              const SizedBox(height: 20),
              const Text("🔊 Audio",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: playAudio,
                child: const Text("Play Audio"),
              ),
              const SizedBox(height: 20),
              const Text("📤 Share",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton(
                onPressed: shareFile,
                child: const Text("Share Media"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
