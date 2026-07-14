import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/product_model.dart';

class ProductService {
  final _db = FirebaseFirestore.instance;

  Future<void> addProduct(ProductModel product) async {
    final docRef = _db.collection('products').doc();
    await docRef.set({
      ...product.toMap(),
      'id': docRef.id,
    });
  }

  Future<List<ProductModel>> getProducts() async {
    final snapshot = await _db.collection('products').get();
    return snapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<void> updateProduct(ProductModel product) async {
    await _db.collection('products').doc(product.id).update(product.toMap());
  }

  Future<void> deleteProduct(String id) async {
    await _db.collection('products').doc(id).delete();
  }
}
