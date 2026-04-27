import 'package:flutter/material.dart';

class TrainingOnlineScreen extends StatelessWidget {
  const TrainingOnlineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Training'),
      ),
      body: const Center(
        child: Text('Training Online Screen'),
      ),
    );
  }
}