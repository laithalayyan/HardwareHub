class Project {
  final String id;
  final String name;
  final String? category;
  final List<String> imageUrls;
  final String description;
  final double cost;
  final String userId;

  Project({
    required this.id,
    required this.name,
    this.category,
    required this.imageUrls,
    this.description = '',
    required this.cost,
    this.userId = '',
  });
}

