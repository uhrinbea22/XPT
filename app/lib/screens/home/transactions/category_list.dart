import 'package:app/consts/styles.dart';
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
    final appTitle = 'Kategóriára szűrés';
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
  bool onlyThisMonth = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: Column(
        children: [
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: onlyThisMonth ? Colors.grey : Colors.pink),
                onPressed: () => setState(() {
                  onlyThisMonth = false;
                }),
                child: Text('Minden tranzakció'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: onlyThisMonth ? Colors.pink : Colors.grey),
                onPressed: () => setState(() {
                  onlyThisMonth = true;
                }),
                child: Text('Ehavi tranzakciók'),
              ),
            ]),
          ),
          SingleChildScrollView(
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("transactions")
                    .where("uid", isEqualTo: _authService.getuser()!.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  // if not has data - loading
                  if (!snapshot.hasData) {
                    return const Text("Hiba történt");
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
                        Text(selectedCategory),
                        DropdownButton<dynamic>(
                          items: categoryList.map((category) {
                            return DropdownMenuItem(
                              child: new Text(category),
                              value: category,
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
              stream: onlyThisMonth
                  ? FirebaseFirestore.instance
                      .collection('transactions')
                      .where('uid', isEqualTo: _authService.getuser()!.uid)
                      .where('category', isEqualTo: selectedCategory)
                      .where('date', isGreaterThanOrEqualTo: actualMonthStart)
                      .where('date', isLessThan: nextMonthStart)
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('transactions')
                      .where('uid', isEqualTo: _authService.getuser()!.uid)
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print((snapshot.error));
                  return Text('Hiba történt');
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
      child: Column(
        children: [
          ListTile(
            selectedColor: Colors.lightBlueAccent,
            visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            tileColor: Colors.white30,
            leading: Icon(
              Icons.double_arrow_rounded,
              color: Colors.black,
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(document['title'],
                      style: const TextStyle(color: Colors.black)),
                ),
                Expanded(
                    child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.transparent,
                      child: document['expense'] == true
                          ? Icon(
                              Icons.remove_outlined,
                              color: Colors.black,
                            )
                          : Icon(
                              Icons.add_outlined,
                              color: Colors.black,
                            ),
                    ),
                    Text('${document['amount']}$valuta',
                        style:
                            const TextStyle(color: Colors.black, fontSize: 18))
                  ],
                ))
              ],
            ),
            subtitle: Text(
              document['date'],
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      TransactionDetailview(document['title']),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}
