class Product {
  final int id;
  final String name;
  final double price;
  final String image;
  final String? state;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    this.state,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // La API usa claves como product_id, product_name, etc.
    return Product(
      id: _asInt(json['product_id']),
      name: (json['product_name'] ?? '').toString(),
      price: _asDouble(json['product_price']),
      image: (json['product_image'] ?? '').toString(),
      state: json['product_state']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': id,
    'product_name': name,
    'product_price': price,
    'product_image': image,
    if (state != null) 'product_state': state,
  };

  // Helpers robustos para castear
  static int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    if (v is num) return v.toInt();
    return 0;
  }

  static double _asDouble(dynamic v) {
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    if (v is num) return v.toDouble();
    return 0.0;
  }

  static List<Product> fromList(dynamic data) {
    // Caso 1: la API ya devuelve un arreglo directo
    if (data is List) {
      return data
          .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    // Caso 2: viene envuelto en un Map con alguna clave conocida
    if (data is Map) {
      // Claves candidatas (incluye "Listado" del backend)
      const candidateKeys = [
        'Listado', // <- clave observada en los logs
        'listado',
        'data',
        'products',
        'productos',
        'items',
        'result',
        'rows',
        'lista',
      ];

      for (final key in candidateKeys) {
        final v = data[key];
        if (v is List) {
          return v
              .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }

      // Heurística: busca cualquier lista de mapas que parezca de productos
      for (final entry in data.entries) {
        final v = entry.value;
        if (v is List && v.isNotEmpty && v.first is Map) {
          final first = Map<String, dynamic>.from(v.first as Map);
          if (first.containsKey('product_id') ||
              first.containsKey('product_name')) {
            return v
                .map(
                  (e) => Product.fromJson(Map<String, dynamic>.from(e as Map)),
                )
                .toList();
          }
        }
      }

      // A veces viene anidado: { data: { Listado: [...] } } u otras combinaciones
      final d2 = data['data'];
      if (d2 is Map) {
        for (final key in candidateKeys) {
          final v = d2[key];
          if (v is List) {
            return v
                .map((e) => Product.fromJson(Map<String, dynamic>.from(e)))
                .toList();
          }
        }
        for (final entry in d2.entries) {
          final v = entry.value;
          if (v is List && v.isNotEmpty && v.first is Map) {
            final first = Map<String, dynamic>.from(v.first as Map);
            if (first.containsKey('product_id') ||
                first.containsKey('product_name')) {
              return v
                  .map(
                    (e) =>
                        Product.fromJson(Map<String, dynamic>.from(e as Map)),
                  )
                  .toList();
            }
          }
        }
      }
    }

    // Si nada coincide
    return <Product>[];
  }
}
