import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../proto/recording_messages.pb.dart';
import '../routes.dart';

final releaseProvider = FutureProvider.family<Recording, String>(
  (ref, id) {
    var url = Uri.https(host, debugApi + release, {"id": id});
    var response = http.read(url, headers: {
      "Referrer-Policy": "no-referrer",
      "Content-Type": "application/json"
    });
    return response.then((value) {
      final decoded = Recording.create();
      decoded.mergeFromProto3Json(jsonDecode(value));
      return decoded;
    });
  },
);
