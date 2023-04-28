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
  runApp(TransactionsByCategoryPage());
}

class TransactionsByCategoryPage extends StatelessWidget {
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
        body: TransactionsByCategories(),
      ),
    );
  }
}

class TransactionsByCategories extends StatefulWidget {
  var _streamCategoriesList;
  @override
  TransactionsByCategoriesState createState() {
    return TransactionsByCategoriesState();
  }
}

class TransactionsByCategoriesState extends State<TransactionsByCategories> {
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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: Column(
        children: [
          ///set date range for transactions which we want to list
          Container(
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: onlyThisMonth ? Colors.grey : Colors.pink),
                onPressed: () => setState(() {
                  onlyThisMonth = false;
                }),
                child: const Text('Minden tranzakció'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    primary: onlyThisMonth ? Colors.pink : Colors.grey),
                onPressed: () => setState(() {
                  onlyThisMonth = true;
                }),
                child: const Text('Ehavi tranzakciók'),
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
                  if (!snapshot.hasData) {
                    return const Text("Hiba történt");
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
                          hint: Text(selectedCategory),
                          items: categoryList.map((category) {
                            return DropdownMenuItem(
                              value: category,
                              child: Text(category),
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
                  return const Text('Hiba történt');
                }
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData) {
                  return LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.green,
                    size: 50,
                  );
                }

                return ListView.builder(
                  physics: const ScrollPhysics(),
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
            leading: const Icon(
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
                          ? const Icon(
                              Icons.remove_outlined,
                              color: Colors.black,
                            )
                          : const Icon(
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
