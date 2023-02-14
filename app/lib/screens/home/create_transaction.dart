import 'dart:html';

import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/list_of_categ.dart';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/transact.dart';
import '../../services/auth_service.dart';

void main() => runApp(CreateTransacton());

class CreateTransacton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Flutter Form Demo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
          backgroundColor: Colors.grey,
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  var _streamCategoriesList;
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  late Stream<QuerySnapshot> _streamCategoriesList;
  CollectionReference _referenceCategoriesList =
      FirebaseFirestore.instance.collection('transactions');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _streamCategoriesList = _referenceCategoriesList.where("category", isNotEqualTo: '').snapshots();
  }

  //FirebaseFirestore ref = FirebaseFirestore.instance;
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  final _formKey = GlobalKey<FormState>();
  final Map<String, TextEditingController> myController = {
    'amount': TextEditingController(),
    'category': TextEditingController(),
    'date': TextEditingController(),
    'persistent': TextEditingController(),
    'place': TextEditingController(),
    'title': TextEditingController(),
    'notes': TextEditingController(),
    'expense': TextEditingController(),
  };

  //var valuefirst;
  bool valuefirst = false;
  bool valuesec = false;

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Flexible(
            flex: 2,
            fit: FlexFit.tight,
            child: TextFormField(
              controller: myController['amount'],
              decoration: const InputDecoration(
                icon: const Icon(Icons.money),
                hintText: 'Enter the amount',
                labelText: 'Amount',
                iconColor: Colors.grey,
              ),
            ),
          ),
          //create dropdown list from the categories so far
          TextFormField(
            controller: myController['category'],
            decoration: const InputDecoration(
              icon: const Icon(Icons.add_box),
              hintText: 'Enter category',
              labelText: 'Category',
            ),
          ),

          DropdownButton<String>(
            onChanged: (String? value) {
              // This is called when the user selects an item.
            },
            items:
                ['1','2','3'].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),

          TextFormField(
            controller: myController['date'],
            //editing controller of this TextField
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), //icon of text field
                labelText: "Enter Date" //label text of field
                ),
          ),
          CheckboxListTile(
            //controller : myController['persistent'],
            title: Text('Persistent?'),
            checkColor: Colors.grey,
            activeColor: Colors.blue,
            value: valuefirst,
            onChanged: (bool? value) {
              setState(() {
                valuefirst = value!;
              });
            },
          ),
          TextFormField(
            //editing controller of this TextField
            controller: myController['place'],
            decoration: const InputDecoration(
                icon: Icon(Icons.place_outlined), //icon of text field
                labelText: "Place" //label text of field
                ),
          ),
          TextFormField(
            //editing controller of this TextField
            controller: myController['title'],
            decoration: const InputDecoration(
                icon: Icon(Icons.abc), //icon of text field
                labelText: "Title" //label text of field
                ),
          ),
          TextFormField(
            controller: myController['notes'],
            //editing controller of this TextField
            decoration: const InputDecoration(
                icon: Icon(Icons.note), //icon of text field
                labelText: "Notes" //label text of field
                ),
          ),
          CheckboxListTile(
            title: Text('Expense?'),
            checkColor: Colors.grey,
            activeColor: Colors.blue,
            value: valuesec,
            onChanged: (bool? value) {
              setState(() {
                valuesec = value!;
              });
            },
          ),
          Container(
            padding: const EdgeInsets.only(left: 150.0, top: 40.0),
            child: ElevatedButton(
                child: const Text('Submit'),
                onPressed: () async {
                  final tr = Transact(
                    DateTime.parse(myController['date']!.text),
                    int.parse(myController['amount']!.text),
                    valuefirst,
                    //'CATEG',
                    myController['category']!.text,
                    false,
                    //'note by hand',
                    myController['notes']!.text,
                    //'place by hand',
                    myController['place']!.text,
                    valuesec,
                    myController['title']!.text,
                  );
                  //print(tr.toString());

                  //create new transaction, insert into firestore
                  //print(tr.toString());
                  FirebaseFirestore.instance
                      .collection('transactions')
                      .doc()
                      .set({
                    'date': tr.date,
                    'amount': tr.amount,
                    'title': tr.title,
                    'place': tr.place,
                    'online': tr.online,
                    'expense': tr.expense,
                    'note': tr.note,
                    'category': tr.category,
                    'persistent': tr.persistent,
                    'uid': _authService.getuser()!.uid
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ListAllTrans()),
                  );
                }),
          ),
          Container(
            padding: const EdgeInsets.only(left: 190.0, top: 40.0),
            child: ElevatedButton(
              child: const Text('List all transactions'),
              onPressed: () async {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ListAllTrans()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
