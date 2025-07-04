class ChecklistItem {
  final String id;
  final String title;
  final String description;
  final bool isRequired;
  final bool isChecked;
  final String? observations;
  final DateTime? checkedAt;
  final List<String> photos; // URLs das fotos
  final List<String> localPhotos; // Caminhos locais das fotos

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.isRequired = true,
    this.isChecked = false,
    this.observations,
    this.checkedAt,
    this.photos = const [],
    this.localPhotos = const [],
  });

  // Método copyWith
  ChecklistItem copyWith({
    String? id,
    String? title,
    String? description,
    bool? isRequired,
    bool? isChecked,
    String? observations,
    DateTime? checkedAt,
    List<String>? photos,
    List<String>? localPhotos,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isRequired: isRequired ?? this.isRequired,
      isChecked: isChecked ?? this.isChecked,
      observations: observations ?? this.observations,
      checkedAt: checkedAt ?? this.checkedAt,
      photos: photos ?? this.photos,
      localPhotos: localPhotos ?? this.localPhotos,
    );
  }

  // Serialização para Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isRequired': isRequired,
      'isChecked': isChecked,
      'observations': observations,
      'checkedAt': checkedAt?.toIso8601String(),
      'photos': photos,
      'localPhotos': localPhotos,
    };
  }

  // Deserialização do Firebase
  factory ChecklistItem.fromMap(Map<String, dynamic> map) {
    return ChecklistItem(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      isRequired: map['isRequired'] ?? true,
      isChecked: map['isChecked'] ?? false,
      observations: map['observations'],
      checkedAt: map['checkedAt'] != null 
          ? DateTime.parse(map['checkedAt']) 
          : null,
      photos: List<String>.from(map['photos'] ?? []),
      localPhotos: List<String>.from(map['localPhotos'] ?? []),
    );
  }

  // Método para verificar se tem fotos
  bool get hasPhotos => photos.isNotEmpty || localPhotos.isNotEmpty;

  // Método para obter todas as fotos (locais e remotas)
  List<String> get allPhotos => [...localPhotos, ...photos];

  // Método para contar total de fotos
  int get photoCount => photos.length + localPhotos.length;

  @override
  String toString() {
    return 'ChecklistItem(id: $id, title: $title, isChecked: $isChecked, photos: ${photoCount})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChecklistItem &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.isRequired == isRequired &&
        other.isChecked == isChecked &&
        other.observations == observations &&
        other.checkedAt == checkedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        isRequired.hashCode ^
        isChecked.hashCode ^
        observations.hashCode ^
        checkedAt.hashCode;
  }
}