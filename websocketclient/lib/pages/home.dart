import 'package:flutter/material.dart';
import 'package:instana_agent/instana_agent.dart';

// Pages ======================================================================
import './websocket.dart';

// Event ======================================================================
// import '../instana/event.dart';

class FirstRoute extends StatelessWidget {
  const FirstRoute({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text('Open Websocket'),
          onPressed: () {
            // Navigate to second route when tapped.
            InstanaAgent.setView('Home');
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecondRoute()),
            );
          },
        ),
      ),
    );
  }
}
