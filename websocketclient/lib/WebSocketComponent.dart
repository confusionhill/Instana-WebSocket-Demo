import 'package:flutter/material.dart';
// import 'package:web_socket_channel/io.dart';
// import 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:math';

import 'dart:async';
import 'dart:convert';

import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class WebSocketComponent extends StatefulWidget {
  WebSocketComponent({super.key});
  // final WebSocketChannel channel =
  //     IOWebSocketChannel.connect('ws://localhost:8080/wsmlpt');

  @override
  State<WebSocketComponent> createState() => _WebSocketComponentState();
}

class _WebSocketComponentState extends State<WebSocketComponent> {
  final String url = 'http://10.0.2.2:8080/wsmlpt';
  late StompClient stompClient;
  final rng = Random();
  late String userName;

  final inputController = TextEditingController();
  List<String> messageList = [];

  ListView getMesssageList() {
    List<Widget> listWidget = [];

    for (String message in messageList) {
      listWidget.add(ListTile(
        title: Container(
          color: Colors.teal[50],
          height: 60,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              message,
              style: const TextStyle(fontSize: 17),
            ),
          ),
        ),
      ));
    }

    return ListView(
      children: listWidget,
    );
  }

  @override
  void initState() {
    super.initState();

    int randomInt = rng.nextInt(100);
    userName = "flutter-mobile-$randomInt";

    stompClient = StompClient(
      config: StompConfig.SockJS(
        url: url,
        onConnect: onConnect,
        beforeConnect: () async {
          // print('waiting to connect...');
          await Future.delayed(Duration(milliseconds: 1000));
          // print('connecting...');
        },
        onWebSocketError: (dynamic error) =>
            print("Websocket error: " + error.toString()),
        onStompError: (dynamic error) =>
            print("Stomp error: " + error.toString()),
        onDisconnect: (dynamic error) =>
            print("Disconnect error: " + error.toString()),
      ),
    );

    stompClient.activate();
  }

  onConnect(StompFrame frame) {
    stompClient.subscribe(
        destination: '/topic/public',
        callback: (StompFrame frame) {
          final data = jsonDecode(frame.body!);
          setState(() {
            messageList.add(data['sender'] + " - " + data['type'] + " " + " : " + data['content']);  
          });          
          print(data['sender'] + " - " + data['type'] + " " + " : " + data['content']);
        });

    stompClient.send(
      destination: '/app/chat.register',
      body:
          jsonEncode({'sender': userName, 'content': 'joined', 'type': 'JOIN'}),
      headers: {},
    );
  }

  @override
  void dispose() {
    super.dispose();

    stompClient.send(
      destination: '/app/chat.register',
      body: jsonEncode(
          {'sender': userName, 'content': 'joined.', 'type': 'JOIN'}),
      headers: {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: inputController,
                  decoration: const InputDecoration(
                    labelText: "Send Message",
                    border: OutlineInputBorder(),
                  ),
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // setState(() {
                    //   if (inputController.text.isNotEmpty) {
                    //     messageList.add(inputController.text);
                    //     print(messageList);
                    //   }
                    // });
                    // widget.channel.sink.add(inputController.text);
                    if (inputController.text.isNotEmpty) {
                      stompClient.send(
                        destination: '/app/chat.send',
                        body: jsonEncode({
                          'sender': userName,
                          'content': inputController.text,
                          'type': 'CHAT'
                        }),
                        headers: {},
                      );
                      inputController.text = "";
                    }
                  },
                  child: const Text(
                    'Send',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: getMesssageList(),
          // child: StreamBuilder(
          //   stream: widget.channel.stream,
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       messageList.add(snapshot.data);
          //     }
          //     return getMesssageList();
          //   },
          // ),
        )
      ],
    );
  }
}

// * https://www.youtube.com/watch?v=U3b0-ZUWNbQ&list=PL_YbT4IaTv9UuiLSuJ7PnLnWYi7fn2MtB&index=2
// * https://startswithzed.hashnode.dev/build-squid-games-marble-guessing-game-using-flutter-and-websocket#heading-gameplay-page