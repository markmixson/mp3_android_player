import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/player_app.dart';

void main() async {
  runApp(ProviderScope(child: const PlayerApp()));
}
