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
      name: json["product"]?.toString() ?? json["name"]?.toString() ?? "Sản phẩm",
      price: (json["price"] is num) ? (json["price"] as num).toDouble() : 0.0,
      image: json["image"]?.toString(),
      description: json["description"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      "product": name,  // API yêu cầu "product" thay vì "name"
      "price": price,
      "image": image,
      "description": description,
    };
    // Chỉ thêm id khi có giá trị (khi update)
    if (id != null) {
      json["id"] = id;
    }
    return json;
  }
}