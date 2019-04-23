import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

class ItemInfo {
  String title;
  bool isDone = false;
}

class TODOListController {
  final _items = List<ItemInfo>();

  List<ItemInfo> get items => _items;

  final _itemsStreamController = StreamController<List<ItemInfo>>.broadcast();

  Sink<List<ItemInfo>> get itemsSink => _itemsStreamController.sink;

  Stream<List<ItemInfo>> get itemsStream => _itemsStreamController.stream;

  /// RX
  final statsObservable = BehaviorSubject<String>();

  final inputController = TextEditingController();

  void add(String text) {
    if (text.isEmpty) {
      return;
    }

    addItem(ItemInfo()..title = text);
  }

  void addItem(ItemInfo item) {
    items.add(item);
    inputController.text = '';

    itemsSink.add(items);
    recalculateStats();
  }

  void removeItem(ItemInfo item) {
    items.remove(item);

    itemsSink.add(items);
    recalculateStats();
  }

  void recalculateStats() {
    if (items.length > 0) {
      final count = items.where((item) => item.isDone).length;

      statsObservable.add("$count/${items.length}");
    } else {
      statsObservable.add(null);
    }
  }

  void dispose() {
    _itemsStreamController.close();
    statsObservable.close();
  }
}
