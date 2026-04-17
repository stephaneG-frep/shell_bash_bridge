class PersonalSnippet {
  const PersonalSnippet({
    required this.id,
    required this.title,
    required this.content,
  });

  final String id;
  final String title;
  final String content;

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'content': content,
  };

  factory PersonalSnippet.fromMap(Map<String, dynamic> map) {
    return PersonalSnippet(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      content: map['content']?.toString() ?? '',
    );
  }
}
