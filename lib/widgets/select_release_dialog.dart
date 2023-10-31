import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

import '../proto/recording_messages.pb.dart';
import '../providers/selected_release_provider.dart';

/// Widget to select one release from a list of releases
class SelectReleaseDialog extends ConsumerWidget {
  /// Constructor
  const SelectReleaseDialog({Key? key, required this.releases})
      : super(key: key);

  final List<Recording> releases;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PointerInterceptor(
      child: AlertDialog(
        title: const Text("Select a Recording"),
        content: SizedBox(
          width: 400,
          height: 400,
          child: ListView.builder(
            itemCount: releases.length,
            itemBuilder: (context, index) {
              final release = releases[index];
              return ListTile(
                title: Text(release.title),
                subtitle: Text(release.band),
                onTap: () {
                  ref.read(selectedReleaseProvider.notifier).state = release.id;
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
