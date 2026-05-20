import 'package:flutter/material.dart';
import 'package:mp3_android_player/ui/player_screen.dart';

class PlayerApp extends StatelessWidget {
  const PlayerApp({super.key});

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(
      title: 'MP3 Player',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PlayerScreen(),
    );
  }
}
