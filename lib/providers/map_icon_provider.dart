import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final mapIconProvider =
    FutureProvider.family<BitmapDescriptor, (AssetBundle bundle, int count, bool selected)>((ref, args) async {
  final (bundle, count, selected) = args;

  final icon = await BitmapDescriptor.fromAssetImage(
    ImageConfiguration(bundle: bundle),
    "assets/map_markers/${(selected) ? "red" : "blue"}/number_$count.png",
    mipmaps: false,
  );

  return icon;
});
