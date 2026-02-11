import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/wishlist_item.dart';

class WardrobeRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  WardrobeRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _storage = storage ?? FirebaseStorage.instance;

  String? get _userId => _auth.currentUser?.uid;

  // --- Clothing Items ---

  CollectionReference<Map<String, dynamic>> _wardrobeCol() {
    return _firestore.collection('users').doc(_userId).collection('wardrobe');
  }

  Future<String> uploadImage(String itemId, Uint8List bytes) async {
    if (_userId == null) throw Exception('Not authenticated');
    final ref = _storage.ref('users/$_userId/wardrobe/$itemId.jpg');
    final task = await ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await task.ref.getDownloadURL();
  }

  Future<void> createClothingItem(ClothingItem item) async {
    if (_userId == null) return;
    await _wardrobeCol().doc(item.id).set(item.toMap());
  }

  Stream<List<ClothingItem>> getClothingItems() {
    if (_userId == null) return Stream.value([]);
    return _wardrobeCol()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => ClothingItem.fromMap(d.data())).toList());
  }

  Future<void> updateClothingItem(ClothingItem item) async {
    if (_userId == null) return;
    await _wardrobeCol().doc(item.id).update(item.toMap());
  }

  Future<void> deleteClothingItem(String itemId) async {
    if (_userId == null) return;
    await _wardrobeCol().doc(itemId).delete();
    try {
      await _storage.ref('users/$_userId/wardrobe/$itemId.jpg').delete();
    } catch (_) {}
  }

  // --- Outfits ---

  CollectionReference<Map<String, dynamic>> _outfitsCol() {
    return _firestore.collection('users').doc(_userId).collection('outfits');
  }

  Future<void> createOutfit(Outfit outfit) async {
    if (_userId == null) return;
    await _outfitsCol().doc(outfit.id).set(outfit.toMap());
  }

  Stream<List<Outfit>> getOutfits() {
    if (_userId == null) return Stream.value([]);
    return _outfitsCol()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => Outfit.fromMap(d.data())).toList());
  }

  Future<void> updateOutfit(Outfit outfit) async {
    if (_userId == null) return;
    await _outfitsCol().doc(outfit.id).update(outfit.toMap());
  }

  Future<void> deleteOutfit(String outfitId) async {
    if (_userId == null) return;
    await _outfitsCol().doc(outfitId).delete();
  }

  // --- Wishlist ---

  CollectionReference<Map<String, dynamic>> _wishlistCol() {
    return _firestore.collection('users').doc(_userId).collection('wishlist');
  }

  Future<void> createWishlistItem(WishlistItem item) async {
    if (_userId == null) return;
    await _wishlistCol().doc(item.id).set(item.toMap());
  }

  Stream<List<WishlistItem>> getWishlistItems() {
    if (_userId == null) return Stream.value([]);
    return _wishlistCol()
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => WishlistItem.fromMap(d.data())).toList());
  }

  Future<void> updateWishlistItem(WishlistItem item) async {
    if (_userId == null) return;
    await _wishlistCol().doc(item.id).update(item.toMap());
  }

  Future<void> deleteWishlistItem(String itemId) async {
    if (_userId == null) return;
    await _wishlistCol().doc(itemId).delete();
  }
}
