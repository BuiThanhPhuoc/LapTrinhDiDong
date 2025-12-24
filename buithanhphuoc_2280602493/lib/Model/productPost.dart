class ProductPost {
  final int? id;
  final String? name;
  final double? price;
  final String? image;
  final String? description;

  ProductPost({this.id, this.name, this.price, this.image, this.description});

  factory ProductPost.fromJson(Map<String, dynamic> json) {
    return ProductPost(
      id: json["id"] as int?,
      name: json["name"]?.toString() ?? "Người dùng",
      price: (json["price"] is num) ? (json["price"] as num).toDouble() : 0.0,
      image: json["image"]?.toString(),
      description: json["description"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "price": price,
    "image": image,
    "description": description,
  };
}