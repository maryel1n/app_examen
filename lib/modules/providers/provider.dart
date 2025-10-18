// lib/modules/providers/provider.dart

class Provider {
  final int id;
  final String name;
  final String lastName;
  final String? mail;
  final String? state;

  Provider({
    required this.id,
    required this.name,
    required this.lastName,
    this.mail,
    this.state,
  });

  Provider copyWith({
    int? id,
    String? name,
    String? lastName,
    String? mail,
    String? state,
  }) {
    return Provider(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      mail: mail ?? this.mail,
      state: state ?? this.state,
    );
  }

  factory Provider.fromMap(Map<String, dynamic> map) {
    int parseInt(dynamic v) {
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? 0;
      return 0;
    }

    String? s(dynamic v) => v?.toString();

    return Provider(
      // acepta provider_id, providerid o id
      id: parseInt(map['provider_id'] ?? map['providerid'] ?? map['id']),
      name: s(map['provider_name'] ?? map['name']) ?? '',
      lastName:
          s(map['provider_last_name'] ?? map['last_name'] ?? map['lastname']) ??
          '',
      mail: s(map['provider_mail'] ?? map['mail'] ?? map['email']),
      state: s(map['provider_state'] ?? map['state']),
    );
  }

  Map<String, dynamic> toMapForApi() {
    return {
      'provider_id': id,
      'provider_name': name,
      'provider_last_name': lastName,
      'provider_mail': mail,
      'provider_state': state ?? 'Activo',
    };
  }

  @override
  String toString() =>
      'Provider(id: $id, name: $name, lastName: $lastName, mail: $mail, state: $state)';
}
