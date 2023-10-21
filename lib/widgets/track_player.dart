import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class TrackPlayer extends StatefulWidget {
  final AudioPlayer player = AudioPlayer();

  TrackPlayer({super.key, required String trackSource}) {
    player.setUrl(trackSource).then((value) => print(value));
  }

  @override
  State<TrackPlayer> createState() {
    return _TrackPlayerState();
  }

}

class _TrackPlayerState extends State<TrackPlayer> {
  Duration? currentPosition;

  @override
  void initState() {
    print("Creating State");
    widget.player.positionStream.listen(
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
    widget.player.playbackEventStream.listen(
      (event) {
        print("Playback: $event");
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          style: Theme.of(context).elevatedButtonTheme.style,
          icon: Icon(
            widget.player.playing ? Icons.pause : Icons.play_arrow,
          ),
          onPressed: () {
            if (widget.player.playing) {
              widget.player.pause().then(
                    (value) => setState(
                      () {
                        print(widget.player.playing);
                      },
                    ),
                  );
            } else {
              widget.player.play();
              setState(
                () {
                  print(widget.player.playing);
                },
              );
            }
          },
        ),
        Expanded(
          child: Slider(
            value: currentPosition?.inMilliseconds.toDouble() ?? 0,
            min: 0,
            max: widget.player.duration?.inMilliseconds.toDouble() ?? 1,
            onChanged: (value) {
              widget.player.seek(Duration(milliseconds: value.toInt()));
            },
          ),
        ),
        const SizedBox(
          width: 20,
        ),
        Text(
            "${(currentPosition?.inMinutes ?? 0).toString().padLeft(2, '0')}:${(currentPosition?.inSeconds ?? 0 / Duration.secondsPerMinute).toString().padLeft(2, '0')}/${(widget.player.duration?.inMinutes ?? 0).toString().padLeft(2, '0')}:${((widget.player.duration?.inSeconds ?? 0) % Duration.secondsPerMinute).toString().padLeft(2, '0')}")
      ],
    );
  }

  @override
  void dispose() {
    widget.player.stop();
    super.dispose();
  }
}
