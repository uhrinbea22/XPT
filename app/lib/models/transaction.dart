import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  //final int id;
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

  Transaction(
      //this.id,  -> since the firestore stores documentid-s
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

  factory Transaction.fromJson(Map<String, dynamic> json) =>
      _transactionFromJson(json);
  Map<String, dynamic> toJson() => _transactionToJson(this);

  @override
  String toString() =>
      'Transaction title: <$title>, amount:<$amount> , place<$place> , date<$date> , expense<$expense>, persistent<$persistent> , category<$category>, online<$online>';
}

// 1
Transaction _transactionFromJson(Map<String, dynamic> json) {
  return Transaction(
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

// 2
Map<String, dynamic> _transactionToJson(Transaction tr) => <String, dynamic>{
      'amount': tr.amount,
      'date': tr.date,
      'expense': tr.expense,
    };

