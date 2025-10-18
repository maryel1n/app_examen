class Category {
  final int id;
  final String name;
  final String? state;

  Category({required this.id, required this.name, this.state});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _asInt(json['category_id']),
      name: (json['category_name'] ?? '').toString(),
      state: json['category_state']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'category_id': id,
    'category_name': name,
    if (state != null) 'category_state': state,
  };

  // Helpers
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is num) return v.toInt();
    return 0;
  }

  /// Soporta distintas envolturas de la API (incluye "Listado")
  static List<Category> fromList(dynamic data) {
    if (data is List) {
      return data
          .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
    if (data is Map) {
      const keys = [
        'Listado Categorias', // <- clave con espacio que devuelve la API
        'Listado',
        'listado',
        'data',
        'categories',
        'categorias',
        'items',
        'result',
        'rows',
        'lista',
      ];
      for (final k in keys) {
        final v = data[k];
        if (v is List) {
          return v
              .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      final d2 = data['data'];
      if (d2 is Map) {
        for (final k in keys) {
          final v = d2[k];
          if (v is List) {
            return v
                .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
      }
    }
    return <Category>[];
  }
}
