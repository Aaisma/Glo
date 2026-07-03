import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');

  Future<void> addProduct(ProductModel product) async {
    final docRef = _products.doc();

    await docRef.set({
      ...product.toMap(),
      'id': docRef.id,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _products.get();

    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Stream<List<ProductModel>> watchProducts() {
    return _products.snapshots().map(
          (snapshot) => snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
          .toList(),
    );
  }

  Stream<int> watchProductCount() {
    return _products.snapshots().map(
          (snapshot) => snapshot.docs.length,
    );
  }

  Future<void> updateProduct(ProductModel product) async {
    await _products.doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _products.doc(id).delete();
  }
}