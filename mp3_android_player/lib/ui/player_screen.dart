import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/providers/player_notifier.dart';

String formatDuration(final Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final state = ref.watch(playerNotifierProvider);
    final notifier = ref.read(playerNotifierProvider.notifier);
    final audioPlayerService = ref.read(audioPlayerServiceProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('MP3 Player')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.currentFile != null) ...[
              Text(
                'Now Playing: ${state.currentFile!.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              StreamBuilder<Duration>(
                stream: audioPlayerService.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      StreamBuilder<Duration>(
                        stream: audioPlayerService.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          final double current = position.inSeconds.toDouble();
                          final double total = duration.inSeconds.toDouble();

                          return Slider(
                            value: current.clamp(0.0, total),
                            onChanged: (val) {
                              audioPlayerService.seek(
                                Duration(seconds: val.toInt()),
                              );
                            },
                            min: 0.0,
                            max: total,
                          );
                        },
                      ),
                      Text(formatDuration(position)),
                    ],
                  );
                },
              ),
            ] else
              const Text('No file selected'),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.file_present),
                  onPressed: () async => notifier.pickAndPlayFile(),
                  enableFeedback: false,
                ),
                IconButton(
                  icon: Icon(
                    state.status == PlaybackStatus.playing
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                  onPressed: state.currentFile != null 
                      ? () async => notifier.togglePlayPause() 
                      : null,
                  enableFeedback: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
