import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

MqttServerClient? client;
int port = 7794;

class _MyHomePageState extends State<MyHomePage> {
  void mqttConnect() async {
    client = MqttServerClient.withPort('cctv4rent.thddns.net', '1234', port);
    client?.keepAlivePeriod = 60;
    client?.autoReconnect = true;
    client?.onConnected = onConnected;
    client?.onDisconnected = onDisconnected;
    try {
      await client?.connect();
    } on NoConnectionException catch (e) {
      log(e.toString());
    }

    // client?.subscribe('test', MqttQos.exactlyOnce);

    // client?.updates?.listen((mqttReceivedMessage) {
    //   final recMess = mqttReceivedMessage[0].payload as MqttPublishMessage;
    //   var payload =
    //       MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
    //   log(payload);
    // });
  }

  // Stream<List<MqttReceivedMessage<MqttMessage>>>? mqttSubscribe(String topic) {
  //   client?.subscribe('topic', MqttQos.exactlyOnce);
  //   return client?.updates;
  // }
  void onConnected() {
    log('Connected');
  }

  void onDisconnected() {
    log('Disconnected');
  }

  @override
  void initState() {
    super.initState();
    mqttConnect();
  }

  @override
  Widget build(BuildContext context) {
    String test = 'hello';
    // final builder = MqttClientPayloadBuilder();
    // builder.addString(test);
    // if (client!.connectionStatus!.state == MqttConnectionState.connected) {
    // mqttSubscribe('topic');
    // }
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 200,
              child: Text(
                test,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(
              height: 40,
            )
          ],
        ),
        // child:StreamBuilder(
        //   stream: mqttSubscribe('topic'),
        //   builder: (BuildContext context, AsyncSnapshot snapshot) {
        //     if (snapshot.hasData) {
        //       var mqttRecieveMessage = snapshot.data;
        //       MqttPublishMessage recieveMessage = mqttRecieveMessage[0].payload;
        //       String payload = MqttPublishPayload.bytesToStringAsString(
        //           recieveMessage.payload.message);
        //       return Center(child: Text(payload));
        //     }
        //     return const Center(child: CircularProgressIndicator());
        //   },
        // ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
              bottom: 20,
              right: 10,
              child: FloatingActionButton(
                onPressed: () {
                  final builder = MqttClientPayloadBuilder();
                  builder.addString(test);
                  client?.publishMessage(
                      'topic', MqttQos.exactlyOnce, builder.payload!);
                  log('published');
                },
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                splashColor: Colors.lightBlueAccent,
                tooltip: "press for publish message",
                child: const Text('publish'),
              )),
          Positioned(
              bottom: 20,
              left: 30,
              child: FloatingActionButton(
                onPressed: () {
                  client?.subscribe('topic', MqttQos.exactlyOnce);
                  log('subscribed');
                },
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                splashColor: Colors.lightBlueAccent,
                tooltip: "press for subscribe to topic",
                child: const Text('subscribe'),
              ))
        ],
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     client?.publishMessage(
      //         'topic', MqttQos.exactlyOnce, builder.payload!);
      //          log('published');
      //   },
      //   child: const Text('publish'),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.startDocked,
      // floatingActionButton:FloatingActionButton(
      //   backgroundColor: Colors.amber,
      //   foregroundColor: Colors.white,
      //   splashColor: Colors.lightBlueAccent,
      //   tooltip: "press for connect server",
      //   onPressed:(){
      //     mqttConnect();
      //     },
      //   child: const Text("connect to server"),
      // ),
    );
  }
}
