library sticky_grid_view;

import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'grid_image.dart';
import 'grid_painter.dart';

typedef OnClick = void Function(int section, int index);

class StickyGridView extends StatefulWidget {

  final Map<String, List<GridImage>> map;
  final List<String> headers;
  final int crossAxisCount;
  final double padding;
  final FilterQuality filterQuality;
  final double headerFontSize;
  final Color headerColor;
  final Color headerTextColor;
  final Color backgroundColor;
  final OnClick onClick;

  const StickyGridView(
      {Key? key,
      required this.headers,
      required this.map,
      this.crossAxisCount = 5,
      this.padding = 0.2,
      this.filterQuality = FilterQuality.low,
        this.headerFontSize = 14,
      this.headerColor = Colors.blue,
      this.headerTextColor = Colors.white,
      this.backgroundColor = Colors.white,
      required this.onClick})
      : super(key: key);

  @override
  _StickyGridViewState createState() => _StickyGridViewState();
  
}

class _StickyGridViewState extends State<StickyGridView>
    with SingleTickerProviderStateMixin {
  /// Configuration of gridview
  ScrollController scrollController = ScrollController();
  late double cellSize = 56;
  int clickedIndex = -1;
  String clickedItemId = "?";
  late Offset clickedOffset;
  List<double> offsets = [];

  /// Animations
  double blinkVal = 0.0;
  late Animation<double> blinkAnim;
  late AnimationController animationController;

  _StickyGridViewState() {
    initAnimations();
  }

  @override
  void initState() {
    _afterLayoutBuilt();
    super.initState();
  }

  void initAnimations() {
    animationController =
        AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    blinkAnim = Tween(begin: 0.5, end: 0.0).animate(animationController)
      ..addListener(() {
        setState(() {
          blinkVal = blinkAnim.value;
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      child: SingleChildScrollView(
        controller: scrollController,
        //physics: NeverScrollableScrollPhysics(),
        child: CustomPaint(
          size: Size(
              MediaQuery
                  .of(context)
                  .size
                  .width, getHeightOfScrollView()),
          painter: GridPainter(
              headers: widget.headers,
              map: widget.map,
              context: context,
              crossAxisCount: widget.crossAxisCount,
              filterQuality: widget.filterQuality,
              padding: widget.padding,
              scrollController: scrollController,
              blinkVal: blinkVal,
              clickedItemId: clickedItemId,
              headerFontSize: widget.headerFontSize,
              headerColor: widget.headerColor,
              headerTextColor: widget.headerTextColor,
              backgroundColor: widget.backgroundColor,
              onCanvasChanged: (List<double> offsets) {
                if (this.offsets.isEmpty) {
                  this.offsets.addAll(offsets);
                }
              }
              ),
        ),
      ),
    );
  }

  void _afterLayoutBuilt() {
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      cellSize = MediaQuery
          .of(context)
          .size
          .width / widget.crossAxisCount;
    });
  }

  double getHeightOfScrollView() {
    double boxSize = (MediaQuery
        .of(context)
        .size
        .width / widget.crossAxisCount + 1);
    double headerHeights = widget.headers.length * (boxSize * 0.45);
    double itemHeights = 0;
    for (int i = 0; i < widget.headers.length; i++) {
      int length = widget.map[widget.headers[i]]!.length;
      double rawLayer = length / widget.crossAxisCount;
      int layer = rawLayer.floor();
      bool isBig = length > (layer * widget.crossAxisCount);
      double height = (isBig ? layer + 1 : layer) * boxSize;
      itemHeights += height;
    }
    return headerHeights + itemHeights;
  }

  void onTapDown(TapDownDetails details) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    clickedOffset = box.globalToLocal(details.globalPosition);
    clickedItemId = '?';
    blinkVal = 0.5;
  }

  void onTap() {
    animationController.reset();
    animationController.forward();
    final dx = clickedOffset.dx;
    double dy = clickedOffset.dy + scrollController.offset;
    double headerOffset = 0;
    int index = 0;
    int lastIndex = offsets.length - 1;
    if (dy > offsets[lastIndex]) {
      headerOffset = offsets[lastIndex];
      index = lastIndex;
    } else {
      for (int i = 0; i < offsets.length; i++) {
        if (i < offsets.length - 1) {
          if (dy > offsets[i] && dy < offsets[i + 1]) {
            headerOffset = offsets[i];
            index = i;
            break;
          }
        }
      }
    }
    dy -= headerOffset;
    final tapedRow = (dx / cellSize).floor();
    final tapedColumn = (dy / cellSize).floor();
    clickedIndex = tapedColumn * widget.crossAxisCount + tapedRow;

    try {
      String clickedItemId = widget.map[widget.headers[index]]![clickedIndex].id;
      this.clickedItemId = clickedItemId;
      widget.onClick(index, clickedIndex);
    } catch (exception) {
      log("Clicked to the empty field." + exception.toString());
    }
  }

}
