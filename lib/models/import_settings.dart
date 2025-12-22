enum ImportLevel { all, none, custom }

class ImportSettings {
  final ImportLevel level;
  final List<String> fields;

  ImportSettings({
    this.level = ImportLevel.custom,
    this.fields = const ['subject'],
  });

  factory ImportSettings.fromJson(Map<String, dynamic> json) {
    return ImportSettings(
      level: _parseLevel(json['level']),
      fields: (json['fields'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? ['subject'],
    );
  }

  static ImportLevel _parseLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'all':
        return ImportLevel.all;
      case 'none':
        return ImportLevel.none;
      case 'custom':
      default:
        return ImportLevel.custom;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'fields': fields,
    };
  }

  ImportSettings copyWith({
    ImportLevel? level,
    List<String>? fields,
  }) {
    return ImportSettings(
      level: level ?? this.level,
      fields: fields ?? this.fields,
    );
  }

  bool hasField(String field) {
    if (level == ImportLevel.all) return true;
    if (level == ImportLevel.none) return false;
    return fields.contains(field.toLowerCase());
  }
}
