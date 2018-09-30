import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TranslateView extends StatefulWidget {
  final trasnlateFrom;
  final translateTo;

  TranslateView({this.trasnlateFrom, this.translateTo});

  @override
  _TranslateViewState createState() => _TranslateViewState();
}

class _TranslateViewState extends State<TranslateView> {
  var _currentTranslatedTo = "";
  final myController = TextEditingController();
  bool isTranslating = false;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
          widget.trasnlateFrom == "en" ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 4.0,
          automaticallyImplyLeading: false,
          title: TextField(
            onChanged: (val) {
              _translate(
                  text: val,
                  from: widget.trasnlateFrom,
                  to: widget.translateTo);
            },
            controller: myController,
            autofocus: true,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: widget.trasnlateFrom == "en"
                    ? 'Tap To Enter Text (English)'
                    : 'چیزی برای ترجمه بنویسید (فارسی)'),
          ),
          actions: <Widget>[
            IconButton(
                onPressed: () {
                  _saveToSharedPreferences();
                  myController.text = '';
                },
                icon: Icon(Icons.close))
          ],
        ),
        body: Directionality(
          textDirection: widget.translateTo == "en"
              ? TextDirection.ltr
              : TextDirection.rtl,
          child: RaisedButton(
            padding: EdgeInsets.only(top: 2.0),
            onPressed: () {
              _saveToSharedPreferences();
              Navigator.pop(context, 'ok');
            },
            child: Material(
              elevation: 1.0,
              child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0.0),
                  child: Material(
                    elevation: 2.0,
                    child: ListTile(
                      title: Text(isTranslating
                          ? "${_currentTranslatedTo} ..."
                          : _currentTranslatedTo),
                    ),
                  )),
            ),
          ),
        ),
      ),
    );
  }

  void _translate({String text, from, to}) async {
    try {
      setState(() {
        isTranslating = true;
      });
      // final response = await http.get(Uri.encodeFull(
      //     'https://translate.googleapis.com/translate_a/single?client=gtx&sl=${from}&tl=${to}&dt=t&q=${text}&ie=UTF-8&oe=UTF-8'));
      //above is Google's own api but will block after few request till that use bello api
      final response = await http.get(Uri.encodeFull(
          'http://mozaffari.me/api/gtranslate/?from=${from}&to=${to}&text=${text}'));
      if (response.statusCode == 200) {
        print(text);
        // If the call to the server was successful, parse the JSON

        var _result = json.decode(response.body)['translated_text'];

        print("result:${_result} from:${from} to:${to} text:${text} \n ");

        setState(() {
          _currentTranslatedTo = _result;
          isTranslating = false;
        });
      } else {
        setState(() {
          _currentTranslatedTo = to == "en"
              ? "خطا در اتصال به شبکه"
              : "Faild To Connect to internet";
          isTranslating = false;
        });
        // If that call was not successful, throw an error.
        throw Exception('Failed to load data error:${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _currentTranslatedTo = to == "en"
            ? "خطا در اتصال به شبکه"
            : "Faild To Connect to internet";
        isTranslating = false;
      });
      print(e.toString());
    }
  }

  void _saveToSharedPreferences() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> _prevList = prefs.getStringList("recents") ?? [];
    myController.text != ""
        ? _prevList.add(
            jsonEncode({
              "from": widget.trasnlateFrom,
              "to": widget.translateTo,
              "orignalString": myController.text,
              "translatedString": _currentTranslatedTo,
            }),
          )
        : () {};

    prefs.setStringList('recents', _prevList);
    print("done Saving To Prefs");
  }
}
