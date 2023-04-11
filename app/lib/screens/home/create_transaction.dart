import 'package:app/screens/home/list_all_transactions.dart';
import 'package:app/screens/home/menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
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
  bool expense_value = false;
  bool persistent_value = false;
  bool online_value = false;
  var showText = "";

  var categoryController = TextEditingController();

  List Lista = [];

  @override
  void initState() {
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();

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
              icon: Icon(Icons.money),
              hintText: 'Enter the amount',
              labelText: 'Amount',
              iconColor: Colors.grey,
            ),
          ),
          //datepicker to make it easier for user to choose date

          TextFormField(
              controller: myController['date'],
              decoration: const InputDecoration(
                icon: Icon(Icons.calendar_month),
                hintText: 'Enter date',
                labelText: 'Date',
                iconColor: Colors.grey,
              ),
              readOnly: true,
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101));
                if (pickedDate != null) {
                  print(pickedDate);
                  String formattedDate =
                      DateFormat('yyyy-MM-dd').format(pickedDate);
                  setState(() {
                    myController['date']!.text = formattedDate;
                  });
                } else {
                  showDialog(
                      context: context,
                      builder: (context) {
                        Future.delayed(const Duration(seconds: 5), () {
                          Navigator.of(context).pop(true);
                        });
                        return const AlertDialog(
                          title: Text('Date is not selected!'),
                        );
                      });
                }
              }),
          //
/* 
          TextFormField(
            controller: myController['date'],
            //editing controller of this TextField
            decoration: const InputDecoration(
                icon: Icon(Icons.calendar_today), //icon of text field
                labelText: "Enter Date" //label text of field
                ),
          ), */

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
              Text(
                'Category : ',
                style: TextStyle(
                    color: showText == "" ? Colors.black : Colors.red),
              ),
              Text(dropdownvalue),
              Column(
                children: [
                  Text(
                    showText,
                    style: TextStyle(color: Colors.red),
                  )
                ],
              ),
              //show the error text here somewhere
              //Text(showText),
              Container(
                child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("transactions")
                        .where("category", isNotEqualTo: '')
                        //.where("category", i)
                        //.where("uid", isEqualTo: _authService.getuser()!.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return const Text("Loading.....");
                      else {
                        //TODO : refactor this

                        List<DropdownMenuItem> currencyItems = [];

                        for (int i = 0; i < snapshot.data!.docs.length; i++) {
                          DocumentSnapshot snap = snapshot.data!.docs[i];
                          Lista.add(snap['category']);
                          if (snapshot.data!.docs.contains(snap['category'])) {
                            print(snap['category']);
                          }
                          if (currencyItems.contains(DropdownMenuItem(
                            value: (snap['category']).toString(),
                            child: Text(snap['category']),
                          ))) {
                            print("egyezese");
                          } else {
                            currencyItems.add(
                              DropdownMenuItem(
                                value: (snap['category']).toString(),
                                child: Text(
                                  snap['category'],
                                  style: TextStyle(color: Color(0xff11b719)),
                                ),
                              ),
                            );
                          }
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(width: 50.0),
                            DropdownButton<dynamic>(
                              items: currencyItems,
                              onChanged: (choosedCategory) {
                                setState(() {
                                  dropdownvalue = choosedCategory.toString();
                                });
                                dropdownvalue = choosedCategory.toString();
                                categoryController.text =
                                    choosedCategory.toString();
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
                                  onPressed: () {
                                    setState(() {
                                      dropdownvalue = categoryController.text;
                                    });
                                    print(categoryController.text);
                                    dropdownvalue = categoryController.text;

                                    if (Lista.contains(dropdownvalue)) {
                                      setState(() {
                                        showText =
                                            "This category is already exists! Create a new one or choose from the list!";
                                      });

                                      //TODO : warn user that this category exists and that they cant create it like this
                                      print("VAN MAR IYLEN");
                                    } else
                                      showText = "Submit";

                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Submit"),
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
                      //create a transaction
                      print(dropdownvalue);
                      print(expense_value);
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

                      //check if with that amount the category limit is overlapped
                      final citiesRef = await FirebaseFirestore.instance
                          .collection("category_limits")
                          .where("uid", isEqualTo: _authService.getuser()!.uid)
                          .where("category".toLowerCase(),
                              isEqualTo: tr.category!.toLowerCase())
                          //.where("expense", isEqualTo: true)
                          .get();
                      if (citiesRef.docs.isNotEmpty) {
                        if (citiesRef.docs.first['limit'] + tr.amount >
                            citiesRef.docs.first['limit']) {
                          //TODO hibauzenet pop up window
                          print("TULLÉPED A HATART");
                        }
                      } else if (tr.expense == true) {
                        print(tr.category);
                        FirebaseFirestore.instance
                            .collection('category_limits')
                            .doc()
                            .set({
                          'category': tr.category.toString(),
                          'limit': 0,
                          'uid': _authService.getuser()!.uid
                        });
                      }
                      //find the category with user uid, and check if it has limit

                      //if not, normally add the transaction
                      //if it has, check the amounts, and war the user about possible over expense

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
        ],
      ),
    );
  }
}
