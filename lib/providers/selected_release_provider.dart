import 'package:contra_square_catalog/providers/map_controller_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final selectedReleaseProvider = StateNotifierProvider<ZoomingProvider, String?>(
    (ref) => ZoomingProvider(ref.watch(mapControllerProvider)));

class ZoomingProvider extends StateNotifier<String?> {
  final GoogleMapController? controller;

  ZoomingProvider(this.controller) : super(null);

  void setActiveRelease(String? releaseID) {
    state = releaseID;

    // controller?.animateCamera(
    //   CameraUpdate.newCameraPosition(
    //     const CameraPosition(
    //       target: LatLng(0, 0),
    //     ),
    //   ),
    // );
  }

  void clearRelease() {
    state = null;
  }
}
