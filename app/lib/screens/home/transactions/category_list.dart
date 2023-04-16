import 'dart:io';
import 'package:app/screens/home/theme_manager.dart';
import 'package:app/screens/home/transactions/fileupload.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import '../../../firebase_options.dart';
import '../../../models/transact.dart';
import '../../../services/auth_service.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(CategLiast());
}

class CategLiast extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'List by categories';
    // return MyCustomForm();
    return MaterialApp(
      title: appTitle,
      theme: Theme.of(context),
      home: Scaffold(
        drawer: NavDrawer(),
        appBar: AppBar(
          title: Text(appTitle),
        ),
        body: MyCustomForm(),
      ),
    );
  }
}

class MyCustomForm extends StatefulWidget {
  var _streamCategoriesList;
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();
  List categoryList = [];
  var categoryController = TextEditingController();
  String selectedCategory = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
//      appBar: AppBar(),
        //    drawer: NavDrawer(),
        body: Column(
      children: [
        Flexible(
          child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("transactions")
                  .where("category", isNotEqualTo: '')
                  //  .where("uid", isEqualTo: _authService.getuser()!.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                // if not has data - loading
                if (!snapshot.hasData) {
                  return const Text("Loading.....");
                  //if has data
                } else {
                  for (int i = 0; i < snapshot.data!.docs.length; i++) {
                    DocumentSnapshot snap = snapshot.data!.docs[i];
                    if (!categoryList.contains(snap['category'].toString())) {
                      categoryList.add(snap['category']);
                    }
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      DropdownButton<dynamic>(
                        items: categoryList.map((location) {
                          return DropdownMenuItem(
                            child: new Text(location),
                            value: location,
                          );
                        }).toList(),
                        onChanged: (choosedCategory) {
                          setState(() {
                            selectedCategory = choosedCategory;
                          });
                        },
                        isExpanded: false,
                      ),
                    ],
                  );
                }
              }),
        ),
        Flexible(
          flex: 1,
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('transactions')
                .where("uid", isEqualTo: _authService.getuser()!.uid)
                .where("category", isEqualTo: selectedCategory)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text("Waiting...");
              if (snapshot.hasError) return Text('Something went wrong');
              // if (snapshot.hasData) return Text('has data');

              return ListView.builder(
                itemExtent: 80.0,
                itemCount: snapshot.data!.size,
                itemBuilder: ((context, index) =>
                    _buildListItem(context, snapshot.data!.docs[index])),
              );
            },
          ),
        )
      ],
    ));
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    // return
/*     SingleChildScrollView(
      child: Column(
        children: [ */
    return Column(children: [
      ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.lightBlue,
          child: document['expense'] == true
              ? Icon(
                  Icons.remove,
                  color: Colors.black,
                )
              : Icon(
                  Icons.add,
                  color: Colors.black,
                ),
        ),
        title: Row(
          children: [
            Expanded(
              child:
                  Text(document['title'], style: TextStyle(color: Colors.black)
                      //Theme.of(context).textTheme.displayMedium,
                      ),
            ),
          ],
        ),
        subtitle: Text(document['category'].toString(),
            style: TextStyle(color: Colors.black)
            //Theme.of(context).textTheme.displaySmall,
            ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailview(document['title']),
            ),
          );
        },
        /*  )
        ],
      ), */
      )
    ]);
  }
}
