// lib/modules/providers/provider_service.dart
import 'package:app_examen/shared/services/api_client.dart';
import 'provider.dart';

/// Servicio para CRUD de Proveedores contra la API del examen.
class ProviderService {
  static const _listPath = 'ejemplos/provider_list_rest/';
  static const _addPath = 'ejemplos/provider_add_rest/';
  static const _editPath = 'ejemplos/provider_edit_rest/';
  static const _delPath = 'ejemplos/provider_del_rest/';

  /// Lista de proveedores (robusto a claves distintas y a respuestas tipo List o Map).
  static Future<List<Provider>> list() async {
    final json = await ApiClient.getJson(_listPath);

    // Logs para ver lo que devuelve la API
    // ignore: avoid_print
    print('[PROVIDERS][RAW] ${json.runtimeType} -> $json');

    List<dynamic> list = const [];

    if (json is List) {
      // Algunas APIs devuelven directamente el arreglo
      list = json;
    } else if (json is Map) {
      // 1) Intentar con claves típicas
      final candidates = [
        'Listado Proveedores',
        'Listado proveedores',
        'Listado_proveedores',
        'Listado',
        'listado',
        'providers',
        'data',
        'resultado',
      ];
      for (final k in candidates) {
        final v = json[k];
        if (v is List) {
          list = v;
          // ignore: avoid_print
          print('[PROVIDERS] usando clave "$k" (${list.length} items)');
          break;
        }
        if (v is Map) {
          // A veces viene como objeto con ids como keys → usamos sus values
          list = (v.values).toList();
          // ignore: avoid_print
          print(
            '[PROVIDERS] usando clave "$k" (Map->values: ${list.length} items)',
          );
          break;
        }
      }

      // 2) Fallback: primera value que sea List
      if (list.isEmpty) {
        for (final entry in json.entries) {
          if (entry.value is List) {
            list = entry.value as List;
            // ignore: avoid_print
            print(
              '[PROVIDERS] fallback List con clave "${entry.key}" (${list.length} items)',
            );
            break;
          }
        }
      }

      // 3) Fallback: primera value que sea Map (tomamos sus values como lista)
      if (list.isEmpty) {
        for (final entry in json.entries) {
          if (entry.value is Map) {
            final m = entry.value as Map;
            list = m.values.toList();
            // ignore: avoid_print
            print(
              '[PROVIDERS] fallback Map->values con clave "${entry.key}" (${list.length} items)',
            );
            break;
          }
        }
      }
    }

    // Mapear elementos de forma tolerante
    final items = list.map((e) {
      final m = (e is Map) ? e.cast<String, dynamic>() : <String, dynamic>{};
      return Provider.fromMap(m);
    }).toList();

    // ignore: avoid_print
    print('[PROVIDERS] items mapeados: ${items.length}');
    return items;
  }

  /// Agregar proveedor.
  static Future<void> add({
    required String name,
    required String lastName,
    required String mail,
    String state = 'Activo',
  }) async {
    await ApiClient.postJson(_addPath, {
      'provider_name': name,
      'provider_last_name': lastName,
      'provider_mail': mail,
      'provider_state': state,
    });
  }

  /// Editar proveedor.
  static Future<void> edit({
    required int id,
    required String name,
    required String lastName,
    required String mail,
    String state = 'Activo',
  }) async {
    await ApiClient.postJson(_editPath, {
      'provider_id': id,
      'provider_name': name,
      'provider_last_name': lastName,
      'provider_mail': mail,
      'provider_state': state,
    });
  }

  /// Eliminar proveedor (la API exige SOLO 'provider_id').
  static Future<void> delete(int id) async {
    await ApiClient.postJson(_delPath, {'provider_id': id});
  }
}
