import 'dart:math';

import 'package:collection/collection.dart';
import 'package:contra_square_catalog/widgets/select_release_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../proto/recording_messages.pb.dart';
import '../widgets/releases_map.dart';
import 'map_icon_provider.dart';
import 'releases_provider.dart';
import 'selected_release_provider.dart';

final mapControllerProvider =
    StateProvider<GoogleMapController?>((ref) => null);

final mapZoomProvider = StateProvider<double>((ref) => 4.5);

final mapTacksProvider =
    StateProvider.family<Set<Marker>, BuildContext>((ref, context) {
  final releases = ref.watch(filteredReleasesProvider);
  final combinationDistance = 50 * 50 / pow(4, ref.watch(mapZoomProvider));
  final selectedRelease = ref.watch(selectedReleaseProvider);

  return releases.when(
    data: (data) {
      final locationAggregate = <LatLng, List<Recording>>{};

      for (final recording in data) {
        final latLong = LatLng(recording.latitude, recording.longitude);
        final closest = findClosestPoint(locationAggregate.keys, latLong);

        if (closest != null &&
            pow(recording.latitude - closest.latitude, 2) +
                    pow(recording.longitude - closest.longitude, 2) <
                combinationDistance) {
          // Get the existing recordings
          final recordings = locationAggregate.remove(closest)!;

          // Add the new recording
          recordings.add(recording);

          // Calculate the new center
          final lat = recordings.map((e) => e.latitude).average;
          final long = recordings.map((e) => e.longitude).average;

          locationAggregate.putIfAbsent(LatLng(lat, long), () => recordings);

          locationAggregate[closest]?.add(recording);
        } else {
          locationAggregate.putIfAbsent(latLong, () => [recording]);
        }
      }

      final Iterable<Marker> x = locationAggregate.entries.map((entry) {
        final recordings = entry.value;

        final lat = recordings.map((e) => e.latitude).average;
        final long = recordings.map((e) => e.longitude).average;

        final icon = ref
                .watch(mapIconProvider((
                  DefaultAssetBundle.of(context),
                  recordings.length,
                  recordings.any((element) => element.id == selectedRelease)
                )))
                .valueOrNull ??
            BitmapDescriptor.defaultMarker;

        return Marker(
          markerId: MarkerId("${lat}_${long}"),
          position: LatLng(lat, long),
          icon: icon,
          onTap: () {
            if (recordings.length == 1) {
              ref
                  .read(selectedReleaseProvider.notifier)
                  .setActiveRelease(recordings.first.id);
            } else {
              showDialog(
                context: context,
                barrierDismissible: true,
                builder: (context) => PointerInterceptor(
                  child: AlertDialog(
                    title: const Text("Select a Recording"),
                    content: SizedBox(
                      width: 400,
                      height: 400,
                      child: ListView.builder(
                        itemCount: recordings.length,
                        itemBuilder: (context, index) {
                          final release = recordings[index];
                          return ListTile(
                            title: Text(release.band),
                            subtitle: Text(
                                "${release.title} (${DateTime.fromMillisecondsSinceEpoch(release.releaseTime.toInt(), isUtc: true).year})"),
                            onTap: () {
                              ref
                                  .read(selectedReleaseProvider.notifier)
                                  .setActiveRelease(release.id);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text("Close"),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        );
      });
      return x.toSet();
    },
    error: (error, trace) => <Marker>{},
    loading: () => <Marker>{},
    skipLoadingOnRefresh: false,
  );
});
