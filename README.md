<!-- 
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages). 

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages). 
-->

## Features

Listing images in gridview wrapped listview gives bad performance (display optimization fails),
because ListView only optimizes certain self. It does not bother to optimize its own widgets.
Therefore, the elements of the GridView are excluded from this state.

In addition, StickyGridView optimizes itself and all its sub-elements and prevents delays.

## Usage

First, create the header list.
And then create the Map<String, List<GridImage>> map.

<img src="https://github.com/fcenesiz/sticky_grid_view/blob/main/image.gif" align="right" height="300px" />
    
```dart
List<String> headers = [
    'Flags 1',
    'Flags 2',
    'Flags 3',
    'Flags 4',
    'Flags 5',
    'Flags 6'
  ];
  Map<String, List<GridImage>> map = {};
```

```dart
Future<void> initMap() async {
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
```
    
```dart
Widget build(BuildContext context) {
  return FutureBuilder(
      future: init,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          String error = "Error: " + snapshot.error.toString();
          return Center(child: Text(error));
        }
        return StickyGridView(
            headerFontSize: 19,
            backgroundColor: Colors.deepPurple.shade50,
            headerColor: Colors.deepPurple,
            headerTextColor: Colors.white,
            crossAxisCount: 6,
            map: map,
            headers: headers);
      });
}
```