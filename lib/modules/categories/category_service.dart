import 'package:app_examen/shared/services/api_client.dart';
import 'category.dart';

class CategoryService {
  static const _listPath = 'ejemplos/category_list_rest/';
  static const _addPath = 'ejemplos/category_add_rest/';
  static const _editPath = 'ejemplos/category_edit_rest/';
  static const _delPath = 'ejemplos/category_del_rest/';

  static Future<List<Category>> list() async {
    final data = await ApiClient.getJson(_listPath);
    return Category.fromList(data);
  }

  static Future<void> add({required String name}) async {
    await ApiClient.postJson(_addPath, {'category_name': name});
  }

  static Future<void> edit({
    required int id,
    required String name,
    String state = 'Activa',
  }) async {
    await ApiClient.postJson(_editPath, {
      'category_id': id,
      'category_name': name,
      'category_state': state,
    });
  }

  static Future<void> delete(int id) async {
    await ApiClient.postJson(_delPath, {'category_id': id});
  }
}
