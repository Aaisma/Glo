import '../model/product_model.dart';

abstract class ProductRepo {
  Future<void> addProduct(ProductModel product);
  Future<List<ProductModel>> getProducts();
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}
