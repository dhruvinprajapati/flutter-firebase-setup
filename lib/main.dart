import 'package:firebase_setup/modal/board.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';



void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Community Board',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // int _counter = 0;

  List<Board> boardMessages = List();
  Board board;
  final FirebaseDatabase database = FirebaseDatabase.instance;
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  DatabaseReference databaseReference;


  @override
  void initState() { 
    super.initState();
    board = Board("", "");
    databaseReference = database.reference().child("Community_board");
    databaseReference.onChildAdded.listen(_onEntryAdded);
    databaseReference.onChildChanged.listen(_onEntrychange);
          }
        
          // void _incrementCounter() {
        
          //   database.reference().child("message").set({
          //     "firstname":"Dhruvin",
          //     "lastname" : "prajapati",
          //     "Age" : 1
          //   });
          //   setState(() {
          //     database.reference().child("message").once().then((DataSnapshot snapshot){
          //       Map<dynamic , dynamic> list = snapshot.value;
          //       print("values DB:-${snapshot.key}");
          //     });
          //     _counter++;
          //   });
          // }
        
          @override
          Widget build(BuildContext context) {
            
            return Scaffold(
              appBar: AppBar(
                
                title: Text("Board"),
              ),
              body: Column(
                children: <Widget>[
                  Flexible(
                    flex: 0,
                    child: Form(
                      key: formkey,
                      child: Flex(
                        direction: Axis.vertical,
                        children: <Widget>[
                          ListTile(
                            leading: Icon(Icons.subject),
                            title: TextFormField(
                              initialValue: "",
                              onSaved: (val) => board.subject = val,
                              validator: (val) => val == ""? val : null,
                            ),
                          ),
                          ListTile(
                            leading: Icon(Icons.message),
                            title: TextFormField(
                              initialValue: "",
                              onSaved: (val) => board.body = val,
                              validator: (val) => val == ""? val : null,
                            ),
                          ),
                          FlatButton(
                              child: Text("POST"),
                              color: Colors.red,
                              onPressed: () {
                                heandlesubmit();
                              },
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    child: FirebaseAnimatedList(
                      query: databaseReference,
                      itemBuilder: (_,DataSnapshot snapshot,Animation<double> animation,int index){
                        return new Card(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.red,
                            ),
                            title: Text(boardMessages[index].subject),
                            subtitle: Text(boardMessages[index].body),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              )
               // This trailing comma makes auto-formatting nicer for build methods.
            );
          }
        
          void _onEntryAdded(Event event) {
            setState(() {
             boardMessages.add(Board.fromSnapshot(event.snapshot)); 
            });
      }
    
      void heandlesubmit() {
        final FormState form = formkey.currentState;
        if (form.validate()){
          form.save();
          form.reset();
          databaseReference.push().set(board.toJson());
        }
      }
    
      void _onEntrychange(Event event) {
        var oldentry = boardMessages.singleWhere((entry){
          return entry.key == event.snapshot.key;
        });
        setState(() {
         boardMessages[boardMessages.indexOf(oldentry)]=Board.fromSnapshot(event.snapshot); 
        });
  }
}
