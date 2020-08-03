import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:random_words/random_words.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

class Translator extends StatefulWidget {
  @override
  _Translator createState() => _Translator();
}

class _Translator extends State<Translator> with SingleTickerProviderStateMixin {
  TextEditingController _textEditingController;
  TabController _tabController;

  bool _isLoading = false;
  String _string = "";
  bool _about = false;

  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: "This is going to be translated badly.");
    _tabController = TabController(vsync: this, length: 2);
  }

  void dispose() {
    _textEditingController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<String> _sendRequest(String s) async {
    String url = "https://lit-ocean-80355.herokuapp.com/api/search?q=" + Uri.encodeFull(s);
    String data = await http.read(url);
    print(data);
    return jsonDecode(data)["results"];
  }

  Future<void> _translate() async {
    try {
      String s = _textEditingController.text;
      print("1:"+s);
      s = await _sendRequest(s);
      print("2:"+s);
      setState(() => _string = s);
    } catch (e) {
      print("Error translating: " + e);
    }
  }

  void _translateHandler() async {
    setState(() => _isLoading = true);
    await _translate();
    setState(() => _isLoading = false);
  }

  void _randomize() {
    String adj = generateAdjective().take(1).elementAt(0).toString();
    adj = adj[0].toUpperCase() + adj.substring(1);
    String noun1 = generateNoun().take(1).elementAt(0).toString();
    String noun2 = generateNoun().take(1).elementAt(0).toString();
    String punc = ([".",".",".",".",".",".",".",".","!","?"]..shuffle()).first;
    setState(() => _textEditingController.text = adj + " " + noun1 + " " + noun2 + punc);
  }

  Widget _buttonRandomize() {
    return ButtonTheme(
      minWidth: 120.0,
      child: FlatButton(
        child: Text("Randomize"),
        color: Colors.yellow,
        splashColor: Colors.orange,
        onPressed: _randomize
      )
    );
  }

  Widget _textFieldInput() {
    return TextField(
      controller: _textEditingController,
      maxLength: 200
    );
  }

  Widget _buttonTranslate() {
    return _isLoading
      ? CircularProgressIndicator( valueColor: new AlwaysStoppedAnimation<Color>(Colors.red))
      : ButtonTheme(
      minWidth: 120.0,
      child: FlatButton(
        child: Text("Translate"),
        color: Colors.red,
        textColor: Colors.white,
        onPressed: _translateHandler
      )
    );
  }

  Widget _textResult() {
    return Text(_string);
  }

  void _aboutHandler() {
    setState(() => _about = !_about);
    _tabController.animateTo((_tabController.index + 1) % 2);
  }

  Widget _buttonAbout() {
    return ButtonTheme(
      minWidth: 100.0,
      height: 30.0,
      child: FlatButton(
        child: Text(!_about ? "What is this?" : "Back", style: TextStyle(fontSize: 12)),
        onPressed: _aboutHandler
      )
    );
  }

  Widget _mainBody() {
    return Column(
      children: [
        _buttonRandomize(),
        _textFieldInput(),
        _buttonTranslate(),
        _textResult()
      ]
    );
  }

  Widget _aboutBody() {
    return Column(
      children: [
        Text("BadTranslator\n", style: TextStyle(fontSize: 30)),
        Text(
            "This site takes your input (in English only for now) and translates it through 10 random languages and then back to English."
        ),
        FlatButton(
          child: Text("GitHub link", style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
          onPressed: () => html.window.open('https://github.com/aacheng17/BadTranslator', 'new tab')
        )
      ]
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          padding: EdgeInsets.all(25.0),
          child: DefaultTabController(
            length: 2,
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                _mainBody(),
                _aboutBody()
              ]
            )
          )
        )
      ),
      floatingActionButton: _buttonAbout(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
    );
  }
}