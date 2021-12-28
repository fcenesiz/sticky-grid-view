import 'dart:developer';

import 'package:flutter/material.dart';
import 'grid_image.dart';
import 'dart:ui' as ui;

typedef OnCanvasChanged = void Function(List<double> offsets);



class GridPainter extends CustomPainter {

  List<String> headers;
  List<TextSpan> headerSpans = [];
  Map<String, List<GridImage>> map;
  int crossAxisCount;
  FilterQuality filterQuality;
  BuildContext context;
  final double padding;
  final Color headerColor;
  final Color headerTextColor;
  final Color backgroundColor;
  final double headerFontSize;
  bool firstCycle = true;
  late final Paint painter;
  late final TextPainter textPainter;
  late final double boxSize;
  late final double headerSize;
  late final ScrollController scrollController;
  OnCanvasChanged onCanvasChanged;


  double blinkVal;
  String clickedItemId;
  GridPainter({required this.headers,
    required this.map,
    required this.context,
    required this.crossAxisCount,
    required this.filterQuality,
    required this.padding,
    required this.scrollController,
    required this.blinkVal,
    required this.clickedItemId,
    this.headerFontSize = 14,
    required this.headerColor,
    required this.headerTextColor,
    required this.backgroundColor,
    required this.onCanvasChanged}) {
    painter = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..filterQuality = filterQuality;
    textPainter = TextPainter();
    textPainter.textDirection = TextDirection.ltr;
    for (var header in headers) {
      headerSpans.add(TextSpan(
          text: header, style: TextStyle(fontSize: headerFontSize, color: headerTextColor)));
    }
    boxSize = MediaQuery
        .of(context)
        .size
        .width / crossAxisCount;
    headerSize = boxSize * 0.5;
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(backgroundColor, BlendMode.src);
    drawHeaders(canvas, size);
    return;
  }

  void drawHeaders(Canvas canvas, Size size) {
    late List<double> headerTops;
    if (firstCycle) headerTops = [];

    for (int i = 0; i < headerSpans.length; i++) {
      TextSpan span = headerSpans[i];
      textPainter.text = span;
      textPainter.layout();
      double scrollOffset = scrollController.offset;
      double headerTop = getHeaderTop(i, i, span);
      headerTops.add(headerTop + headerSize);
      double posTop = headerTop < scrollOffset ? scrollOffset : headerTop;
      bool isInvisible =
      drawItems(canvas, size, headers[i], headerTop + headerSize);
      if (isInvisible) continue;
      painter.color = headerColor;
      canvas.drawRect(
          Rect.fromLTWH(0, posTop, boxSize * crossAxisCount, headerSize),
          painter);
      painter.color = backgroundColor;
      textPainter.paint(canvas, Offset(2.5, posTop + 5));
    }

    if (firstCycle) onCanvasChanged(headerTops);
  }

  bool drawItems(Canvas canvas, Size size, String header, double offset) {
    List<GridImage>? items = map[header];

    double lastItemPosition = -scrollController.offset +
        getItemTop(items!.length - 1) +
        offset +
        boxSize;
    bool isInvisible = lastItemPosition < 0;
    if (isInvisible) return true;

    for (int i = 0; i < items.length; i++) {
      GridImage item = items[i];


      double position = -scrollController.offset + getItemTop(i) + offset;
      bool isInvisible = position < -boxSize ||
          position > scrollController.position.viewportDimension;
      if (isInvisible) continue;
      double itemSize = boxSize * (1 - padding);
      double posLeft = getItemLeft(i) + (boxSize - itemSize) * 0.5;
      double posTop = offset + getItemTop(i) + (boxSize - itemSize) * 0.5;

      double nWidth = 0;
      double nHeight = 0;
      double pT = posTop;
      double pL = posLeft;
      if(item.width >= item.height){
        nWidth = itemSize;
        nHeight = (item.height / item.width) * itemSize;
        double t1 = boxSize - nHeight;
        double t2 = t1 - nHeight;
        double t3 = t2 / 2;
        pT -= t3;
      }
      else{
        nHeight = itemSize;
        nWidth = (item.width / item.height) * itemSize;
        double t1 = boxSize - nWidth;
        double t2 = t1 - nWidth;
        double t3 = t2 / 2;
        pL -= t3;
      }
      canvas.drawImageRect(
          item.uiImage,
          // Source image bounds
          Rect.fromLTWH(item.x, item.y,
              item.width, item.height),
          // Destination image bounds
          Rect.fromLTWH(pL, pT, nWidth, nHeight),
          painter);
      if(clickedItemId == item.id){
        painter.color = const Color(0xff000000).withOpacity(blinkVal);
        canvas.drawRect(Rect.fromLTWH(posLeft - boxSize / 10, posTop - boxSize / 10, boxSize, boxSize), painter);
        painter.color = backgroundColor;
      }
    }
    return false;
  }

  double getHeaderTop(int next, int headerIndex, TextSpan span) {
    if (next == 0 && headerIndex == 0) return 0;
    if (next == 0) return 0;
    int length = map[headers[next - 1]]!.length;
    double rawLayer = length / crossAxisCount;
    int layer = rawLayer.floor();
    bool isBig = length > (layer * crossAxisCount);
    double itemsHeight = (isBig ? layer + 1 : layer) * boxSize;
    next--;
    double bound =
        headerSize + itemsHeight + getHeaderTop(next, headerIndex, span);
    return bound;
  }

  double getItemTop(int index) {
    return (index / crossAxisCount).floor().toDouble() * boxSize;
  }

  double getItemLeft(int index) {
    return (index % crossAxisCount).floor().toDouble() * boxSize;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  @override
  bool shouldRebuildSemantics(covariant CustomPainter oldDelegate) => true;
}