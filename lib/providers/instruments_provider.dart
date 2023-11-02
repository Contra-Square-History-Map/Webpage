import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../proto/musician_messages.pb.dart';
import '../routes.dart';

final instrumentsProvider = FutureProvider<Iterable<String>>(
  (ref) async {
    final url = Uri.https(host, debugApi + instruments);
    final response =
        await http.read(url, headers: {"Referrer-Policy": "no-referrer"});

    final decoded = InstrumentList.create();
    decoded.mergeFromProto3Json(jsonDecode(response));

    final uniqueInstruments = decoded.instruments.toSet();
    final orderedInstruments = uniqueInstruments.toList(growable: false);
    orderedInstruments.sort();

    return orderedInstruments;
  },
);
