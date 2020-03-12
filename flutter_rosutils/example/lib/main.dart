import 'package:flutter/material.dart';
import 'package:flutter_rosutils/flutter_rosutils.dart';
import 'package:provider/provider.dart';

class CommandMessage extends RosMessage {
  int command;
  static const INITIALIZE_ALL = 0;
  static const SHUTDOWN = 10;
  static const START_GAME = 20;

  CommandMessage._(this.command);
  factory CommandMessage(dynamic message) {
    return CommandMessage._(message['msg']['command']);
  }

  CommandMessage.initialize() {
    command = INITIALIZE_ALL;
  }

  CommandMessage.shutdown() {
    command = SHUTDOWN;
  }

  CommandMessage.startGame() {
    command = START_GAME;
  }

  @override
  dynamic get serializedMessage => {'command': command};

  String get message {
    switch (command) {
      case INITIALIZE_ALL:
        return 'initialize';
      case START_GAME:
        return 'start game';
      case SHUTDOWN:
        return 'shutdown';
      default:
        return 'none';
    }
  }
}

class ExampleBloc {
  Ros _ros;
  RosMessageTopic<CommandMessage> messageTopic;

  ExampleBloc() {
    _ros = Ros(url: 'ws://127.0.0.1:9090');
    messageTopic = RosMessageTopic<CommandMessage>(ros: _ros, name: 'command', type: 'custom_msgs/CommandMessage');
  }

  void connect() {
    _ros.connect();
    messageTopic.connect((message) => CommandMessage(message));
  }

  void sendInitMessage() {
    messageTopic.value = CommandMessage.initialize();
  }
}

void main() {
  final bloc = ExampleBloc();
  bloc.connect();
  runApp(
    Provider<ExampleBloc>.value(
      value: bloc,
      child: StreamProvider<CommandMessage>.value(
        value: bloc.messageTopic.stream,
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Bloc Demo'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  final String title;
  MyHomePage({this.title, key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<ExampleBloc>(context);
    final currentMessage = Provider.of<CommandMessage>(context).message;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Current Message: $currentMessage',
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: appState.sendInitMessage,
        tooltip: 'Send Init',
        child: Icon(Icons.play_arrow),
      ),
    );
  }
}
