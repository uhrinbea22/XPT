import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import '../../firebase_options.dart';
import '../../models/transact.dart';
import '../../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CreateTransacton());
}

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
  String dropdownvalue = 'Food';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
  bool expense_value = false;
  bool persistent_value = false;
  bool online_value = false;

  var categoryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Flexible(
          // flex: 1,
          // fit: FlexFit.tight,
          // child:
          TextFormField(
            controller: myController['amount'],
            decoration: const InputDecoration(
              icon: const Icon(Icons.money),
              hintText: 'Enter the amount',
              labelText: 'Amount',
              iconColor: Colors.grey,
            ),
          ),
          // ),
          TextFormField(
            controller: myController['date'],
            //editing controller of this TextField
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), //icon of text field
                labelText: "Enter Date" //label text of field
                ),
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
            title: Text('Expense'),
            checkColor: Colors.grey,
            activeColor: Colors.blue,
            value: expense_value,
            onChanged: (bool? value) {
              setState(() {
                expense_value = value!;
              });
            },
          ),
          CheckboxListTile(
            //controller : myController['persistent'],
            title: Text('Persistent'),
            checkColor: Colors.grey,
            activeColor: Colors.blue,
            value: persistent_value,
            onChanged: (bool? value) {
              setState(() {
                persistent_value = value!;
              });
            },
          ),
          CheckboxListTile(
            //controller : myController['persistent'],
            title: Text('Online'),
            checkColor: Colors.grey,
            activeColor: Colors.blue,
            value: online_value,
            onChanged: (bool? value) {
              setState(() {
                online_value = value!;
              });
            },
          ),
          Row(
            children: [
              Text('Category : '),
              Text(dropdownvalue),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("transactions")
                        .where("category", isNotEqualTo: '')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Text("Loading.....");
                      else {
                        List<DropdownMenuItem> currencyItems = [];
                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          DocumentSnapshot snap = snapshot.data!.docs[i];
                          currencyItems.add(
                            DropdownMenuItem(
                              child: Text(
                                snap['category'],
                                style: TextStyle(color: Color(0xff11b719)),
                              ),
                              //it was text
                              value: (snap['category']).toString(),
                            ),
                          );
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 50.0),
                            DropdownButton<dynamic>(
                              items: currencyItems,
                              onChanged: (choosed_category) {
                                setState(() {
                                  dropdownvalue = choosed_category.toString();
                                });
                                dropdownvalue = choosed_category.toString();
                                categoryController.text =
                                    choosed_category.toString();
                                print(dropdownvalue);
                              },
                              //value: currencyItems.first,
                              isExpanded: false,
                              //hint: Text(dropdownvalue),
                            ),
                          ],
                        );
                      }
                    }),
              ),
              Container(
                padding: const EdgeInsets.only(left: 20.0, top: 0.0),
                child: FloatingActionButton(
                    mini: true,
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.blueGrey,
                    hoverColor: Colors.purple,
                    child: Icon(Icons.add),
                    onPressed: () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('New category'),
                              content: TextField(
                                controller: categoryController,
                                decoration: const InputDecoration(
                                    hintText: 'Type new category'),
                              ),
                              actions: <Widget>[
                                ElevatedButton(
                                  child: const Text('Submit'),
                                  onPressed: () {
                                    setState(() {
                                      dropdownvalue = categoryController.text;
                                    });
                                    print(categoryController.text);
                                    dropdownvalue = categoryController.text;
                                    Navigator.of(context).pop();
                                  },
                                )
                              ],
                            );
                          });
                    }),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.only(left: 150.0, top: 20.0),
                child: ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () async {
                      print(categoryController.text);
                      print(dropdownvalue);
                      //create a transaction
                      final tr = Transact(
                        DateTime.parse(myController['date']!.text),
                        int.parse(myController['amount']!.text),
                        persistent_value,
                        dropdownvalue,
                        online_value,
                        myController['notes']!.text,
                        myController['place']!.text,
                        expense_value,
                        myController['title']!.text,
                      );
                      //store it in database
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
                      //put it in the calendar
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ListAllTrans()),
                      );
                    }),
              ),
              Container(
                padding: const EdgeInsets.only(left: 250.0, top: 20.0),
                child: ElevatedButton(
                  child: const Text('Back'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                  },
                ),
              )
            ],
          ),
//create category dropdownlist from db
        ],
      ),
    );
  }
}
