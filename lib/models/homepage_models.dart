import 'curated_collection_models.dart';

enum HomepageSectionType {
  hero,
  category,
  collection,
  curatedCollection,
  custom,
  resumeReading,
  allCategories,
  unknown,
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
      case 'CURATED_COLLECTION':
        return HomepageSectionType.curatedCollection;
      case 'CUSTOM':
        return HomepageSectionType.custom;
      case 'RESUME_READING':
        return HomepageSectionType.resumeReading;
      case 'ALL_CATEGORIES':
        return HomepageSectionType.allCategories;
      default:
        return HomepageSectionType.unknown;
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
      case HomepageSectionType.curatedCollection:
        return 'CURATED_COLLECTION';
      case HomepageSectionType.custom:
        return 'CUSTOM';
      case HomepageSectionType.resumeReading:
        return 'RESUME_READING';
      case HomepageSectionType.allCategories:
        return 'ALL_CATEGORIES';
      case HomepageSectionType.unknown:
        return 'UNKNOWN';
    }
  }
}

abstract class SectionContent {}

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
}

class CategorySectionContent extends SectionContent {
  final String categoryId;
  final String categoryName;
  final int limit;
  final String sortBy;

  CategorySectionContent({
    required this.categoryId,
    required this.categoryName,
    this.limit = 10,
    this.sortBy = 'random',
  });

  factory CategorySectionContent.fromJson(Map<String, dynamic> json) {
    return CategorySectionContent(
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      limit: json['limit'] is int ? json['limit'] : 10,
      sortBy: json['sortBy']?.toString() ?? 'random',
    );
  }
}

class CollectionSectionContent extends SectionContent {
  final String collectionId;
  final String collectionName;
  final int limit;
  final String sortBy;

  CollectionSectionContent({
    required this.collectionId,
    required this.collectionName,
    this.limit = 10,
    this.sortBy = 'random',
  });

  factory CollectionSectionContent.fromJson(Map<String, dynamic> json) {
    return CollectionSectionContent(
      collectionId: json['collectionId']?.toString() ?? '',
      collectionName: json['collectionName']?.toString() ?? '',
      limit: json['limit'] is int ? json['limit'] : 10,
      sortBy: json['sortBy']?.toString() ?? 'random',
    );
  }
}

class CuratedCollectionSectionContent extends SectionContent {
  final String presentationType;
  final CuratedCollection? collection;

  CuratedCollectionSectionContent({
    required this.presentationType,
    this.collection,
  });

  factory CuratedCollectionSectionContent.fromJson(Map<String, dynamic> json) {
    CuratedCollection? collection;
    if (json['collection'] != null) {
      collection = CuratedCollection.fromJson(
        json['collection'] as Map<String, dynamic>,
      );
    }

    return CuratedCollectionSectionContent(
      presentationType: json['presentationType']?.toString() ?? '',
      collection: collection,
    );
  }
}

class CustomSectionContent extends SectionContent {
  final String endpoint;
  final Map<String, dynamic>? parameters;
  final int limit;
  final String sortBy;

  CustomSectionContent({
    required this.endpoint,
    this.parameters,
    this.limit = 10,
    this.sortBy = 'random',
  });

  factory CustomSectionContent.fromJson(Map<String, dynamic> json) {
    return CustomSectionContent(
      endpoint: json['endpoint']?.toString() ?? '',
      parameters: json['parameters'] as Map<String, dynamic>?,
      limit: json['limit'] is int ? json['limit'] : 10,
      sortBy: json['sortBy']?.toString() ?? 'random',
    );
  }
}

class ResumeReadingSectionContent extends SectionContent {
  final int limit;

  ResumeReadingSectionContent({this.limit = 10});

  factory ResumeReadingSectionContent.fromJson(Map<String, dynamic> json) {
    return ResumeReadingSectionContent(
      limit: json['limit'] is int ? json['limit'] : 10,
    );
  }
}

class AllCategoriesSectionContent extends SectionContent {
  final int categoryCount;

  AllCategoriesSectionContent({required this.categoryCount});

  factory AllCategoriesSectionContent.fromJson(Map<String, dynamic> json) {
    return AllCategoriesSectionContent(
      categoryCount: json['categoryCount'] is int ? json['categoryCount'] : 6,
    );
  }
}

class UnknownSectionContent extends SectionContent {
  UnknownSectionContent();

  factory UnknownSectionContent.fromJson(Map<String, dynamic> json) {
    return UnknownSectionContent();
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
      json['type']?.toString() ?? 'UNKNOWN',
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
      case HomepageSectionType.curatedCollection:
        content = CuratedCollectionSectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.custom:
        content = CustomSectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.resumeReading:
        content = ResumeReadingSectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.allCategories:
        content = AllCategoriesSectionContent.fromJson(contentJson);
        break;
      case HomepageSectionType.unknown:
        content = UnknownSectionContent.fromJson(contentJson);
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
}
