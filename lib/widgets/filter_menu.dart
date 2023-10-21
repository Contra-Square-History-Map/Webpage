import 'package:contra_square_catalog/constants.dart';
import 'package:contra_square_catalog/providers/instruments_provider.dart';
import 'package:contra_square_catalog/providers/musicians_provider.dart';
import 'package:contra_square_catalog/providers/releases_provider.dart';
import 'package:contra_square_catalog/providers/selected_release_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_providers.dart';
import 'welcome_dialog.dart';

class FilterMenu extends ConsumerWidget {
  const FilterMenu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSelection = ref.watch(releaseRangeProvider);
    final Iterable<String> instruments = ref.watch(instrumentsProvider).when(
          data: (data) => data,
          error: (error, details) => {},
          loading: () => {},
        );

    final selectedInstruments = ref.watch(selectedInstrumentsProvider);

    final Iterable<String> releasesText = ref.watch(releasesTextProvider);

    final minTextController =
        TextEditingController(text: currentSelection.start.round().toString());

    void updateMin() {
      final newLow = int.tryParse(minTextController.text);
      if (newLow != null &&
          minYear <= newLow &&
          minYear < currentSelection.end) {
        ref.read(releaseRangeProvider.notifier).state =
            RangeValues(newLow.toDouble(), currentSelection.end);
      }
    }

    final maxTextController =
        TextEditingController(text: currentSelection.end.round().toString());

    void updateMax() {
      final newHigh = int.tryParse(minTextController.text);
      if (newHigh != null &&
          currentSelection.start < newHigh &&
          newHigh <= maxYear) {
        ref.read(releaseRangeProvider.notifier).state =
            RangeValues(currentSelection.start, newHigh.toDouble());
      }
    }

    const sectionSpacing = 30.0;

    return Align(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        primary: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DrawerHeader(
              child: Text(
                "Filters",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            TextFormField(
              initialValue: ref.read(releaseSearchTextProvider),
              decoration: const InputDecoration(
                hintText: "Search",
                icon: Icon(Icons.search),
              ),
              autofillHints: releasesText,
              onChanged: (newText) {
                ref.read(releaseSearchTextProvider.notifier).state = newText;
                ref
                    .read(selectedReleaseProvider.notifier)
                    .setActiveRelease(null);
              },
            ),
            const SizedBox(
              height: sectionSpacing,
            ),
            Text(
              "Release Range",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 40,
                    //height: (Theme.of(context).textTheme.displaySmall?.height) ?? 20 ,
                    child: TextField(
                      maxLength: 4,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) {
                        return null;
                      },
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) {
                        updateMin();
                      },
                      onEditingComplete: () {
                        updateMin();
                      },
                      focusNode: FocusNode(),
                      controller: minTextController,
                    ),
                  ),
                  Expanded(
                    child: RangeSlider(
                      values: currentSelection,
                      min: minYear.toDouble(),
                      max: maxYear.toDouble(),
                      divisions: maxYear - minYear,
                      onChanged: (values) => {
                        ref.read(releaseRangeProvider.notifier).state = values
                      },
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    //height: (Theme.of(context).textTheme.displaySmall?.height) ?? 20 ,
                    child: TextField(
                      maxLength: 4,
                      buildCounter: (context,
                          {required currentLength,
                          required isFocused,
                          maxLength}) {
                        return null;
                      },
                      maxLengthEnforcement: MaxLengthEnforcement.enforced,
                      keyboardType: TextInputType.number,
                      onSubmitted: (_) {
                        updateMax();
                      },
                      onEditingComplete: () {
                        updateMax();
                      },
                      focusNode: FocusNode(),
                      controller: maxTextController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: sectionSpacing,
            ),
            Text(
              "Instruments",
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Wrap(
              spacing: 6.0,
              runSpacing: 6.0,
              children: instruments
                  .map(
                    (instrument) => FilterChip(
                      label: Text(instrument),
                      selected: ref
                          .watch(selectedInstrumentsProvider)
                          .contains(instrument),
                      onSelected: (selected) {
                        if (selected) {
                          ref
                              .read(selectedInstrumentsProvider.notifier)
                              .add(instrument);
                        } else {
                          ref
                              .read(selectedInstrumentsProvider.notifier)
                              .remove(instrument);
                        }
                      },
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(
              height: sectionSpacing,
            ),
            FilledButton.tonal(
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => const WelcomeDialog(),
                );
              },
              child: const Text("Show Welcome"),
            ),
            const SizedBox(
              height: sectionSpacing,
            ),
            FilledButton.tonal(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LicensePage(),
                  ),
                );
              },
              child: const Text("Open Source Licences"),
            ),
          ],
        ),
      ),
    );
  }
}