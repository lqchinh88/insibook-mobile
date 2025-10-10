import 'book_models.dart';

class CuratedCollection {
  final String id;
  final String title;
  final String? description;
  final String? curatorName;
  final String? curatorId;
  final String? coverImageUrl;
  final int bookCount;
  final String? publishedAt;
  final String createdAt;
  final String updatedAt;
  final List<CuratedCollectionItem>? items;

  CuratedCollection({
    required this.id,
    required this.title,
    this.description,
    this.curatorName,
    this.curatorId,
    this.coverImageUrl,
    required this.bookCount,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    this.items,
  });

  factory CuratedCollection.fromJson(Map<String, dynamic> json) {
    return CuratedCollection(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      curatorName: json['curatorName']?.toString(),
      curatorId: json['curatorId']?.toString(),
      coverImageUrl: json['coverImageUrl']?.toString(),
      bookCount: json['bookCount'] is int ? json['bookCount'] : 0,
      publishedAt: json['publishedAt']?.toString(),
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => CuratedCollectionItem.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CuratedCollectionItem {
  final String id;
  final int order;
  final InternalBookItem book;
  final String? reasonForInclusion;
  final String? keyTakeaways;
  final String? prerequisites;

  CuratedCollectionItem({
    required this.id,
    required this.order,
    required this.book,
    this.reasonForInclusion,
    this.keyTakeaways,
    this.prerequisites,
  });

  factory CuratedCollectionItem.fromJson(Map<String, dynamic> json) {
    return CuratedCollectionItem(
      id: json['id']?.toString() ?? '',
      order: json['order'] is int ? json['order'] : 0,
      book: InternalBookItem.fromJson(json['book'] as Map<String, dynamic>? ?? {}),
      reasonForInclusion: json['reasonForInclusion']?.toString(),
      keyTakeaways: json['keyTakeaways']?.toString(),
      prerequisites: json['prerequisites']?.toString(),
    );
  }
}