import 'package:app/screens/home/menu.dart';
import 'package:app/screens/home/transactions/list_all_transactions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../services/auth_service.dart';
import '../../../services/storage_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

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
  String title;
  TransactionDetailview(this.title, {Key? key}) : super(key: key);
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  final AuthService _authService = AuthService();
  Storage storage = Storage();

  Widget _buildListItem(BuildContext context, DocumentSnapshot document) {
    _launchURL() async {
      Uri _url = Uri.parse('https://${document['place']}');
      if (await launchUrl(_url)) {
        launchUrl(_url);
      } else {
        throw 'Could not launch $_url';
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          BackButton(),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 0, 10, 0),
                                  child: Icon(
                                    Icons.subtitles_outlined,
                                  )),
                              Text(
                                document['title'],
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Offstage(
                                offstage:
                                    document['picture'] != "" ? false : true,
                                child: FutureBuilder(
                                    future: storage.downloadUrl(
                                        _authService.getuser()!.uid,
                                        document["picture"]),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String?> snapshot) {
                                      if (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          !snapshot.hasData) {
                                        return LoadingAnimationWidget
                                            .staggeredDotsWave(
                                          color: Colors.green,
                                          size: 50,
                                        );
                                      }
                                      if (snapshot.hasError)
                                        return Text('Hiba történt');
                                      return GestureDetector(
                                        onTap: () async {
                                          final imageProvider =
                                              Image.network(snapshot.data!)
                                                  .image;
                                          showImageViewer(
                                              context, imageProvider,
                                              onViewerDismissed: () {
                                            print("dismissed");
                                          });
                                        },
                                        child: Container(
                                            height: 75,
                                            child: Image(
                                              image:
                                                  NetworkImage(snapshot.data!),
                                            )),
                                      );
                                    }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.attach_money_outlined,
                              )),
                          Text(
                            document['amount'].toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.view_cozy_outlined,
                              )),
                          Expanded(
                            child: Text(document['category'],
                                style: const TextStyle(fontSize: 20)),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
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
                                          style: const TextStyle(
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
                                    style: const TextStyle(fontSize: 20),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: document['persistent'] == true ? false : true,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 10, 20, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Text(
                                  document['expense'] ? 'Számla ' : 'Fizetés',
                                  style: const TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 20),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                              child: Icon(
                                Icons.date_range_outlined,
                              )),
                          Text(
                            (document['date']).toString(),
                            style: const TextStyle(fontSize: 20),
                          ),
                        ],
                      ),
                    ),
                    Offstage(
                      offstage: document['online'] == true ? false : true,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 10, 20, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.wifi_outlined,
                                )),
                            const Expanded(
                              child: Text("Online",
                                  style: TextStyle(fontSize: 20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            20, 10, 20, 20),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            const Padding(
                                padding:
                                    EdgeInsetsDirectional.fromSTEB(0, 0, 10, 0),
                                child: Icon(
                                  Icons.note_alt_outlined,
                                )),
                            Text(
                              (document['note']).toString(),
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        )),
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(20, 10, 20, 0),
                      child: FloatingActionButton(
                          hoverColor: Colors.purple,
                          child: const Icon(Icons.delete_forever),
                          onPressed: () {
                            //warn user about deleting forever
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
                                                      transaction.delete(
                                                          document.reference));
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      ListAllTransactions()));
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
    User? user = _authService.getuser();
    return Scaffold(
      resizeToAvoidBottomInset: false,
      drawer: NavDrawer(),
      appBar: AppBar(
        title: const Text('Tranzakció részletei'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("transactions")
            .where("title", isEqualTo: title)
            .where("uid", isEqualTo: user!.uid)
            .get()
            .asStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Text('Hiba történt');
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
