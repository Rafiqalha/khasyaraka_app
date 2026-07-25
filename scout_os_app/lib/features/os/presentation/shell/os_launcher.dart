import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/os_provider.dart';
import 'pradigi_os_scaffold.dart';

class OSLauncher extends ConsumerWidget {
  const OSLauncher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeDataAsync = ref.watch(homeDataProvider);

    return homeDataAsync.when(
      data: (data) {
        // If system requires initialization, we might want to force the Explorer view,
        // but the scaffold handles its own state. We just mount the scaffold.
        // We could also do a microtask to set the initial provider state if needed.
        return const PradigiOSScaffold();
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Colors.black),
        ),
      ),
      error: (error, stackTrace) => Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Text(
            'System Offline: $error',
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
      ),
    );
  }
}
