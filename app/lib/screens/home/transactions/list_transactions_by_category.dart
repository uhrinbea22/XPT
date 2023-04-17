import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/transactions_detailview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';

getStringValuesSF() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //Return String
  String? stringValue = prefs.getString('theme');
  print(stringValue);
  return stringValue;
}

/* class ListAllTransByCateg extends StatelessWidget {
  //const ListAllTransByCateg(citle);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      home: MyAppHomePage(),
    );
  }
} */

class ListAllTransByCateg extends StatelessWidget {
  String title;
  //TransactionDetailview(this.title, {Key? key}) : super(key: key);
  ListAllTransByCateg({Key? key, required this.title}) : super(key: key);
  //final String selectedCategory = title;

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Column(
      children: [
        /*  Container(
          child: FutureBuilder(
            future: FirebaseFirestore.instance.collection('transactions').get(),
            builder: (_, snapshot) {
              if (snapshot.hasError) return Text('Error = ${snapshot.error}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Text("Loading");
              }

              return ListView(
                  children: snapshot.data.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                return ListTile(
                  title: Text(data['cateory']),
                );
              }).toList());
            },
          ),
        ), */

        // listázás kategóriánként VAGY szűrés kulcsszóra a title-ben vagy note-ban
        ListTile(
          selectedColor: Colors.lightBlueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50.0),
          ),
          tileColor: Colors.white24,
          hoverColor: Colors.blueGrey,
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
          /* leading: document['expense'] == true
              ? Icon(Icons.add)
              : Icon(Icons.remove), */
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
            .where('category', isEqualTo: title)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Something went wrong');
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }

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
    );
  }
}
