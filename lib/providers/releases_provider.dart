import 'dart:convert';

import 'package:contra_square_catalog/proto/recording_messages.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../routes.dart';
import 'filter_providers.dart';

final releasesProvider = FutureProvider<List<Recording>>(
  (ref) async {
    final query = ref.watch(releaseSearchTextProvider);

    if (true) {
      final Map<String, dynamic> queryParameters = {};

      if (query.length > 2) {
        queryParameters["q"] = query;
      }

      var url = Uri.http(host, debugApi + releases, queryParameters);

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
    } else {
      var url = Uri.http(host, api);
      var response = await http.readBytes(url);
      return RecordingList.fromBuffer(response).recordings;
    }
  },
);

final filteredReleasesProvider = FutureProvider<List<Recording>>((ref) {
  final searchWindow = ref.watch(releaseRangeProvider);
  final requiredInstruments = ref.watch(selectedInstrumentsProvider);
  final requiredMusicians = ref.watch(selectedInstrumentsProvider);

  final List<Recording> allReleases = ref.watch(releasesProvider).when(
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
              .where(
                (release) => requiredMusicians.every(
                  (musician) => release.contributions.any((contribution) =>
                      "${contribution.musician.firstName} ${contribution.musician.lastName}" ==
                      musician),
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
  return allReleases;
});
