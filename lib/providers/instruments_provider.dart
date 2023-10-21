import 'dart:convert';

import 'package:contra_square_catalog/proto/musician_messages.pb.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../routes.dart';

final instrumentsProvider = FutureProvider<Iterable<String>>(
  (ref) async {
    if (true) {
      final url = Uri.http(host, debugApi + instruments);
      final response =
          await http.read(url, headers: {"Referrer-Policy": "no-referrer"});

      final decoded = InstrumentList.create();
      decoded.mergeFromProto3Json(jsonDecode(response));

      final uniqueInstruments = decoded.instruments.toSet();
      final orderedInstruments = uniqueInstruments.toList(growable: false);
      orderedInstruments.sort();

      return orderedInstruments;
    } else {
      final url = Uri.http(host, api);
      final response = http.readBytes(url);
      return response.then(
          (value) => InstrumentList.fromBuffer(value).instruments.toSet());
    }
  },
);
