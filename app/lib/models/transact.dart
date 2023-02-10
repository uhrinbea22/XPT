import 'package:cloud_firestore/cloud_firestore.dart';

class Transact {
  final DateTime? date;
  final int amount;
  final bool? persistent;
  final String? category;
  final bool? online;
  final String? note;
  final String? place;
  final bool expense;
  //final Picture? picture;
  final String? title;

  Transact(
      this.date,
      this.amount,
      this.persistent,
      this.category,
      this.online,
      this.note,
      this.place,
      this.expense,
      //this.picture,
      this.title);

  Map<String, dynamic> toJson() => _transactToJson(this);

  @override
  String toString() =>
      'Transaction title: <$title>, amount:<$amount> , place<$place> , date<$date> , expense<$expense>, persistent<$persistent> , category<$category>, online<$online>';

  Transact _transactFromJson(Map<String, dynamic> json) {
    return Transact(
        //json['id'] as int,
        (json['date'] as Timestamp).toDate(),
        json['amount'] as int,
        json['persistent'] as bool,
        json['category'] as String,
        json['online'] as bool,
        json['note'] as String,
        json['place'] as String,
        json['expense'] as bool,
        //json['picture'] as Picture,
        json['title'] as String);
  }

  Transact.fromMap(Map<String, dynamic> data, String id)
      : title = data['title'],
        amount = data['amount'],
        date = data['date'],
        persistent = data['persistent'],
        category = data['category'],
        online = data['online'],
        note = data['note'],
        place = data['place'],
        expense = data['expense'];

  Map<String, dynamic> _transactToJson(Transact tr) => <String, dynamic>{
        'amount': tr.amount,
        'date': tr.date,
        'expense': tr.expense,
      };
}
