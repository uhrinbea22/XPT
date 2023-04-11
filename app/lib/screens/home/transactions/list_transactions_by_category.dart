import 'package:app/screens/home/menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../firebase_options.dart';
import '../../../services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ListAllTransByCateg());
}

class ListAllTransByCateg extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appTitle = 'List transactions by category';
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

class MyCustomForm extends StatefulWidget {
  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

class MyCustomFormState extends State<MyCustomForm> {
  @override
  void initState() {
    super.initState();
  }

  final String title = '';
  String filterData = "Clothes";

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        // listázás kategóriánként
        ListTile(
          leading: CircleAvatar(backgroundColor: Colors.grey),
          title: Row(
            children: [
              Expanded(
                child: Text(document['title'],
                    style: TextStyle(color: Colors.black)
                    ),
              ),
            ],
          ),
          subtitle: Text(document['amount'].toString(),
              style: TextStyle(color: Colors.black)
              ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
        body: Row(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            icon: Icon(Icons.calendar_month),
            hintText: 'Enter filter data',
            labelText: 'Enter filter data',
            iconColor: Colors.grey,
          ),
          initialValue: filterData,
          readOnly: false,
          onChanged: (value) {
            setState(() => filterData = value);
          },
        ),
        Flex(
          direction: Axis.vertical,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
                child: Row(children: [
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('transactions')
                    .where('uid', isEqualTo: user!.uid)
                    .where('category', isEqualTo: filterData)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const Text("Waiting...");
                  if (snapshot.hasError) return Text('Something went wrong');

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Waiting");
                  }
                  print(snapshot.data!.size.toInt().toString());
                  return ListView.builder(
                    itemExtent: 120.0,
                    itemCount: snapshot.data!.size,
                    itemBuilder: ((context, index) =>
                        _buildListItem(context, snapshot.data!.docs[index])),
                  );
                },
              ),
            ]))
          ],
        )
      ],
    ));
  }
}
