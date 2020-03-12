import 'dart:async';

import 'package:roslib/roslib.dart';
import 'package:rxdart/rxdart.dart';

/// The annotation class that is going to be used to generate the source code
/// Where it works:

///
/// Example:
/// ```
/// @RosUtils()
/// RosMessageTopic<T extends RosMessage> messageTopic;
/// ```
abstract class RosMessage {
  /// Abstract getter that must be overridden to enable automatic serialization of messages
  dynamic get serializedMessage;
}

/// Encapsulates a ROS topic along with some state that makes it easy to subscribe to changes, and publish messages
///
/// Example:
/// ```
/// import 'package:flutter_rosutils/flutter_rosutils.dart';
///
/// class CommandMessage extends RosMessage {
///   int command;
///   static const INITIALIZE_ALL = 0;
///   static const SHUTDOWN = 10;
///   static const START_GAME = 20;
///
///   CommandMessage._(this.command);
///   factory CommandMessage(dynamic message) {
///     return CommandMessage._(message['msg']['command']);
///   }
///
///   CommandMessage.initialize() {
///     command = INITIALIZE_ALL;
///   }
///
///   CommandMessage.shutdown() {
///     command = SHUTDOWN;
///   }
///
///   CommandMessage.startGame() {
///     command = START_GAME;
///   }
///
///   @override
///   dynamic get serializedMessage => {
///     'command': command
///   };
/// }
///
/// final _ros = Ros(url: 'ws://127.0.0.1:9090');
/// final messageTopic = RosMessageTopic<CommandMessage>(ros: _ros, name: 'command', type: 'custom_msgs/CommandMessage');
///
/// messageTopic.stream.listen((message) => print(message));
///
/// messageTopic.value = CommandMessage.initialize();
///
/// final lastestValue = messageTopic.value;
/// ```
class RosMessageTopic<T extends RosMessage> extends Topic {
  T _currentValue;
  final _behaviorSubject = BehaviorSubject<T>();
  StreamSubscription<dynamic> _listener;

  RosMessageTopic({
    ros,
    name,
    type,
    compression = 'none',
    throttleRate = 0,
    latch = false,
    queueSize = 100,
    queueLength = 10,
    reconnectOnClose = true,
  }) : super(
          ros: ros,
          name: name,
          type: type,
          compression: compression,
          throttleRate: throttleRate,
          latch: latch,
          queueSize: queueSize,
          queueLength: queueLength,
          reconnectOnClose: reconnectOnClose,
        );

  /// A stream that can be subscribed to in multiple places
  get stream => _behaviorSubject.stream;

  /// The latest value from the topic
  T get value => _currentValue;

  /// A setter that will publish the new message [value] to ROS, as well as
  /// add it to the [stream], so the app can be synchronized
  set value(T value) {
    if (value != null) {
      super.publish(value.serializedMessage).then((_) {
        if (_currentValue != null && value == _currentValue) {
          return; // Don't add doubles
        }
        _behaviorSubject.add(value);
        _currentValue = value;
      });
    }
  }

  void _updateValue(T message) {
    _currentValue = message;
    _behaviorSubject.add(message);
  }

  /// Connects to the ros topic
  Future<void> connect(T Function(dynamic message) constructor, {Function(T message) callback}) async {
    await super.subscribe();
    _listener = super.subscription.listen((message) {
      // print(message);
      T newValue = constructor(message);
      callback?.call(newValue);
      _updateValue(newValue);
    });
  }

  /// Subscribes to the ros topic
  @override
  Future<void> unsubscribe() async {
    _listener?.cancel();
    await super.unsubscribe();
  }

  /// Disposes of the stream
  void dispose() {
    _behaviorSubject.close();
  }
}
