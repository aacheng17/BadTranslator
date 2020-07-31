import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:random_words/random_words.dart';
import 'package:http/http.dart' as http;

class Translator extends StatefulWidget {
  @override
  _Translator createState() => _Translator();
}

class _Translator extends State<Translator> {
  TextEditingController _textEditingController;

  bool _isLoading = false;
  String _string = "";

  void initState() {
    super.initState();
    _textEditingController = TextEditingController(text: "This is going to be translated badly.");
  }

  void dispose() {
    _textEditingController.dispose();
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

  void _asyncAction() async {
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
    return RaisedButton(
        child: Text("Randomize"),
        color: Colors.yellow,
        onPressed: _randomize
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
        ? CircularProgressIndicator()
        : RaisedButton(
        child: Text("Translate"),
        color: Colors.red,
        onPressed: _asyncAction
    );
  }

  Widget _textResult() {
    return Text(_string);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: Column(
                children: [
                  _buttonRandomize(),
                  _textFieldInput(),
                  _buttonTranslate(),
                  _textResult()
                ]
            )
        )
    );
  }
}