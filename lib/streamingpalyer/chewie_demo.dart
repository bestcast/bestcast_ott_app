// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Chewie Video Player Example'),
        ),
        body: ChewieDemo1(),
      ),
    );
  }
}

class ChewieDemo1 extends StatefulWidget {
  const ChewieDemo1({super.key});

  @override
  _ChewieDemo1State createState() => _ChewieDemo1State();
}

class _ChewieDemo1State extends State<ChewieDemo1> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late Future<void> _initializeVideoPlayerFuture;
  @override
  void initState() {
    super.initState();
    _initializeVideoPlayerFuture = _initializeVideoPlayer();
    // _initializeVideoPlayer();
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController.dispose();
    _initializeVideoPlayerFuture.then((_) {
      final chewieController = _chewieController;
      chewieController.dispose();
    });
    super.dispose();
  }

  Future<void> _initializeVideoPlayer() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(
        "http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"));

    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      aspectRatio: 16 / 9,
      autoInitialize: true,
      looping: true,
      customControls: CustomControls(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeVideoPlayerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Chewie(controller: snapshot.data as ChewieController);
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}

class CustomControls extends StatelessWidget {
  const CustomControls({super.key});

  @override
  Widget build(BuildContext context) {
    final chewieController = ChewieController.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: Icon(Icons.fast_rewind),
              onPressed: () {
                final currentPosition =
                    chewieController.videoPlayerController.value.position;
                chewieController.seekTo(Duration(
                    seconds: currentPosition.inSeconds > 10
                        ? currentPosition.inSeconds - 10
                        : 0));
              },
            ),
            IconButton(
              icon: Icon(Icons.fast_forward),
              onPressed: () {
                final currentPosition =
                    chewieController.videoPlayerController.value.position;
                final duration =
                    chewieController.videoPlayerController.value.duration;
                chewieController.seekTo(Duration(
                    seconds: currentPosition.inSeconds + 10 < duration.inSeconds
                        ? currentPosition.inSeconds + 10
                        : duration.inSeconds));
              },
            ),
          ],
        ),
      ],
    );
  }
}
