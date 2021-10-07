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
    client = MqttServerClient.withPort(
        'cctv4rent.thddns.net', 'clientIdentifier123', port);
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

  mqttSubscribe(String topic) {
    client?.subscribe('topic', MqttQos.exactlyOnce);
    return client?.updates;
  }

  final builder = MqttClientPayloadBuilder();
  builder.addString('Hello from Mqtt_client');

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              var mqttRecieveMessage = snapshot.data;
              MqttPublishMessage recieveMessage = mqttRecieveMessage[0].payload;
              String payload = MqttPublishPayload.bytesToStringAsString(
                  recieveMessage.payload.message);
              return Center(child: Text(payload));
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _publish() {
    return Center(
      child: RaisedButton(
        onPressed: () {
          client?.publishMessage('topic', MqttQos.exactlyOnce, builder.payload!);
        },
        child: const Text('publish'),
        color: Colors.lightBlue,
      ),
    );
  }
}
