import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lesson72/models/tour.dart';

class FirestoreFirebaseService extends ChangeNotifier {
  final firestore = FirebaseFirestore.instance.collection('tour');

  Stream<QuerySnapshot<Map<String, dynamic>>> getTours() async* {
    yield* firestore.snapshots();
  }

  Future<void> editTour(Tour tour) async {
    await firestore.doc(tour.id).update({
      'title': tour.title,
      'imageUrl': tour.imageUrl,
      'location': tour.location,
    });
  }

  Future<void> addTour(Tour tour) async {
    await firestore.add({
      'title': tour.title,
      'imageUrl': tour.imageUrl,
      'location': tour.location,
    });
  }

  Future<void> deleteTour(String id) async {
    await firestore.doc(id).delete();
  }
}
