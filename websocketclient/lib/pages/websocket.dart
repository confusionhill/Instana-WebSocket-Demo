import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:instana_agent/instana_agent.dart';

import 'dart:math';
import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

// Event ======================================================================
import '../instana/event.dart';

class SecondRoute extends StatefulWidget {
  const SecondRoute({super.key});

  @override
  State<SecondRoute> createState() => _SecondRouteState();
}

List<String> messageList = [];

ListView getMesssageList() {
  List<Widget> test = [];

  for (String message in messageList) {
    var splitMessage = message.split(',');
    test.add(Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 5, left: 5, right: 5),
      decoration: const BoxDecoration(
          color: Colors.blue,
          border: Border(
              top: BorderSide(color: Colors.black),
              bottom: BorderSide(color: Colors.black),
              left: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.black)),
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(0),
              bottomRight: Radius.circular(10))),
      child: Wrap(
        children: [
          Row(
            children: [
              Text(
                splitMessage[0],
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.bold),
              )
            ],
          ),
          Text(
            splitMessage[2],
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    ));
  }

  return ListView(
    shrinkWrap: true,
    children: test,
  );
}

class _SecondRouteState extends State<SecondRoute> {
  final inputController = TextEditingController();
  final scrollController = ScrollController();

  final String url = 'http://10.0.2.2:8080/wschatdemo';
  late StompClient stompClient;
  final rng = Random();
  late String userName;

  @override
  void initState() {
    super.initState();

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    int randomInt = rng.nextInt(100);
    userName = "flutter-mobile-$randomInt";

    InstanaAgent.setUserID(userName);
    InstanaAgent.setUserName(userName);
    InstanaAgent.setUserEmail("$userName@gmail.com");

    stompClient = StompClient(
      config: StompConfig.SockJS(
          url: url,
          onConnect: onConnect,
          beforeConnect: () async {
            // print('waiting to connect...');
            await Future.delayed(const Duration(milliseconds: 1000));
            // print('connecting...');
          },
          onWebSocketError: (dynamic error) => {
                print("Websocket error: " + error.toString()),
                websocketEvents(
                    userName + ': ' + 'Websocket error: ' + error.toString(),
                    timestamp,
                    0)
              },
          onStompError: (dynamic error) => {
                print("Stomp error: " + error.toString()),
                websocketEvents(
                    userName + ': ' + 'Stomp error: ' + error.toString(),
                    timestamp,
                    0)
              },
          onDisconnect: (dynamic error) => {
                print("Disconnect error: " + error.toString()),
                websocketEvents(
                    userName + ': ' + 'Disconnect error: ' + error.toString(),
                    timestamp,
                    0)
              }),
    );

    stompClient.activate();
  }

  onConnect(StompFrame frame) {
    stompClient.subscribe(
        destination: '/topic/public',
        callback: (StompFrame frame) {
          final data = jsonDecode(frame.body!);
          int timestampData = data['timestamp'];
          int timestampReceive = DateTime.now().millisecondsSinceEpoch;

          setState(() {
            messageList.add(
                data['sender'] + ',' + data['type'] + ',' + data['content']);
          });

          switch (data['type']) {
            case 'JOIN':
              websocketEvents(userName + ': ' + 'Websocket client connected',
                  timestampData, timestampReceive - timestampData);
              break;
            case 'LEAVE':
              websocketEvents(userName + ': ' + 'Websocket client disconnected',
                  timestampData, timestampReceive - timestampData);
              break;
            case 'CHAT':
              websocketEvents(userName + ': ' + 'Websocket message',
                  timestampData, timestampReceive - timestampData);
              break;
            default:
          }
        });

    int timestamp = DateTime.now().millisecondsSinceEpoch;
    stompClient.send(
      destination: '/app/chat.register',
      body: jsonEncode({
        'sender': userName,
        'content': 'joined',
        'timestamp': timestamp,
        'type': 'JOIN'
      }),
      headers: {},
    );

    // websocketEvents(userName + ': ' + 'Websocket client connected');
  }

  @override
  void dispose() {
    if (stompClient.connected) {
      stompClient.deactivate();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Simple Websocket Chat')),
        body: getMesssageList(),
        bottomNavigationBar: Container(
            padding: const EdgeInsets.all(10),
            child: Wrap(
              children: [
                Padding(
                    // padding: MediaQuery.of(context).viewInsets,
                    padding: const EdgeInsets.all(0),
                    child: TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      controller: inputController,
                      decoration: const InputDecoration(
                        labelText: "Message",
                        border: OutlineInputBorder(),
                      ),
                    )),
                Padding(
                  padding: MediaQuery.of(context).viewInsets,
                  child: Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Navigate back to first route when tapped.
                          InstanaAgent.setView('Chat Screen');
                          Navigator.pop(context);
                          stompClient.deactivate();

                          // websocketEvents(
                          //     userName + ': ' + 'Client disconnected');
                        },
                        child: const Text('Close Websocket'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (inputController.text.isNotEmpty) {
                            int timestamp =
                                DateTime.now().millisecondsSinceEpoch;
                            stompClient.send(
                              destination: '/app/chat.send',
                              body: jsonEncode({
                                'sender': userName,
                                'content': inputController.text,
                                'timestamp': timestamp,
                                'type': 'CHAT'
                              }),
                              headers: {},
                            );
                            // websocketEvents(userName + ': ' + 'Websocket Message');
                            inputController.clear();
                          }
                        },
                        child: const Text('Send'),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            inputController.clear();
                          },
                          child: const Text('Clear'))
                    ],
                  ),
                )
              ],
            )));
  }
}
