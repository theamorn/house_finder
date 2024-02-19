class NewsItem {
  final String id;
  final String title;
  final String summary;
  final String body;
  final String category;
  final String imageUrl;
  final String publishedAt;
  final bool isPromotion;
  final String? promoCode;
  final int? discountPercent;

  NewsItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.body,
    required this.category,
    required this.imageUrl,
    required this.publishedAt,
    required this.isPromotion,
    this.promoCode,
    this.discountPercent,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['id'],
      title: json['title'],
      summary: json['summary'],
      body: json['body'],
      category: json['category'],
      imageUrl: json['image_url'],
      publishedAt: json['published_at'],
      isPromotion: json['is_promotion'],
      promoCode: json['promo_code'],
      discountPercent: json['discount_percent'],
    );
  }
}
