import 'package:build/build.dart';

import 'package:source_gen/source_gen.dart';

import 'package:flutter_rosutils_generator/src/flutter_rosutils_generator.dart';

Builder rosutilsGenerator(BuilderOptions options) =>
    SharedPartBuilder(const [RosUtilsGenerator()], 'rosutils_generator');
