import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(String name, int quantity) {
    // CREATE
    return items.add({
      'name': name,
      'quantity': quantity,
      'favorite': false,
      'createdAt': Timestamp.now(),
    });
  }

  // READ
  Stream<QuerySnapshot> getItems() {
    return items.orderBy('createdAt', descending: true).snapshots();
  }

  // UPDATE
  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({
      'name': name,
      'quantity': quantity,
    });
  }

  // DELETE
  Future<void> deleteItem(String id) {
    return items.doc(id).delete();
  }

  // TOGGLE FAVORITE
  Future<void> toggleFavorite(String id, bool currentFavorite) {
    return items.doc(id).update({
      'favorite': !currentFavorite,
    });
  }

  // GET FAVORITES ONLY
  Stream<QuerySnapshot> getFavoriteItems() {
    return items
        .where('favorite', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}