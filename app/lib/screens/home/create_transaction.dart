// ignore: unused_import
import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../models/transact.dart';

void main() => runApp(CreateTransacton());

class CreateTransacton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'Flutter Form Demo';
    return MaterialApp(
      title: appTitle,
      home: Scaffold(
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

// Create a Form widget.
class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class. This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
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

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    //final db = FirebaseFirestore.instance;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: myController['amount'],
            decoration: const InputDecoration(
              icon: const Icon(Icons.money),
              hintText: 'Enter the amount',
              labelText: 'Amount',
            ),
          ),
          TextFormField(
            controller: myController['category'],
            decoration: const InputDecoration(
              icon: const Icon(Icons.add_box),
              hintText: 'Enter category',
              labelText: 'Category',
            ),
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
            //controller : myController,
            title: Text('Persistent?'),
            checkColor: Colors.greenAccent,
            activeColor: Colors.red,
            value: valuefirst,
            onChanged: (bool? value) {
              valuefirst = value!;
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
            checkColor: Colors.greenAccent,
            activeColor: Colors.red,
            value: valuefirst,
            onChanged: (bool? value) {
              valuefirst = value!;
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
                      true,
                      myController['category']!.text,
                      false,
                      '',
                      '',
                      true,
                      '');
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
                    'persistent': tr.persistent
                  });
                }),
          ),
        ],
      ),
    );
  }
}
