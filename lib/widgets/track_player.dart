import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TrackPlayer extends StatefulWidget {
  final String trackSource;

  const TrackPlayer({super.key, required this.trackSource});

  @override
  State<TrackPlayer> createState() {
    return _TrackPlayerState();
  }
}

class _TrackPlayerState extends State<TrackPlayer> {
  Duration? duration;
  Duration? currentPosition;
  final AudioPlayer player = AudioPlayer();

  @override
  void initState() {
    super.initState();

    player.setUrl(widget.trackSource).then((totalDuration) {
      if (mounted) {
        setState(() {
          duration = totalDuration;
        });
      }

      player.positionStream.listen(
        (event) {
          if (kDebugMode) {
            print("Time: $event");
          }
          if (mounted) {
            setState(
              () {
                currentPosition = event;
              },
            );
          }
        },
      );
      player.playbackEventStream.listen(
        (event) {
          print("Playback: $event");
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          icon: Icon(
            player.playing ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            if (player.playing) {
              player.pause().then(
                    (value) => setState(
                      () {
                        if (kDebugMode) {
                          print(player.playing);
                        }
                      },
                    ),
                  );
            } else {
              player.play().then(
                    (value) => setState(
                      () {
                        if (kDebugMode) {
                          print(player.playing);
                        }
                      },
                    ),
                  );
            }
          },
        ),
        Expanded(
          child: Slider(
            value: min(currentPosition?.inMilliseconds.toDouble() ?? 0,
                duration?.inMilliseconds.toDouble() ?? 0),
            min: 0,
            max: duration?.inMilliseconds.toDouble() ?? 1,
            onChanged: (value) {
              player.seek(Duration(milliseconds: value.toInt())).then(
                (_) {
                  if (duration != null) {
                    setState(() {
                      currentPosition = Duration(milliseconds: value.toInt());
                    });
                  }
                },
              );
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
            "${(currentPosition?.inMinutes ?? 0).toString().padLeft(2, '0')}:${((currentPosition?.inSeconds ?? 0) % Duration.secondsPerMinute).toString().padLeft(2, '0')}/${(duration?.inMinutes ?? 0).toString().padLeft(2, '0')}:${((duration?.inSeconds ?? 0) % Duration.secondsPerMinute).toString().padLeft(2, '0')}")
      ],
    );
  }

  @override
  void dispose() {
    player.stop();
    super.dispose();
  }
}
