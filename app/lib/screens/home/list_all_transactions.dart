import 'package:app/screens/home/create_transaction.dart';
import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions_detailview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';

void main() {
  runApp(const ListAllTrans());
}

class ListAllTrans extends StatelessWidget {
  const ListAllTrans();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'expense db test',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: const MyAppHomePage(title: 'All expenses'),
    );
  }
}

class MyAppHomePage extends StatelessWidget {
  const MyAppHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Column(
      children: [
        //
       /*  Container(
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
                          categoryController.text = choosedCategory.toString();
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
        ), */
        // listázás kategóriánként VAGY szűrés kulcsszóra a title-ben vagy note-ban
        ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey),
          title: Row(
            children: [
              Expanded(
                child: Text(document['title'],
                    style: TextStyle(color: Colors.black)
                    //Theme.of(context).textTheme.displayMedium,
                    ),
              ),
            ],
          ),
          subtitle: Text(document['amount'].toString(),
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
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text(title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('transactions')
            .where('uid', isEqualTo: user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Text("Waiting...");
          if (snapshot.hasError) return Text('Something went wrong');
          // if (snapshot.hasData) return Text('has data');

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Text("Waiting");
          }
          return ListView.builder(
            itemExtent: 80.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                _buildListItem(context, snapshot.data!.docs[index])),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
          hoverColor: Colors.purple,
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateTransacton(),
                ));
          }),
    );
  }
}
