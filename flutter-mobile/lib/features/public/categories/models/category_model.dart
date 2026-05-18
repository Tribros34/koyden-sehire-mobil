class CategoryModel {
  final String id;
  final String name;
  final String slug;
  final String? parentId;
  final String? icon;
  final int sortOrder;
  final List<CategoryModel> children;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
    this.icon,
    this.sortOrder = 0,
    this.children = const [],
  });

  bool get isRoot => parentId == null;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final raw = (json['children'] as List?) ?? const [];
    final kids = raw
        .whereType<Map>()
        .map((m) => CategoryModel.fromJson(m.cast<String, dynamic>()))
        .toList();
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      parentId: json['parent_id']?.toString(),
      icon: json['icon']?.toString(),
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
      children: kids,
    );
  }
}
