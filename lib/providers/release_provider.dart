import 'dart:convert';

import 'package:contra_square_catalog/proto/recording_messages.pb.dart';
import 'package:fixnum/fixnum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../routes.dart';

final releaseProvider = FutureProvider.family<Recording, String>(
  (ref, id) {
    if (true) {
      var url = Uri.http(host, debugApi + release, {"id": id});
      var response = http.read(url, headers: {
        "Referrer-Policy": "no-referrer",
        "Content-Type": "application/json"
      });
      return response.then((value) {
        final decoded = Recording.create();
        decoded.mergeFromProto3Json(jsonDecode(value));
        return decoded;
      });
    } else {
      var url = Uri.http(host, api);
      var response = http.readBytes(url);
      return response.then((value) => Recording.fromBuffer(value));
    }
  },
);
