import 'dart:collection';
import 'dart:math';

import 'package:contra_square_catalog/proto/recording_messages.pb.dart';
import 'package:contra_square_catalog/providers/filter_providers.dart';
import 'package:contra_square_catalog/providers/releases_provider.dart';
import 'package:contra_square_catalog/providers/selected_release_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants.dart';

class _ReleaseSpot extends ScatterSpot {
  _ReleaseSpot(this.recording, super.x, super.y, {super.color});

  final Recording recording;
}

class ReleasesTimeline extends ConsumerStatefulWidget {
  const ReleasesTimeline({super.key});

  @override
  ConsumerState<ReleasesTimeline> createState() {
    return _ReleasesTimelineState();
  }
}

class _ReleasesTimelineState extends ConsumerState<ReleasesTimeline> {
  @override
  Widget build(BuildContext context) {
    final searchWindow = ref.watch(releaseRangeProvider);
    final requiredInstruments = ref.watch(selectedInstrumentsProvider);
    final selectedRelease = ref.watch(selectedReleaseProvider);

    final releasePoints = ref.watch(releasesProvider).when(
          data: (recordingList) {
            final points = List<ScatterSpot>.empty(growable: true);
            final timeBuckets = SplayTreeMap<int, List<Recording>>();

            for (var recording in recordingList.where((release) =>
                requiredInstruments.every((inst) => release.contributions
                    .any((contribution) => contribution.instrument == inst)))) {
              final releaseYear = DateTime.fromMillisecondsSinceEpoch(
                      recording.releaseTime.toInt(),
                      isUtc: true)
                  .year;

              timeBuckets.putIfAbsent(
                releaseYear,
                () => List<Recording>.empty(
                  growable: true,
                ),
              );

              timeBuckets[releaseYear]?.add(recording);
            }

            if (timeBuckets.isEmpty) {
              return points;
            }

            final divisor = 1 /
                (timeBuckets.values
                        .map((e) => e.length)
                        .reduce((value, element) => max(value, element)) +
                    1.0);

            for (var timeBucket in timeBuckets.entries) {
              if (timeBucket.key >= searchWindow.start &&
                  timeBucket.key <= searchWindow.end) {
                final releases = timeBucket.value;
                for (var k = 0; k < timeBucket.value.length; ++k) {
                  points.add(
                    _ReleaseSpot(
                      releases[k],
                      timeBucket.key.toDouble(),
                      (k + 1) * divisor,
                      color: (selectedRelease == releases[k].id)
                          ? Colors.red
                          : Colors.blue,
                    ),
                  );
                }
              }
            }

            return points;
          },
          error: (error, trace) => List<ScatterSpot>.empty(),
          loading: () => List<ScatterSpot>.empty(),
          skipLoadingOnRefresh: false,
        );

    final scrollController = ScrollController();

    return Scrollbar(
      controller: scrollController,
      child: SingleChildScrollView(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        primary: false,
        child: SizedBox(
          width: max(1500, MediaQuery.of(context).size.width),
          child: Padding(
            padding: const EdgeInsets.only(
              left: 18,
              right: 18,
              bottom: 12,
            ),
            child: ScatterChart(
              ScatterChartData(
                scatterSpots: releasePoints,
                minX: searchWindow.start.toDouble(),
                maxX: searchWindow.end.toDouble(),
                minY: 0.0,
                maxY: 1.0,
                scatterLabelSettings: ScatterLabelSettings(
                  getLabelFunction: (spotIndex, spot) => "B",
                ),
                scatterTouchData: ScatterTouchData(
                  enabled: true,
                  touchTooltipData: ScatterTouchTooltipData(
                    fitInsideVertically: true,
                    tooltipBgColor: Colors.blue[100],
                    getTooltipItems: (touchedSpot) {
                      final releaseSpot = touchedSpot as _ReleaseSpot;
                      return ScatterTooltipItem(
                        releaseSpot.recording.title,
                        textStyle: Theme.of(context).textTheme.titleLarge,
                        children: [
                          const TextSpan(text: "\n"),
                          TextSpan(
                              text: releaseSpot.recording.band,
                              style: Theme.of(context).textTheme.bodyLarge),
                        ],
                      );
                    },
                  ),
                  touchCallback: (FlTouchEvent event,
                      ScatterTouchResponse? touchResponse) {
                    if (touchResponse == null ||
                        touchResponse.touchedSpot == null) {
                      return;
                    }
                    if (event is FlTapUpEvent) {
                      final sectionIndex = touchResponse.touchedSpot!.spotIndex;
                      setState(() {
                        ref
                            .read(selectedReleaseProvider.notifier)
                            .setActiveRelease(
                                (releasePoints[sectionIndex] as _ReleaseSpot)
                                    .recording
                                    .id);
                      });
                    }
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 2,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                      ),
                    ),
                  ),
                  bottomTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: const FlGridData(drawHorizontalLine: false),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
