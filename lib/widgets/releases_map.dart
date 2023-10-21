import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../providers/map_controller_provider.dart';

LatLng? findClosestPoint(Iterable<LatLng> points, LatLng target) {
  double minDistance = double.infinity;
  LatLng? closestPoint;

  for (var point in points) {
    double distance = (pow(target.latitude - point.latitude, 2) +
            pow(target.longitude - point.longitude, 2))
        .toDouble();
    if (distance < minDistance) {
      minDistance = distance;
      closestPoint = point;
    }
  }

  return closestPoint;
}

class ReleasesMap extends ConsumerWidget {
  const ReleasesMap({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Set<Marker> markers = ref.watch(mapTacksProvider(context));

    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(40.913, -67.64),
        zoom: 4.5,
      ),
      markers: markers,
      onMapCreated: (controller) {
        ref.read(mapControllerProvider.notifier).state = controller;
        // ref.listen(
        //   selectedReleaseProvider,
        //   (previous, next) {
        //     controller.animateCamera(
        //       CameraUpdate.newCameraPosition(
        //         const CameraPosition(
        //           target: LatLng(0, 0),
        //         ),
        //       ),
        //     );
        //   },
        // );
      },
      onCameraMove: (cameraPos) {
        ref.read(mapZoomProvider.notifier).state = cameraPos.zoom;
        //print(cameraPos);
      },
      //onCameraIdle: ,
    );
  }
}
