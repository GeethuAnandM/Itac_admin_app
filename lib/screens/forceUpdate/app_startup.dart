import 'package:flutter/material.dart';
import 'force_update_service.dart';
import 'force_update_dialog.dart';

class AppStartup extends StatefulWidget {
  final Widget child;
  const AppStartup({super.key, required this.child});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runVersionCheck());
  }

  Future<void> _runVersionCheck() async {
    // No parameter needed — URL is inside ForceUpdateService
    final result = await ForceUpdateService.checkForUpdate();
    if (!mounted) return;

    if (result != null) {
      await ForceUpdateDialog.show(context, result);
    }

    setState(() => _checked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return widget.child;
  }
}
