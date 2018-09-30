import 'dart:convert';

import 'package:gtranslate/translate_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Persian Dic',
      theme: new ThemeData(
        // primarySwatch: Colors.blue,
        primaryColor: Colors.white,
        fontFamily: "iran-sans",
      ),
      home: new MyHomePage(title: 'Translator'),
    );
  }
}

class TranslatePage {}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _translateFrom = "en";
  var _translateTo = "fa";

  List<String> _recentTranlates = [];
  _getRecentsFromSharedPrefsFolder() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    List<String> _prevList = prefs.getStringList("recents") ?? [];

    setState(() {
      _recentTranlates = _prevList;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _getRecentsFromSharedPrefsFolder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        elevation: 1.0,
        centerTitle: true,
        title: new Text(
          widget.title,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Colors.deepPurple,
          ),
        ),
      ),
      body: new Container(
        child: new Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 220.0,
                width: double.infinity,
                child: Material(
                  elevation: 1.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 15.0),
                        child: Row(
                          children: <Widget>[
                            _buildLangSelctor(_translateFrom),
                            Expanded(
                              child: Container(),
                            ),
                            IconButton(
                              icon: Icon(
                                IconData(0xe801, fontFamily: 'GTranslate'),
                                color: Colors.deepPurple,
                              ),
                              onPressed: () {
                                _swapLang();
                              },
                            ),
                            Expanded(
                              child: Container(),
                            ),
                            _buildLangSelctor(_translateTo),
                          ],
                        ),
                      ),
                      Divider(
                        color: Colors.deepPurple,
                      ),
                      // input section
                      Directionality(
                        textDirection: _translateFrom == "en"
                            ? TextDirection.ltr
                            : TextDirection.rtl,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          child: InkWell(
                            onTap: () {
                              _getRecentsFromSharedPrefsFolder();
                              _goToTranslatePage();
                            },
                            child: TextField(
                              keyboardType: TextInputType.multiline,
                              maxLines: 4,
                              enabled: false,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: _translateFrom == "en"
                                      ? 'Tap To Enter Text'
                                      : "چیزی برای ترجمه بنویسید "),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              //recents section
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Material(
                    elevation: 1.0,
                    child: _buildRecnts(),
                  ),
                ),
              ),
            ]),
      ),
    );
  }

  _buildLangSelctor(key) {
    return Row(
      children: <Widget>[
        SizedBox(
          height: 50.0,
          child: key == "fa"
              ? Image.asset("assets/flags/ir.png")
              : Image.asset("assets/flags/us.png"),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 14.0),
          child: key == "fa" ? Text("Persian") : Text("English"),
        )
      ],
    );
  }

  _swapLang() {
    setState(() {
      var tmp = _translateFrom;
      _translateFrom = _translateTo;
      _translateTo = tmp;

      // _visible = !_visible;
    });
  }

  _buildRecnts() {
    return _recentTranlates.length <= 0
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                IconData(0xe804, fontFamily: 'GTranslate'),
                color: Colors.grey.shade400,
                size: 80.0,
              ),
              Container(
                height: 25.0,
              ),
              Text(
                "No Translation Yet",
                style: TextStyle(color: Colors.grey.shade400, fontSize: 20.0),
              ),
            ],
          )
        : Container(
            child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () {
                  _clearSharedPrefs();
                },
              ),
              Flexible(
                child: ListView.builder(
                  itemCount: _recentTranlates.length,
                  itemBuilder: (BuildContext context, index) {
                    final item = json.decode(_recentTranlates[index]);
                    return Column(
                      children: <Widget>[
                        ListTile(
                          title: Text(
                            item['orignalString'],
                            textDirection: item['from'] == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                          ),
                          subtitle: Text(
                            item['translatedString'],
                            textDirection: item['to'] == "en"
                                ? TextDirection.ltr
                                : TextDirection.rtl,
                          ),
                        ),
                        Divider(
                          color: Colors.grey.shade300,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ));
  }

  void _goToTranslatePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => TranslateView(
                trasnlateFrom: _translateFrom,
                translateTo: _translateTo,
              )),
    );

    _getRecentsFromSharedPrefsFolder();
  }

  void _clearSharedPrefs() async {
    setState(() {
      _recentTranlates = [];
    });
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setStringList('recents', []);
    print("done Clearing SharedPrefs");

    // var _rslt = prefs.setString("name", "ali");
    //print(_rslt);
  }
}
