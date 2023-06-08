class ImageModel {
  final String id;
  final String createdAt;
  final String description;
  final String url;
  final String location;
  final String createdBy;

  ImageModel(
      {required this.id,
      required this.createdAt,
      required this.createdBy,
      required this.url,
      required this.location,
      required this.description});

  factory ImageModel.fromJson(Map<String, dynamic> json) {
    return ImageModel(
      id: json['id'],
      createdAt: json['createdAt'],
      description: json['description'],
      url: json['url'],
      location: json['location'],
      createdBy: json['createdBy'],
    );
  }
}
