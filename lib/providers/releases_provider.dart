import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../proto/recording_messages.pb.dart';
import '../routes.dart';
import 'filter_providers.dart';

final releasesProvider = FutureProvider<List<Recording>>(
  (ref) async {
    final query = ref.watch(releaseSearchTextProvider);

    final Map<String, dynamic> queryParameters = {};

    if (query.length > 2) {
      queryParameters["q"] = query;
    }

    var url = Uri.https(host, debugApi + releases, queryParameters);

    if (kDebugMode) {
      print("Loading releases from $url");
    }

    final response =
        await http.get(url, headers: {"Referrer-Policy": "no-referrer"});

    final decoded = jsonDecode(response.body);

    if (kDebugMode) {
      print("Request completed");
    }

    // parse RecordingListMessage from JSON
    final recordingListMessage = RecordingList.create();
    recordingListMessage.mergeFromProto3Json(decoded);

    if (kDebugMode) {
      print("Loaded ${recordingListMessage.recordings.length} recordings");
    }

    return recordingListMessage.recordings;
  },
);

final filteredReleasesProvider = FutureProvider<List<Recording>>((ref) {
  final searchWindow = ref.watch(releaseRangeProvider);
  final requiredInstruments = ref.watch(selectedInstrumentsProvider);

  final List<Recording> filteredReleases = ref.watch(releasesProvider).when(
        data: (data) {
          return data
              .where(
                (recording) {
                  final releaseYear = DateTime.fromMillisecondsSinceEpoch(
                          recording.releaseTime.toInt())
                      .year;
                  return releaseYear >= searchWindow.start &&
                      releaseYear <= searchWindow.end;
                },
              )
              .where(
                (release) => requiredInstruments.every(
                  (inst) => release.contributions
                      .any((contribution) => contribution.instrument == inst),
                ),
              )
              .where((release) =>
                  release.latitude.isFinite && release.longitude.isFinite)
              .toList(growable: false);
        },
        error: (error, trace) => [],
        loading: () => [],
        skipLoadingOnRefresh: false,
      );
  if (kDebugMode) {
    print("Filtered ${filteredReleases.length} releases");
  }

  return filteredReleases;
});
