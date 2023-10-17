import 'package:flutter/material.dart';
import 'package:instana_agent/instana_agent.dart';

// Pages ======================================================================
import './pages/home.dart';

// MAIN =============================================================
void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const title = 'WebSocket Demo';
    return const MaterialApp(
      title: title,
      home: MyHomePage(
        title: title,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // Put keys and reporting-url from Instana Mobile App monitoring configuration options.

  // Instana Agent Initialization =============================================
  // Instana Agent must be initialize as soon as possible when the apps is started.
    InstanaAgent.setup(
        key: 'oMbKxg51TtO4Rvn6xDYAYQ', // Instana Agent key, can be found on mobile apps monitoring configuration options.
        reportingUrl: 'https://eum-orange-saas.instana.io/mobile'); // Instana Agent reporting-url.

    InstanaAgent.setCollectionEnabled(true); // enabling data collection.

    // setUserIdentifiers(); // User-specific information, the configuration is on below.
    setView(); // Segment mobile app insights by logical views. Help to manage beacons that work under this app.

    // HTTP headers of every tracked request/response that Instana will capture.
    InstanaAgent.setCaptureHeaders(regex: [
      'x-ratelimit-limit',
      'x-ratelimit-remaining',
      'x-ratelimit-reset'
    ]);
  }

  // User-specific information config.
  // setUserIdentifiers() {
  //   InstanaAgent.setUserID('alexander_the_great');
  //   InstanaAgent.setUserName('Alexander The Great');
  //   InstanaAgent.setUserEmail('alexander@thegreat.com');
  // }

  // View config.
  setView() {
    InstanaAgent.setView('DemoApp: WebSocket Monitoring');
  }
  // End Instana Agent Initialization =========================================

  @override
  Widget build(BuildContext context) {
    return const FirstRoute();
    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(widget.title),
    //   ),
    //   body: const FirstRoute(),
    // );
  }
}