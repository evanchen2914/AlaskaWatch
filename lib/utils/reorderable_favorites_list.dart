import 'package:flutter/material.dart';

class ProfileEditEquipmentList extends StatefulWidget {
  List<EquipmentItemData> items;

  ProfileEditEquipmentList({this.items});

  @override
  ProfileEditEquipmentListState createState() =>
      ProfileEditEquipmentListState();
}

class ProfileEditEquipmentListState extends State<ProfileEditEquipmentList> {
  bool isReorderable = false;

  @override
  void initState() {
    super.initState();
  }

  // Returns index of item with given key
  int indexOfKey(Key key) {
    return widget.items.indexWhere((EquipmentItemData d) => d.key == key);
  }

  bool reorderCallback(Key item, Key newPosition) {
    int draggingIndex = indexOfKey(item);
    int newPositionIndex = indexOfKey(newPosition);

    final draggedItem = widget.items[draggingIndex];
    setState(() {
      widget.items.removeAt(draggingIndex);
      widget.items.insert(newPositionIndex, draggedItem);
    });
    return true;
  }

  void reorderDone(Key item) {
    final draggedItem = widget.items[indexOfKey(item)];
  }

  Widget build(BuildContext context) {
    return Container(
      height: widget.items.length * itemHeight +
          addButtonHeight +
          (addButtonTopMargin * 2),
      child: ReorderableList(
        onReorder: this.reorderCallback,
        onReorderDone: this.reorderDone,
        child: ListView.builder(
          padding: EdgeInsets.all(0),
          itemCount: widget.items.length + 1,
          itemBuilder: (BuildContext context, int index) {
            return index == widget.items.length
                ? Center(
              child: Container(
                margin: EdgeInsets.only(top: addButtonTopMargin),
                child: profileEditOutlineButton(
                    'Add Field', () => addField()),
              ),
            )
                : EquipmentItem(
              data: widget.items[index],
              isFirst: index == 0,
              isLast: index == widget.items.length - 1,
              onChangedText: (value) {
                setState(() {
                  widget.items[index].text = value;
                });
              },
              onChangedDeleteItem: (value) {
                if (value) {
                  setState(() {
                    widget.items.removeAt(index);
                  });
                }
              },
            );
          },
        ),
      ),
    );
  }

  void addField() {
    if (widget.items.isEmpty) {
      widget.items.add(EquipmentItemData(
          text: '', key: ValueKey(DateTime.now().microsecondsSinceEpoch)));
      FocusScope.of(context).requestFocus(FocusNode());

      setState(() {});
    } else if (widget.items.last.text.isNotEmpty) {
      widget.items.insert(
          widget.items.length,
          EquipmentItemData(
              text: '', key: ValueKey(DateTime.now().microsecondsSinceEpoch)));
      FocusScope.of(context).requestFocus(FocusNode());

      setState(() {});
    }
  }
}

class EquipmentItem extends StatelessWidget {
  EquipmentItem({
    EquipmentItemData data,
    bool isFirst,
    bool isLast,
    this.onChangedText,
    this.onChangedDeleteItem,
    TextEditingController textController,
  })  : data = data,
        isFirst = isFirst,
        isLast = isLast,
        textController = getCustomTextController(text: data.text);

  final EquipmentItemData data;
  final bool isFirst;
  final bool isLast;
  final ValueChanged<String> onChangedText;
  final ValueChanged<bool> onChangedDeleteItem;
  TextEditingController textController;

  Widget buildChild(BuildContext context, ReorderableItemState state) {
    BoxDecoration decoration;

    if (state == ReorderableItemState.dragProxy ||
        state == ReorderableItemState.dragProxyFinished) {
      decoration = BoxDecoration(color: Color(0xD0FFFFFF));
    } else {
      bool placeholder = state == ReorderableItemState.placeholder;
      decoration = BoxDecoration(
          border: Border(
              top: isFirst && !placeholder
                  ? Divider.createBorderSide(context) //
                  : BorderSide.none,
              bottom: isLast && placeholder
                  ? BorderSide.none //
                  : Divider.createBorderSide(context)),
          color: placeholder ? null : Colors.grey[100]);
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
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: 14,
                          bottom: 14,
                          left: 14,
                          right: 6,
                        ),
                        child: TextField(
                          controller: textController,
                          onChanged: (value) {
                            onChangedText(value);
                          },
                        ),
                      )),
                  // Triggers the reordering
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.grey[600],
                    ),
                    onPressed: () {
                      onChangedDeleteItem(true);
                    },
                  ),
                  ReorderableListener(
                    child: Container(
                      padding: EdgeInsets.only(right: 18.0, left: 18.0),
                      color: Color(0x08000000),
                      child: Center(
                        child: Icon(
                          Icons.reorder,
                          color: Color(0xFF888888),
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