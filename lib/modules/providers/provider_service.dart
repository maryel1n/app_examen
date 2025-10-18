import 'package:app_examen/shared/services/api_client.dart';
import 'provider.dart';

class ProviderService {
  static const _listPath = 'ejemplos/provider_list_rest/';
  static const _addPath = 'ejemplos/provider_add_rest/';
  static const _editPath = 'ejemplos/provider_edit_rest/';
  static const _delPath = 'ejemplos/provider_del_rest/';

  static Future<List<ProviderModel>> list() async {
    final data = await ApiClient.getJson(_listPath);
    return ProviderModel.fromList(data);
  }

  static Future<void> add({
    required String name,
    required String lastName,
    required String email,
    String state = 'Activo',
  }) async {
    await ApiClient.postJson(_addPath, {
      'provider_name': name,
      'provider_last_name': lastName,
      'provider_mail': email,
      'provider_state': state,
    });
  }

  static Future<void> edit({
    required int id,
    required String name,
    required String lastName,
    required String email,
    String state = 'Activo',
  }) async {
    await ApiClient.postJson(_editPath, {
      'provider_id': id,
      'provider_name': name,
      'provider_last_name': lastName,
      'provider_mail': email,
      'provider_state': state,
    });
  }

  static Future<void> delete(int id) async {
    await ApiClient.postJson(_delPath, {'provider_id': id});
  }
}
