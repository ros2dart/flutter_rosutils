import 'package:flutter_rosutils/flutter_rosutils.dart';

class StringMessage extends Message {}

class ExampleBloc {
  RosMessageTopic<StringMessage> topic;
}
