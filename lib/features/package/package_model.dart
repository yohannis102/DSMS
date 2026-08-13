class PackageModel {
  final String id;
  final String packageName;
  final double price;
  final String duration;
  final String description;

  const PackageModel({
    required this.id,
    required this.packageName,
    required this.price,
    required this.duration,
    required this.description,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json['id'] ?? '',
        packageName: json['packageName'] ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0.0,
        duration: json['duration'] ?? '',
        description: json['description'] ?? '',
      );
}
