enum HomepageSectionType {
  hero,
  category,
  collection,
  custom,
}

extension HomepageSectionTypeExtension on HomepageSectionType {
  static HomepageSectionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'HERO':
        return HomepageSectionType.hero;
      case 'CATEGORY':
        return HomepageSectionType.category;
      case 'COLLECTION':
        return HomepageSectionType.collection;
      case 'CUSTOM':
        return HomepageSectionType.custom;
      default:
        throw ArgumentError('Unknown section type: $value');
    }
  }

  String get value {
    switch (this) {
      case HomepageSectionType.hero:
        return 'HERO';
      case HomepageSectionType.category:
        return 'CATEGORY';
      case HomepageSectionType.collection:
        return 'COLLECTION';
      case HomepageSectionType.custom:
        return 'CUSTOM';
    }
  }
}

abstract class SectionContent {
  Map<String, dynamic> toJson();
}

class HeroSectionContent extends SectionContent {
  final String? bookId;
  final String? imageUrl;
  final String? ctaText;
  final String? ctaAction;

  HeroSectionContent({
    this.bookId,
    this.imageUrl,
    this.ctaText,
    this.ctaAction,
  });

  factory HeroSectionContent.fromJson(Map<String, dynamic> json) {
    return HeroSectionContent(
      bookId: json['bookId']?.toString(),
      imageUrl: json['imageUrl']?.toString(),
      ctaText: json['ctaText']?.toString(),
      ctaAction: json['ctaAction']?.toString(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'bookId': bookId,
      'imageUrl': imageUrl,
      'ctaText': ctaText,
      'ctaAction': ctaAction,
    };
  }
}

class CategorySectionContent extends SectionContent {
  final String categoryId;
  final String categoryName;
  final int limit;

  CategorySectionContent({
    required this.categoryId,
    required this.categoryName,
    this.limit = 10,
  });

  factory CategorySectionContent.fromJson(Map<String, dynamic> json) {
    return CategorySectionContent(
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      limit: json['limit'] is int ? json['limit'] : 10,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'limit': limit,
    };
  }
}

class CollectionSectionContent extends SectionContent {
  final String collectionId;
  final String collectionName;
  final int limit;

  CollectionSectionContent({
    required this.collectionId,
    required this.collectionName,
    this.limit = 10,
  });

  factory CollectionSectionContent.fromJson(Map<String, dynamic> json) {
    return CollectionSectionContent(
      collectionId: json['collectionId']?.toString() ?? '',
      collectionName: json['collectionName']?.toString() ?? '',
      limit: json['limit'] is int ? json['limit'] : 10,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'collectionId': collectionId,
      'collectionName': collectionName,
      'limit': limit,
    };
  }
}

class CustomSectionContent extends SectionContent {
  final String endpoint;
  final Map<String, dynamic>? parameters;
  final int limit;

  CustomSectionContent({
    required this.endpoint,
    this.parameters,
    this.limit = 10,
  });

  factory CustomSectionContent.fromJson(Map<String, dynamic> json) {
    return CustomSectionContent(
      endpoint: json['endpoint']?.toString() ?? '',
      parameters: json['parameters'] as Map<String, dynamic>?,
      limit: json['limit'] is int ? json['limit'] : 10,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'endpoint': endpoint,
      'parameters': parameters,
      'limit': limit,
    };
  }
}

class HomepageSection {
  final String id;
  final HomepageSectionType type;
  final String title;
  final String? subtitle;
  final int displayOrder;
  final SectionContent content;

  HomepageSection({
    required this.id,
    required this.type,
    required this.title,
    this.subtitle,
    required this.displayOrder,
    required this.content,
  });

  factory HomepageSection.fromJson(Map<String, dynamic> json) {
    final type = HomepageSectionTypeExtension.fromString(
      json['type']?.toString() ?? 'HERO',
    );

    SectionContent content;
    final contentJson = json['content'] as Map<String, dynamic>? ?? {};

    switch (type) {
      case HomepageSectionType.hero:
        content = HeroSectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.category:
        content = CategorySectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.collection:
        content = CollectionSectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.custom:
        content = CustomSectionContent.fromJson(contentJson);
        break;
    }

    return HomepageSection(
      id: json['id']?.toString() ?? '',
      type: type,
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString(),
      displayOrder: json['displayOrder'] is int ? json['displayOrder'] : 0,
      content: content,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'subtitle': subtitle,
      'displayOrder': displayOrder,
      'content': content.toJson(),
    };
  }
}

class HomepageResponse {
  final List<HomepageSection> sections;

  HomepageResponse({required this.sections});

  factory HomepageResponse.fromJson(Map<String, dynamic> json) {
    final sectionsJson = json['sections'] as List<dynamic>? ?? [];
    final sections = sectionsJson
        .map((sectionJson) => HomepageSection.fromJson(sectionJson))
        .toList();

    // Sort sections by display order
    sections.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));

    return HomepageResponse(sections: sections);
  }

  Map<String, dynamic> toJson() {
    return {
      'sections': sections.map((section) => section.toJson()).toList(),
    };
  }
}