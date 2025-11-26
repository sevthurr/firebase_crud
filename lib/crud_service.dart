import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:image_picker/image_picker.dart';

class PickedImage {
  final File file;
  final String url;
  PickedImage({required this.file, required this.url});
}

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

      final CloudinaryPublic _cloudinary = CloudinaryPublic(
        'dg1cz2twr', 'flutter_notes_preset',
        cache: false,
      );

      final ImagePicker _picker = ImagePicker();

      Future<PickedImage?> pickImageForAddItem() async {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile == null) return null;

        final file = File(pickedFile.path);

        final response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
        );
        return PickedImage(file: file, url: response.secureUrl);
      }

  Future<void> addItemWithImage(String name, int quantity, String? imageUrl) async {
    await items.add (
    {// CREATE
      'name': name,
      'quantity': quantity,
      'image_url': imageUrl,
      'favorite': false,
      'createdAt': Timestamp.now(),
        }
    );
  }

  // Convenience: add without image (calls addItemWithImage with null)
  Future<void> addItem(String name, int quantity) async {
    await addItemWithImage(name, quantity, null);
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