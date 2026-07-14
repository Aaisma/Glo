import '../model/product_model.dart';
import '../services/product_service.dart';
import 'product_repo.dart';

class ProductRepoImpl implements ProductRepo {
  final ProductService _service = ProductService();

  @override
  Future<void> addProduct(ProductModel product) {
    return _service.addProduct(product);
  }

  @override
  Future<List<ProductModel>> getProducts() {
    return _service.getProducts();
  }

  @override
  Future<void> updateProduct(ProductModel product) {
    return _service.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(String id) {
    return _service.deleteProduct(id);
  }
}
