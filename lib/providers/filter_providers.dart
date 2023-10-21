import 'package:contra_square_catalog/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final releaseSearchTextProvider = StateProvider<String>(
      (ref) => "",
);

final releaseRangeProvider = StateProvider<RangeValues>(
  (ref) => RangeValues(minYear.toDouble(), maxYear.toDouble()),
);

final selectedInstrumentsProvider =
    StateNotifierProvider<SetNotifier<String>, Set<String>>(
  (ref) {
    return SetNotifier<String>();
  },
);

final selectedMusiciansProvider =
StateNotifierProvider<SetNotifier<String>, Set<String>>(
      (ref) {
    return SetNotifier<String>();
  },
);

class SetNotifier<T> extends StateNotifier<Set<T>> {
  SetNotifier() : super({});

  void add(T value) {
    state.add(value);
    state = state;
  }

  void remove(Object? value) {
    state.remove(value);
    state = state;
  }

  @override
  bool updateShouldNotify(Set<T> old, Set<T> current) {
    return true;
  }
}
