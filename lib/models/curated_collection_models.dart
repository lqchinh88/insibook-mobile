import 'book_models.dart';

class CuratedCollection {
  final String id;
  final Map<String, String>? localizedTitle;
  final Map<String, String>? localizedDescription;
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
    this.localizedTitle,
    this.localizedDescription,
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
      localizedTitle: json['localizedTitle'] != null
          ? Map<String, String>.from(json['localizedTitle'] as Map)
          : json['title'] != null ? {'en': json['title'].toString()} : null,
      localizedDescription: json['localizedDescription'] != null
          ? Map<String, String>.from(json['localizedDescription'] as Map)
          : json['description'] != null ? {'en': json['description'].toString()} : null,
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

  // Helper method to get localized title
  String getTitle(String languageCode) {
    if (localizedTitle == null) return '';
    return localizedTitle![languageCode] ?? localizedTitle!['en'] ?? localizedTitle!.values.first;
  }

  // Helper method to get localized description
  String getDescription(String languageCode) {
    if (localizedDescription == null) return '';
    return localizedDescription![languageCode] ?? localizedDescription!['en'] ?? localizedDescription!.values.first;
  }

  // Convenience getters for backward compatibility
  String get title => localizedTitle?.values.first ?? '';
  String? get description => localizedDescription?.values.first;
}

class CuratedCollectionItem {
  final String id;
  final int order;
  final InternalBookItem book;
  final Map<String, String>? localizedReasonForInclusion;
  final Map<String, String>? localizedKeyTakeaways;
  final Map<String, String>? localizedPrerequisites;

  CuratedCollectionItem({
    required this.id,
    required this.order,
    required this.book,
    this.localizedReasonForInclusion,
    this.localizedKeyTakeaways,
    this.localizedPrerequisites,
  });

  factory CuratedCollectionItem.fromJson(Map<String, dynamic> json) {
    return CuratedCollectionItem(
      id: json['id']?.toString() ?? '',
      order: json['order'] is int ? json['order'] : 0,
      book: InternalBookItem.fromJson(json['book'] as Map<String, dynamic>? ?? {}),
      localizedReasonForInclusion: json['localizedReasonForInclusion'] != null
          ? Map<String, String>.from(json['localizedReasonForInclusion'] as Map)
          : json['reasonForInclusion'] != null ? {'en': json['reasonForInclusion'].toString()} : null,
      localizedKeyTakeaways: json['localizedKeyTakeaways'] != null
          ? Map<String, String>.from(json['localizedKeyTakeaways'] as Map)
          : json['keyTakeaways'] != null ? {'en': json['keyTakeaways'].toString()} : null,
      localizedPrerequisites: json['localizedPrerequisites'] != null
          ? Map<String, String>.from(json['localizedPrerequisites'] as Map)
          : json['prerequisites'] != null ? {'en': json['prerequisites'].toString()} : null,
    );
  }

  // Helper methods to get localized content
  String getReasonForInclusion(String languageCode) {
    if (localizedReasonForInclusion == null) return '';
    return localizedReasonForInclusion![languageCode] ?? localizedReasonForInclusion!['en'] ?? localizedReasonForInclusion!.values.first;
  }

  String getKeyTakeaways(String languageCode) {
    if (localizedKeyTakeaways == null) return '';
    return localizedKeyTakeaways![languageCode] ?? localizedKeyTakeaways!['en'] ?? localizedKeyTakeaways!.values.first;
  }

  String getPrerequisites(String languageCode) {
    if (localizedPrerequisites == null) return '';
    return localizedPrerequisites![languageCode] ?? localizedPrerequisites!['en'] ?? localizedPrerequisites!.values.first;
  }

  // Convenience getters for backward compatibility
  String? get reasonForInclusion => localizedReasonForInclusion?.values.first;
  String? get keyTakeaways => localizedKeyTakeaways?.values.first;
  String? get prerequisites => localizedPrerequisites?.values.first;
}