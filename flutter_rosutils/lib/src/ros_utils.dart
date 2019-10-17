/// The annotation class that is going to be used to generate the source code
/// Where it works:

///
/// Example:
/// ```
/// @RosUtils()
/// RosMessageTopic<T extends RosMessage> messageTopic;
/// ```
class RosUtils {
  final bool stream;
  final String topic;

  const RosUtils({this.topic, this.stream});
}
