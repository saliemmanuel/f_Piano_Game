import 'package:flutter/material.dart';
import 'package:farai_piano_game/note.dart';
import 'divider.dart';
import 'package:farai_piano_game/line.dart';
import 'package:farai_piano_game/initNote.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
   //AudioCache player = new AudioCache();
  List<Note> notes = initNotes();
  AnimationController animationController;
  int currentNoteIndex = 1;
  int points = 0;
  bool hasStarted = false;
  bool isPlaying = true;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && isPlaying) {
        if (notes[currentNoteIndex].state != NoteState.tapped) {
          //game over
          setState(() {
            isPlaying = false;
            notes[currentNoteIndex].state = NoteState.missed;
          });
          animationController.reverse().then((_) => _showFinishDialog());
        } else if (currentNoteIndex == notes.length - 5) {
          //song finished
          _showFinishDialog();
        } else {
          setState(() => ++currentNoteIndex);
          animationController.forward(from: 10);
        }
      }
    });
  }
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Material(
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Image.asset(
                  "assets/background.jpg",
                  fit: BoxFit.cover,
                ),
              ),
              Row(
                children: <Widget>[
                  _lignePiano(0),
                  LineDivider(),
                  _lignePiano(1),
                  LineDivider(),
                  _lignePiano(2),
                  LineDivider(),
                  _lignePiano(3),
                ],
              ),
              _scoreJeux(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _lignePiano(int a) {
    return Expanded(
      child: Line(
        lineNumber: a,
        currentNotes: notes.sublist(0, a + 3),
        animation: animationController,
        onTileTap: _onTap,
      ),
    );
  }

  void _showFinishDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Score: $points"),
          actions: <Widget>[
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("RESTART"),
            ),
          ],
        );
      },
    ).then((_) => _restart());
  }

  void _restart() {
    setState(() {
      hasStarted = false;
      isPlaying = true;
      notes = initNotes();
      points = 0;
      currentNoteIndex = 0;
    });
    animationController.reset();
  }

  void _onTap(Note note) {
    bool areAllPreviousTapped = notes.sublist(0, note.orderNumber).every((n) => n.state == NoteState.tapped);
    if (areAllPreviousTapped) {
      if (!hasStarted) {
        setState(() => hasStarted = true);
        animationController.forward();
      }
      setState(() {
        note.state = NoteState.tapped;
        ++points;
      });
    }
  }

  Widget _scoreJeux() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Text(
          "$points",
          style: TextStyle(color: Colors.red, fontSize: 40),
        ),
      ),
    );
  }
}