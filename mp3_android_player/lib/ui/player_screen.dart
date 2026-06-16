import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';
import 'package:mp3_android_player/ui/player_screen_main.dart';

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final future = ref.read(preferenceServiceProvider.future);
    return Scaffold(
      appBar: AppBar(title: const Text('MP3 Player')),
      body: Center(
        child: FutureBuilder<PreferenceService?>(
          future: future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text(
                "Can't load preferences!  Error: ${snapshot.error} Trace: ${snapshot.stackTrace}",
              );
            } else if (snapshot.hasData) {
              return getMainScreen(context, ref, snapshot.data!);
            } else {
              return Text("Can't load preferences!");
            }
          },
        ),
      ),
    );
  }
}
