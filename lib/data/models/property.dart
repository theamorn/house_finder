// Property model.
// NOTE: parsing is hand rolled. Do not add build_runner to this project.

enum PropertyType { house, condo, apartment }

class Property {
  final String id;
  final String title;
  final String type;
  final int price;
  final int bedrooms;
  final int bathrooms;
  final double areaSqm;
  final String address;
  final String district;
  final String imageUrl;
  final bool isFeatured;
  final String listedAt;
  final String agentName;
  final String agentPhone;
  final String description;
  final List<String> amenities;

  Property({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.areaSqm,
    required this.address,
    required this.district,
    required this.imageUrl,
    required this.isFeatured,
    required this.listedAt,
    required this.agentName,
    required this.agentPhone,
    required this.description,
    required this.amenities,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      price: json['price'],
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      areaSqm: json['area_sqm'].toDouble(),
      address: json['address'],
      district: json['district'],
      imageUrl: json['image_url'],
      isFeatured: json['is_featured'],
      listedAt: json['listed_at'],
      agentName: json['agent']['name'],
      agentPhone: json['agent']['phone'],
      description: json['description'],
      amenities: List<String>.from(json['amenities']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'area_sqm': areaSqm,
      'address': address,
      'district': district,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'listed_at': listedAt,
      'agent': {'name': agentName, 'phone': agentPhone},
      'description': description,
      'amenities': amenities,
    };
  }

  // Used by the home screen filter chips.
  PropertyType get typeEnum {
    if (type == 'house') return PropertyType.house;
    if (type == 'condo') return PropertyType.condo;
    return PropertyType.apartment;
  }

  double get pricePerSqm => price / areaSqm;
}
