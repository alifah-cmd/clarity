class SearchHistory {
  final String id;
  final String keyword;
  final DateTime searchedAt;

  SearchHistory({
    required this.id,
    required this.keyword,
    required this.searchedAt,
  });

  factory SearchHistory.fromMap(Map<String, dynamic> map) {
    return SearchHistory(
      id: map['id'],
      keyword: map['keyword'],
      searchedAt: DateTime.parse(map['searched_at']),
    );
  }
}