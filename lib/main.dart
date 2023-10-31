import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants.dart';
import 'providers/selected_release_provider.dart';
import 'widgets/filter_menu.dart';
import 'widgets/release_summary.dart';
import 'widgets/releases_map.dart';
import 'widgets/releases_timeline.dart';
import 'widgets/welcome_dialog.dart';

void main() {
  usePathUrlStrategy();
  runApp(const AHandForTheBand());
}

class AHandForTheBand extends StatelessWidget {
  const AHandForTheBand({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'A Hand for the Band',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        scrollBehavior: const MaterialScrollBehavior().copyWith(
          dragDevices: {
            PointerDeviceKind.mouse,
            PointerDeviceKind.touch,
            PointerDeviceKind.stylus,
            PointerDeviceKind.unknown
          },
        ),
        home: const MainPage(),
      ),
    );
  }
}

class MainPage extends ConsumerStatefulWidget {
  const MainPage({super.key});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final sharedPrefs = SharedPreferences.getInstance();

        sharedPrefs.then((sharedPrefs) {
          final showWelcome = sharedPrefs.getBool(showWelcomeDialogKey) ?? true;

          if (showWelcome) {
            showDialog(
              context: context,
              barrierDismissible: true,
              builder: (context) => const WelcomeDialog(),
            );
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedRelease = ref.watch(selectedReleaseProvider);

    const releasesMap = ReleasesMap();

    final releaseSummary =
        (selectedRelease != null) ? ReleaseSummary(id: selectedRelease) : null;

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(title: Text(selectedRelease ?? "A Hand for the Band")),
        body: LayoutBuilder(builder: (context, constraints) {
          final stackChildren = (selectedRelease != null)
              ? [
                  releasesMap,
                  FractionallySizedBox(
                    heightFactor: .9,
                    child: PointerInterceptor(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                            maxWidth: min(550, .7 * constraints.maxWidth)),
                        child: ReleaseSummary(id: selectedRelease),
                      ),
                    ),
                  ),
                ]
              : [
                  releasesMap,
                ];

          if (releaseSummary != null &&
              (constraints.maxWidth < 780 || constraints.maxHeight < 800)) {
            return releaseSummary;
          } else {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: const Alignment(.75, .5),
                    children: stackChildren,
                  ),
                ),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: const ReleasesTimeline(),
                ),
              ],
            );
          }
        }),
        drawer: Drawer(
          width: min(400, MediaQuery.of(context).size.width - 20),
          child: PointerInterceptor(
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: FilterMenu(),
            ),
          ),
        ),
        drawerEnableOpenDragGesture: false,
      ),
    );
  }
}
