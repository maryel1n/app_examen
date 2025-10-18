import 'dart:convert';
import 'package:http/http.dart' as http;

/// Cliente básico para consumir la API del examen con autenticación Basic.
class ApiClient {
  // Backend y credenciales entregadas por el profesor
  static const String _host = '143.198.118.203:8100';
  static const String _user = 'test';
  static const String _pass = 'test2023';

  // Construye el header Authorization: Basic <base64(user:pass)>
  static Map<String, String> _headers() {
    final basic = base64Encode(utf8.encode('$_user:$_pass'));
    return <String, String>{
      'authorization': 'Basic $basic',
      'content-type': 'application/json',
      'accept': 'application/json',
    };
  }

  /// GET genérico. `path` debe incluir el segmento, ej: 'ejemplos/product_list_rest/'.
  static Future<dynamic> getJson(String path) async {
    final uri = Uri.http(_host, path);
    final res = await http
        .get(uri, headers: _headers())
        .timeout(const Duration(seconds: 20));

    // LOG: status + cuerpo de respuesta en consola
    // ignore: avoid_print
    print('[GET] $uri -> ${res.statusCode}\n${res.body}');

    return _handle(res);
  }

  /// POST genérico con body JSON.
  static Future<dynamic> postJson(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.http(_host, path);
    final res = await http
        .post(uri, headers: _headers(), body: jsonEncode(body))
        .timeout(const Duration(seconds: 20));

    // LOG: status + body enviado + respuesta en consola
    // ignore: avoid_print
    print(
      '[POST] $uri -> ${res.statusCode}\nBODY: ${jsonEncode(body)}\nRESP: ${res.body}',
    );

    return _handle(res);
  }

  /// Manejo de respuestas (200–299) -> jsonDecode; otros -> throw con detalle.
  static dynamic _handle(http.Response res) {
    final ok = res.statusCode >= 200 && res.statusCode < 300;
    final text = res.body;
    if (!ok) {
      throw ApiException(
        'HTTP ${res.statusCode}',
        details: text.isNotEmpty ? text : null,
      );
    }
    if (text.isEmpty) return null;
    try {
      return jsonDecode(text);
    } catch (_) {
      return text; // si la API devuelve texto plano
    }
  }
}

/// Excepción simple para distinguir errores de API.
class ApiException implements Exception {
  final String message;
  final String? details;
  ApiException(this.message, {this.details});
  @override
  String toString() => details == null ? message : '$message — $details';
}
