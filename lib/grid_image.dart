import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:nanoid/nanoid.dart';

class GridImage {

  String id = "?";
  late double x;
  late double y;
  late bool withPart;
  late double width;
  late double height;
  String _path;
  late ui.Image uiImage;

  GridImage(this._path);

  GridImage.fromAsset(this._path) {
    id = nanoid();
    withPart = false;
    x = 0;
    y = 0;
  }

  GridImage.fromAssetPart(this._path, this.x, this.y, this.width, this.height) {
    id = nanoid();
    withPart = true;
  }

  Future<void> initUiImage() async {
    final ByteData data = await rootBundle.load(_path);
    uiImage = await _loadImage(Uint8List.view(data.buffer));
    if(!withPart){
      width = uiImage.width as double;
      height = uiImage.height as double;
    }
  }

  Future<ui.Image> _loadImage(List<int> image) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(image as Uint8List, (ui.Image image) {
      return completer.complete(image);
    });
    return completer.future;
  }

  set path(String value) {
    _path = value;
  }
}
