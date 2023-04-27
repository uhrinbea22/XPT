import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailView extends StatelessWidget {
  DetailView(this.title, {Key? key}) : super(key: key);
  String title;
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      debugShowCheckedModeBanner: false,
      home: TransactionDetailview(title),
    );
  }
}

class TransactionDetailview extends StatelessWidget {
  //title, date, persistent, category, onlie, note, place, expense, ?picture?

  String title;
  TransactionDetailview(this.title, {Key? key}) : super(key: key);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    Storage storage = Storage();

    _launchURL() async {
      Uri _url = Uri.parse(document['place']);
      if (await launchUrl(_url)) {
        //sikeres volt
      } else {
        throw 'Could not launch $_url';
      }
    }

    return Scaffold(
      drawer: NavDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Offstage(
                      offstage: document['picture'] != "" ? false : true,
                      child: FutureBuilder(
                          future: storage.downloadUrl(
                              _authService.getuser()!.uid, document["picture"]),
                          builder: (BuildContext context,
                              AsyncSnapshot<String?> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData) {
                              return LoadingAnimationWidget.staggeredDotsWave(
                                color: Colors.green,
                                size: 50,
                              );
                            }
                            if (snapshot.hasError) return Text('Hiba történt');
                            return Container(
                              width: 150,
                              height: 175,
                              child: Image.network(snapshot.data!),
                            );
                          }),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          BackButton(),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.subtitles_outlined,
                              )),
                          Text(
                            document['title'],
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.attach_money_outlined,
                              )),
                          Text(
                            document['amount'].toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.view_cozy_outlined,
                              )),
                          Expanded(
                            child: Text(document['category'],
                                style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.storefront_outlined,
                              )),
                          Expanded(
                            child: document['online'] == true
                                ? Wrap(
                                    children: <Widget>[
                                      InkWell(
                                        onTap: _launchURL,
                                        child: Text(
                                          document['place'],
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    document['place'],
                                    style: TextStyle(fontSize: 20),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: document['persistent'] == true ? false : true,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text(
                                  document['expense'] ? 'Számla ' : 'Fizetés',
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.date_range_outlined,
                              )),
                          Text(
                            (document['date']).toString(),
                            style: TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: document['online'] == true ? false : true,
                      child: Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.wifi_outlined,
                                )),
                            Expanded(
                              child: Text("Online",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.note_outlined,
                              )),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                            child: Text(document['note'],
                                style: TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: FloatingActionButton(
                          hoverColor: Colors.purple,
                          child: Icon(Icons.delete_forever),
                          onPressed: () {
                            //warn user
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('Biztos vagy benne?'),
                                    actions: <Widget>[
                                      ElevatedButton(
                                        child: const Text(
                                            "Igen, törlöm ezt a tranzakciót!"),
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .runTransaction(
                                                  (transaction) async =>
                                                      await transaction.delete(
                                                          document.reference));
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListAllTrans()));
                                        },
                                      )
                                    ],
                                  );
                                });
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Timestamp todayTimestamp = Timestamp.fromDate(DateTime.now());

    final AuthService _authService = AuthService();
    User? user = _authService.getuser();
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        title: Text('Tranzakció részletei'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .where("title", isEqualTo: title)
            .where("uid", isEqualTo: user!.uid)
            //.orderBy("date")
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Text('Hiba történt');
          if (snapshot.connectionState == ConnectionState.waiting ||
              !snapshot.hasData) {
            return LoadingAnimationWidget.staggeredDotsWave(
              color: Colors.green,
              size: 50,
            );
          }

          return ListView.builder(
            itemExtent: 1000.0,
            itemCount: snapshot.data!.size,
            itemBuilder: ((context, index) =>
                _buildListItem(context, snapshot.data!.docs[index])),
          );
        },
      ),
    );
  }
}
