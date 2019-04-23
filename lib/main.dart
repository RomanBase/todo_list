import 'package:flutter/material.dart';
import 'package:todo_list/todo_list_controller.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TODO List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TODOList(),
    );
  }
}

/// Stateless - varianta a StreamBuilder pro komunikanici mezi UI a Controllerem
class TODOList extends StatelessWidget {
  final controller = TODOListController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TODO List'),
        actions: <Widget>[
          StreamBuilder<String>(
            stream: controller.statsObservable,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    snapshot.data,
                    style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          RaisedButton(
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => TODOList()));
            },
            child: Text('new list'),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: TextField(
                    controller: controller.inputController,
                    onSubmitted: controller.add,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () => controller.add(controller.inputController.text),
              )
            ],
          ),
          StreamBuilder<List<ItemInfo>>(
            stream: controller.itemsStream,
            builder: (BuildContext context, AsyncSnapshot<List<ItemInfo>> snapshot) {
              if (snapshot.hasData && snapshot.data.length > 0) {
                return buildList(snapshot.data);
              } else {
                return Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Text(
                    'Your list is empty..',
                    textAlign: TextAlign.center,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget buildList(List<ItemInfo> items) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => TODOItem(
              key: ObjectKey(items[index]),
              item: items[index],
              controller: controller,
            ),
      ),
    );
  }
}

/// Statefull - logika je uvnitr State tridy
class TODOItem extends StatefulWidget {
  final ItemInfo item;
  final TODOListController controller;

  const TODOItem({Key key, @required this.item, @required this.controller}) : super(key: key);

  @override
  _TODOItemState createState() => _TODOItemState();
}

class _TODOItemState extends State<TODOItem> {
  ItemInfo get item => widget.item;

  void setDoneState(bool isDone) {
    setState(() {
      item.isDone = isDone;
      widget.controller.recalculateStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: widget.key,
      onDismissed: (args) => widget.controller.removeItem(item),
      background: Container(
        color: Colors.red,
      ),
      child: SizedBox(
        height: 56.0,
        child: FlatButton(
          child: Row(
            children: <Widget>[
              Checkbox(value: item.isDone, onChanged: setDoneState),
              Text(item.title),
            ],
          ),
          onPressed: () => setDoneState(!item.isDone),
        ),
      ),
    );
  }
}
