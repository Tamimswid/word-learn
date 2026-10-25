import 'dart:io';

import 'package:flutter/services.dart';

import 'selection_data_source.dart';

class MacosSelectionDataSource implements SelectionDataSource {
  static const MethodChannel _channel = MethodChannel('wordlearn/selection');

  @override
  Future<String?> readSelectedText() async {
    if (!Platform.isMacOS) return null;

    return _channel.invokeMethod<String>('readSelectedText');
  }
}
