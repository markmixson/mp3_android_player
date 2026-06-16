import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mp3_android_player/models/haptic_mode.dart';
import 'package:mp3_android_player/models/player_status.dart';
import 'package:mp3_android_player/providers.dart';
import 'package:mp3_android_player/providers/player_notifier.dart';
import 'package:mp3_android_player/services/preference_service_interface.dart';

String formatDuration(final Duration duration) {
  final minutes = duration.inMinutes;
  final seconds = duration.inSeconds % 60;
  return '$minutes:${seconds.toString().padLeft(2, '0')}';
}

Widget getMainScreen(
  final BuildContext context,
  final WidgetRef ref,
  final PreferenceService prefs,
) {
  final state = ref.watch(playerNotifierProvider);
  final notifier = ref.watch(playerNotifierProvider.notifier);
  final defaultAudioPlayerService = ref.read(defaultAudioPlayerServiceProvider);
  final hapticAudioPlayerService = ref.read(hapticAudioPlayerServiceProvider);
  final currentAudioPlayerService = prefs.getHapticMode() == HapticMode.enabled
      ? hapticAudioPlayerService
      : defaultAudioPlayerService;
  return state.isLoading
      ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(padding: EdgeInsets.only(bottom: 10.0),),
            Text(
              state.currentFile != null
                  ? "Loading ${state.currentFile!.name}..."
                  : "Loading...",
            ),
          ],
        )
      : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (state.currentFile != null) ...[
              Text(
                'Now Playing: ${state.currentFile!.name}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              StreamBuilder<Duration>(
                stream: currentAudioPlayerService.positionStream,
                builder: (context, snapshot) {
                  final position = snapshot.data ?? Duration.zero;
                  return Column(
                    children: [
                      StreamBuilder<Duration>(
                        stream: currentAudioPlayerService.durationStream,
                        builder: (context, snapshot) {
                          final duration = snapshot.data ?? Duration.zero;
                          final double current = position.inSeconds.toDouble();
                          final double total = duration.inSeconds.toDouble();

                          return Slider(
                            value: current.clamp(0.0, total),
                            onChanged: (val) async {
                              return currentAudioPlayerService.seek(
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
                Switch(
                  value: prefs.getHapticMode() == HapticMode.enabled,
                  onChanged: (bool value) async {
                    return notifier.toggleHapticMode(
                      value ? HapticMode.enabled : HapticMode.disabled,
                      prefs,
                    );
                  },
                ),
                const Text('Haptic Mode'),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.file_present),
                  onPressed: () async => notifier.pickAndPlayFile(prefs),
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
        );
}
