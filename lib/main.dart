import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHome(
        storage: Storage(),
      ),
    );
  }
}

class MyHome extends StatefulWidget {
  final Storage storage;

  MyHome({Key key, @required this.storage}) : super(key: key);
  @override
  _MyHomeState createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  TextEditingController controller = TextEditingController();
  String state;
  Future<Directory> _appDocDir;

  @override
  void initState() {
    super.initState();
    widget.storage.readData().then((String value) {
      setState(() {
        state = value;
      });
    });
  }

  Future<File> writeData() async {
    setState(() {
      state = controller.text;
      controller.text = '';
    });
    return widget.storage.writeData(state);
  }

  void getAppDirectory() {
    setState(() {
      _appDocDir = getApplicationDocumentsDirectory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('R/W file'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[Text('${state ?? "File is empty!"}'), 
          TextField(
            controller: controller,
          ),
          RaisedButton(child: Text('Write to File'),onPressed: writeData,),
          RaisedButton(child: Text('Get dir'), onPressed: getAppDirectory,),
          FutureBuilder<Directory>(future: _appDocDir, builder: (BuildContext context, AsyncSnapshot<Directory> snapshot){
            Text text = Text('');
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasError) {
                text = Text('Error : ${snapshot.error}');
              } else if (snapshot.hasData) {
                text = Text('Path : ${snapshot.data.path}');
              } else {
                text = Text('Unavailable');
              }
            }
            return new Container(child: text,);
          },)
          ],
        ),
      ),
    );
  }
}

class Storage {
  Future<String> get localPath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<File> get localFile async {
    final path = await localPath;
    return File('$path/db.txt');
  }

  Future<String> readData() async {
    try {
      final file = await localFile;
      String body = await file.readAsString();
    } catch (e) {
      return e.toString();
    }
  }

  Future<File> writeData(String data) async {
    final file = await localFile;
    return file.writeAsString('$data');
  }
}
