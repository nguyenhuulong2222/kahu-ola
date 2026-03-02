import 'package:flutter/material.dart';

import 'debug_panel.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({
    super.key,
    this.message = 'Starting Kahu Ola...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const DebugTapTarget(
                  child: Text(
                    'Kahu Ola',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 20),
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class InlineLoadingState extends StatelessWidget {
  const InlineLoadingState({
    super.key,
    this.message = 'Loading the latest safety data...',
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
