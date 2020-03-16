import 'package:alaskawatch/models/favorites_edit.dart';
import 'package:alaskawatch/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reorderable_list/flutter_reorderable_list.dart';

double itemHeight = 58;
double itemPadding = 14;

class FavoritesItemData {
  final Key key;
  final String location;
  final String zip;

  FavoritesItemData({this.zip, this.location, this.key});
}

class ReorderableFavoritesList extends StatefulWidget {
  ReorderableFavoritesList();

  @override
  ReorderableFavoritesListState createState() =>
      ReorderableFavoritesListState();
}

class ReorderableFavoritesListState extends State<ReorderableFavoritesList> {
  FavoritesEdit favoritesEdit;

  @override
  void initState() {
    super.initState();

    favoritesEdit = FavoritesEdit.getModel(context);
  }

  int indexOfKey(Key key) {
    return favoritesEdit.favoritesItems
        .indexWhere((FavoritesItemData d) => d.key == key);
  }

  bool reorderCallback(Key item, Key newPosition) {
    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    final draggedItem = favoritesEdit.favoritesItems[draggingIndex];

    setState(() {
      favoritesEdit.favoritesItems.removeAt(draggingIndex);
      favoritesEdit.favoritesItems.insert(newPositionIndex, draggedItem);
    });

    return true;
  }

  void reorderDone(Key item) {
    final draggedItem = favoritesEdit.favoritesItems[indexOfKey(item)];
  }

  Widget build(BuildContext context) {
    double height = 0;
    if (favoritesEdit.favoritesItems.length >= 2) {
      height = (favoritesEdit.favoritesItems.length - 1) * itemPadding;
    }

    return Container(
      height: favoritesEdit.favoritesItems.length * itemHeight + height + 5,
      child: ReorderableList(
        onReorder: this.reorderCallback,
        onReorderDone: this.reorderDone,
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: favoritesEdit.favoritesItems.length,
          itemBuilder: (BuildContext context, int index) {
            bool isFirst = index == 0;
            bool isLast = index == favoritesEdit.favoritesItems.length - 1;

            return Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : itemPadding),
              child: FavoritesItem(
                data: favoritesEdit.favoritesItems[index],
                isFirst: isFirst,
                isLast: isLast,
                onChangedDeleteItem: (value) {
                  if (value) {
                    setState(() {
                      favoritesEdit.favoritesItems.removeAt(index);
                    });
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class FavoritesItem extends StatelessWidget {
  FavoritesItem({
    FavoritesItemData data,
    bool isFirst,
    bool isLast,
    this.onChangedDeleteItem,
  })  : data = data,
        isFirst = isFirst,
        isLast = isLast;

  final FavoritesItemData data;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<bool> onChangedDeleteItem;

  Widget buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = BoxDecoration(
        color: Colors.white,
        border: Border.all(
          width: 2.5,
          color: kAppSecondaryColor,
        ),
        borderRadius: BorderRadius.circular(kAppBorderRadius),
      );
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      var border;

      if (placeholder) {
        border = null;
      } else {
        border = Border.all(
          width: 2.5,
          color: kAppPrimaryColor,
        );
      }

      decoration = BoxDecoration(
        border: border,
        color: placeholder ? null : Colors.white30,
        borderRadius: BorderRadius.circular(kAppBorderRadius),
      );
    }

    Widget content = Container(
      height: itemHeight,
      decoration: decoration,
      child: SafeArea(
          top: false,
          bottom: false,
          child: Opacity(
            opacity: state == ReorderableItemState.placeholder ? 0.0 : 1.0,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 12),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${data?.zip} - ${data?.location}',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: kAppPrimaryColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[500],
                    ),
                    onPressed: () {
                      onChangedDeleteItem(true);
                    },
                    padding: EdgeInsets.all(0),
                  ),
                  ReorderableListener(
                    child: Container(
                      padding: EdgeInsets.only(right: 12, left: 2),
                      child: Center(
                        child: Icon(
                          Icons.reorder,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )),
    );

    return content;
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableItem(key: data.key, childBuilder: buildChild);
  }
}
