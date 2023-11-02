import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../proto/musician_messages.pb.dart';
import '../routes.dart';

final musiciansProvider = FutureProvider<Iterable<String>>(
  (ref) async {
    final url = Uri.https(host, debugApi + musicians);
    final response =
        await http.read(url, headers: {"Referrer-Policy": "no-referrer"});

    final decoded = MusicianList.create();
    decoded.mergeFromProto3Json(jsonDecode(response));

    final uniqueMusicians =
        decoded.musicians.map((e) => "${e.firstName} ${e.lastName}").toSet();
    final orderedMusicians = uniqueMusicians.toList(growable: false);
    orderedMusicians.sort();

    return orderedMusicians;
  },
);
