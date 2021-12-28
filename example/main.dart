import 'dart:developer' as dev;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sticky_grid_view/grid_image.dart';
import 'package:sticky_grid_view/sticky_grid_view.dart';

void main() {
  runApp(MainWidget());
}

class MainWidget extends StatelessWidget {
  List<String> headers = [
    'Flags 1',
    'Flags 2',
    'Flags 3',
    'Flags 4',
    'Flags 5',
    'Flags 6'
  ];
  Map<String, List<GridImage>> map = {};

  late Future<void> init;

  MainWidget({Key? key}) : super(key: key) {
    init = initF();
  }

  Future<void> initF() async {
    double width = 28;
    double height = 20;
    for (int i = 0; i < headers.length; i++) {
      List<GridImage> gridItems = [];
      double y = i * height;
      int range = 5 + Random().nextInt(11);
      for (int j = 0; j < range; j++) {
        double x = j * width;
        GridImage gridItem = GridImage.fromAssetPart(
            'assets/images/all_flags.png', x, y, width, height);
        await gridItem.initUiImage();
        gridItems.add(gridItem);
      }
      map[headers[i]] = gridItems;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.deepPurple,
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text('StickyGridView'),
          centerTitle: true,
        ),
        body: FutureBuilder(
            future: init,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                String error = "Hata: " + snapshot.error.toString();
                return Center(child: Text(error));
              }
              return StickyGridView(headerFontSize: 19, backgroundColor: Colors.deepPurple.shade50, headerColor: Colors.deepPurple, headerTextColor: Colors.white, crossAxisCount: 6,map: map, headers: headers, onClick: (int section, int index) {
                dev.log('section:${headers[section]}, index: $index');
              },);
            }),
      ),
    );
  }
}
