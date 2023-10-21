import 'dart:math';
import 'dart:ui';

import 'package:contra_square_catalog/providers/selected_release_provider.dart';
import 'package:contra_square_catalog/widgets/filter_menu.dart';
import 'package:contra_square_catalog/widgets/release_summary.dart';
import 'package:contra_square_catalog/widgets/releases_map.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/releases_timeline.dart';
import 'widgets/welcome_dialog.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
  ConsumerState<ConsumerStatefulWidget> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        final sharedPrefs = SharedPreferences.getInstance();

        sharedPrefs.then((sharedPrefs) {
          final showWelcome = sharedPrefs.getBool("showWelcomeDialog") ?? true;

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

    final stackChildren = (selectedRelease != null)
        ? [
            releasesMap,
            FractionallySizedBox(
              widthFactor: .4,
              heightFactor: .9,
              child: PointerInterceptor(
                child: ReleaseSummary(id: selectedRelease),
              ),
            ),
          ]
        : [
            releasesMap,
          ];

    return SelectionArea(
      child: Scaffold(
        appBar: AppBar(),
        body: Column(
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
        ),
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
