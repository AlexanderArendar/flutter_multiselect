import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyPopupRouteLayout extends SingleChildLayoutDelegate {
  final Offset parentPosition;
  final Size parentSize;
  final int itemsCount;

  MyPopupRouteLayout({
    @required this.parentPosition,
    @required this.parentSize,
    @required this.itemsCount,
  });

  @override
  bool shouldRelayout(SingleChildLayoutDelegate oldDelegate) {
    return true;
  }

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    double requiredSpace = (itemsCount * 20 + 25 + 5).toDouble();
    double maxHeight = min(constraints.maxHeight, requiredSpace);
    return BoxConstraints(
      maxHeight: maxHeight,
      maxWidth: constraints.maxWidth - (parentPosition.dx),
      minHeight: 0,
      minWidth: 0,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    double availableVSpace = size.height - parentPosition.dy - parentSize.height;
    if (availableVSpace >= childSize.height)
      return parentPosition + Offset(0, parentSize.height);
    else
      return parentPosition - Offset(0, childSize.height - parentSize.height);
  }
}

class OptionsList<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;

  OptionsList({
    @required this.items,
    this.selectedItems,
  });

  @override
  State<StatefulWidget> createState() => OptionsListState<T>();
}

class OptionsListState<T> extends State<OptionsList<T>> {
  List<T> _items;
  List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _selectedItems = widget.selectedItems == null ? [] : widget.selectedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemExtent: 20,
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return Row(
                  children: <Widget>[
                    Checkbox(
                      value: _selectedItems != null ? _selectedItems.indexOf(_items[index]) != -1 : false,
                      onChanged: (value) {
                        setState(() {
                          if (value && _selectedItems.indexOf(_items[index]) == -1)
                            _selectedItems.add(_items[index]);
                          else if (_selectedItems.indexOf(_items[index]) > -1) _selectedItems.remove(_items[index]);
                        });
                      },
                    ),
                    Text(_items[index].toString()),
                  ],
                );
              }),
          SizedBox(
            width: 70,
            height: 25,
            child: OutlineButton(
              textColor: Colors.green,
              child: Text(
                'Update',
                style: TextStyle(fontSize: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop(_selectedItems);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MultiSelectPopupRoute<T> extends PopupRoute<List<T>> {
  final Offset parentPosition;
  final Size parentSize;
  final List<T> items;
  final List<T> selectedItems;

  MultiSelectPopupRoute({
    @required this.parentPosition,
    @required this.parentSize,
    @required this.items,
    this.selectedItems,
  });

  @override
  Color get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String get barrierLabel => 'close me';

  @override
  Widget buildPage(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
    return CustomSingleChildLayout(
      delegate: MyPopupRouteLayout(
        parentPosition: parentPosition,
        parentSize: parentSize,
        itemsCount: items.length,
      ),
      child: OptionsList<T>(
        items: items,
        selectedItems: selectedItems,
      ),
    );
  }

  @override
  Duration get transitionDuration => Duration(milliseconds: 300);
}

class DropMultiSelect<T> extends StatefulWidget {
  final List<T> items;
  final List<T> selectedItems;

  DropMultiSelect({
    @required this.items,
    this.selectedItems,
  });

  @override
  State<StatefulWidget> createState() => DropMultiSelectState<T>();
}

class DropMultiSelectState<T> extends State<DropMultiSelect<T>> {
  List<T> _items;
  List<T> _selectedItems;

  @override
  void initState() {
    super.initState();
    _items = widget.items;
    _selectedItems = widget.selectedItems;
  }

  @override
  Widget build(BuildContext context) {
    String label = _selectedItems.length > 0 ? _selectedItems.map((t) => t.toString()).join(', ') : 'Dropdown label';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          label,
          overflow: TextOverflow.ellipsis,
        ),
        GestureDetector(
          child: Icon(Icons.arrow_drop_down),
          onTap: () {
            RenderBox box = context.findRenderObject();
            Offset position = box.localToGlobal(Offset.zero);
            Size size = box.size;
            Navigator.of(context)
                .push(
              MultiSelectPopupRoute(
                parentPosition: position,
                parentSize: size,
                items: _items,
                selectedItems: _selectedItems,
              ),
            )
                .then((value) {
              setState(() {
                _selectedItems = value == null ? _selectedItems : value;
              });
            }).catchError((e) => print(e));
          },
        )
      ],
    );
  }
}

class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 8,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
                'We provide child.layout with another parameter, parentUsesSize. If set to false, this means that the parent does not care what size the child chooses to be, which is very useful for optimizing the layout process; if the child changes its size, the parent would not have to re-layout! However, in our case, we want to put the child in the bottom right corner, meaning that we do care about what size it chooses to be, which forces us to set parentUsesSize to true.'),
            SizedBox(
              height: 10,
            ),
            DropMultiSelect<String>(
              items: ['item1', 'item2', 'item3', 'item4'],
              selectedItems: ['item2'],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
                'Until I write the next part, why don’t you try playing around with the StingyWidget and its children! Also, try to look around at the code of the different widgets that Flutter provides, you will see that some of them are Stateless and Stateful widgets, while others are RenderObjectWidgets. You will also see that there is still a hell lot to learn about rendering in Flutter! So see you in the next part!'),
          ],
        ),
      ),
    );
  }
}
