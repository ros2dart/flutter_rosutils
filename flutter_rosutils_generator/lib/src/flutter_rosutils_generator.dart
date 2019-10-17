import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:flutter_rosutils/flutter_rosutils.dart';

class RosUtilsGenerator extends GeneratorForAnnotation<RosUtils> {
  RosUtilsGenerator();
  @override
  generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final stream = annotation.read('stream').boolValue;
    print('$stream');
    return "";
  }
}
