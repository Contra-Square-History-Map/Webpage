import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../proto/recording_messages.pb.dart';
import '../providers/release_provider.dart';
import '../providers/selected_release_provider.dart';
import '../routes.dart';
import 'comment.dart';
import 'track_player.dart';

class ReleaseSummary extends ConsumerWidget {
  const ReleaseSummary({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final releaseDetails = ref.watch(releaseProvider(id)).valueOrNull;

    final sample = releaseDetails?.samples.first;

    final playerWidget = (sample != null)
        ? Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(sample.title),
              SizedBox(
                width: 400,
                height: 50,
                child: TrackPlayer(
                  trackSource:
                      Uri.https(assetsHost, audio + sample.url).toString(),
                ),
              ),
            ],
          )
        : SizedBox(
            width: 400,
            height: 50,
            child: Container(
              color: Colors.orange,
              child: const Text("Error loading track"),
            ),
          );
    final image = releaseDetails?.images.first;
    final imageWidget = (image != null)
        ? Image.network(Uri.https(assetsHost, images + image).toString())
        : SizedBox(
            width: 400,
            height: 50,
            child: Container(
              color: Colors.orange,
            ),
          );

    final musicianContributions = <String, List<String>>{};

    for (var contribution
        in (releaseDetails?.contributions ?? <Contribution>[])) {
      final musician = contribution.musician;
      final name = "${musician.firstName} ${musician.lastName}";
      musicianContributions.putIfAbsent(name, () => <String>[]);
      musicianContributions[name]?.add(contribution.instrument);
    }

    final contributionsList =
        musicianContributions.entries.map<Widget>((musicianContribution) {
      final musician = musicianContribution.key;
      final instruments = musicianContribution.value;

      final contribution = StringBuffer();

      contribution.write(musician);
      contribution.write(": ");
      contribution.writeAll(instruments, ", ");

      return RichText(
        text: TextSpan(
          text: contribution.toString(),
        ),
      );
    }).toList();

    final commentsList = releaseDetails?.comments
            .map<Widget>(
              (comment) => Comment(
                  commentAuthor: comment.author, commentText: comment.text),
            )
            .toList() ??
        [
          RichText(
            text: const TextSpan(text: "No Comments"),
          )
        ];

    return (releaseDetails == null)
        ? ConstrainedBox(
            constraints: const BoxConstraints.expand(),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        : SingleChildScrollView(
            controller: ScrollController(),
            child: SelectionArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    Text(
                      releaseDetails.band,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      "${releaseDetails.title}  (${DateTime.fromMillisecondsSinceEpoch(releaseDetails.releaseTime.toInt(), isUtc: true).year})",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(releaseDetails.location),
                    RichText(
                      text: TextSpan(
                        text: "Released on:",
                        children: [
                          TextSpan(
                            text: (releaseDetails.cassetteRelease)
                                ? " Cassette"
                                : "",
                          ),
                          TextSpan(
                            text: (releaseDetails.lpRelease) ? " LP" : "",
                          ),
                          TextSpan(
                            text: (releaseDetails.cdRelease) ? " CD" : "",
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    Text(
                      "Musicians",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...contributionsList,
                    const Divider(),
                    Text(
                      "Sample",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    playerWidget,
                    const Divider(),
                    Text(
                      "Notes",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ...commentsList,
                    const Divider(),
                    Text(
                      "Images",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    imageWidget,
                  ],
                ),
              ),
            ),
          );
  }
}

class ReleaseSummaryCard extends ConsumerWidget {
  const ReleaseSummaryCard({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          ReleaseSummary(id: id),
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                ref.read(selectedReleaseProvider.notifier).state = null;
              },
            ),
          ),
        ],
      ),
    );
  }
}
