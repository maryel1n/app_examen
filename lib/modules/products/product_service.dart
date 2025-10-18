import 'package:app_examen/shared/services/api_client.dart';
import 'product.dart';

/// Servicio para consumir los endpoints de Productos del examen.
class ProductService {
  // Rutas según lo entregado por el profesor
  static const String _listPath = 'ejemplos/product_list_rest/';
  static const String _addPath = 'ejemplos/product_add_rest/';
  static const String _editPath = 'ejemplos/product_edit_rest/';
  static const String _delPath = 'ejemplos/product_del_rest/';

  /// Obtiene el listado de productos.
  static Future<List<Product>> list() async {
    final data = await ApiClient.getJson(_listPath);
    return Product.fromList(data);
  }

  /// Crea un producto.
  static Future<bool> add({
    required String name,
    required double price,
    required String image,
  }) async {
    final body = {
      'product_name': name,
      'product_price': price,
      'product_image': image,
    };
    await ApiClient.postJson(_addPath, body);
    return true;
  }

  /// Edita un producto.
  static Future<bool> edit({
    required int id,
    required String name,
    required double price,
    required String image,
    String state = 'Activo',
  }) async {
    final body = {
      'product_id': id,
      'product_name': name,
      'product_price': price,
      'product_image': image,
      'product_state': state,
    };
    await ApiClient.postJson(_editPath, body);
    return true;
  }

  /// Elimina un producto por ID.
  static Future<bool> delete(int id) async {
    final body = {'product_id': id};
    await ApiClient.postJson(_delPath, body);
    return true;
  }
}
