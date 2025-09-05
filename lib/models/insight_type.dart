enum InsightType {
  keyIdea('key_idea'),
  opinion('opinion'),
  recommendation('recommendation'),
  habit('habit'),
  quote('quote');

  const InsightType(this.value);
  final String value;

  static InsightType fromString(String? value) {
    switch (value) {
      case 'key_idea':
        return InsightType.keyIdea;
      case 'opinion':
        return InsightType.opinion;
      case 'recommendation':
        return InsightType.recommendation;
      case 'habit':
        return InsightType.habit;
      case 'quote':
        return InsightType.quote;
      default:
        return InsightType.keyIdea; // Fallback for invalid values
    }
  }
}