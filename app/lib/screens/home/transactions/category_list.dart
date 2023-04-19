import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../firebase_options.dart';
import '../../../services/auth_service.dart';

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
  final String actualMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month}-01';
  final String nextMonthStart =
      '${DateTime.now().year}-0${DateTime.now().month + 1}-01';

  @override
  void initState() {
    super.initState();
  }



  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
      body: SingleChildScrollView(
          child: Column(
        children: [
          SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("transactions")
                    .where("uid", isEqualTo: _authService.getuser()!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  // if not has data - loading
                  if (!snapshot.hasData) {
                    return const Text("No data");
                    //if has data
                  } else {
                    for (int i = 0; i < snapshot.data!.docs.length; i++) {
                      DocumentSnapshot snap = snapshot.data!.docs[i];
                      if (!categoryList.contains(snap['category'].toString())) {
                        categoryList.add(snap['category']);
                      }
                    }
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        DropdownButton<dynamic>(
                          hint: Text("Choose category"),
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
          SingleChildScrollView(
            //flex: 0,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('uid', isEqualTo: _authService.getuser()!.uid)
                  .where('category', isEqualTo: selectedCategory)
                  .where('date', isGreaterThanOrEqualTo: actualMonthStart)
                  .where('date', isLessThan: nextMonthStart)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print((snapshot.error));
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.green,
                    size: 50,
                  );
                }

                return ListView.builder(
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  itemExtent: 80.0,
                  itemCount: snapshot.data!.size,
                  itemBuilder: ((context, index) =>
                      _buildListItem(context, snapshot.data!.docs[index])),
                );
              },
            ),
          )
        ],
        //
      )),
  
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return SingleChildScrollView(
        child: Column(children: [
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
              child: Text(document['title'],
                  style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
        subtitle: Text(document['category'].toString(),
            style: TextStyle(color: Colors.black)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionDetailview(document['title']),
            ),
          );
        },
      )
    ]));
  }
}
