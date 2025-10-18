class ProviderModel {
  final int id;
  final String name;
  final String lastName;
  final String email;
  final String? state;

  ProviderModel({
    required this.id,
    required this.name,
    required this.lastName,
    required this.email,
    this.state,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: _asInt(json['provider_id']),
      name: (json['provider_name'] ?? '').toString(),
      lastName: (json['provider_last_name'] ?? '').toString(),
      email: (json['provider_mail'] ?? '').toString(),
      state: json['provider_state']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'provider_id': id,
    'provider_name': name,
    'provider_last_name': lastName,
    'provider_mail': email,
    if (state != null) 'provider_state': state,
  };

  // Helpers
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is num) return v.toInt();
    return 0;
  }

  /// Soporta distintas envolturas de la API (p.ej. "Listado Proveedores")
  static List<ProviderModel> fromList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => ProviderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      const keys = [
        'Listado Proveedores', // posible clave devuelta por el backend
        'Listado',
        'listado',
        'data',
        'providers',
        'proveedores',
        'items',
        'result',
        'rows',
        'lista',
      ];
      for (final k in keys) {
        final v = data[k];
        if (v is List) {
          return v
              .map((e) => ProviderModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      // Heurística: detecta cualquier lista con campos provider_*
      for (final entry in data.entries) {
        final v = entry.value;
        if (v is List && v.isNotEmpty && v.first is Map) {
          final first = Map<String, dynamic>.from(v.first as Map);
          if (first.keys.any((k) => k.toString().startsWith('provider_'))) {
            return v
                .map(
                  (e) => ProviderModel.fromJson(
                    Map<String, dynamic>.from(e as Map),
                  ),
                )
                .toList();
          }
        }
      }
      // Anidado en data
      final d2 = data['data'];
      if (d2 is Map) {
        for (final k in keys) {
          final v = d2[k];
          if (v is List) {
            return v
                .map(
                  (e) => ProviderModel.fromJson(Map<String, dynamic>.from(e)),
                )
                .toList();
          }
        }
      }
    }
    return <ProviderModel>[];
  }
}
