class Note {
  String title;
  String content;
  bool isPinned;

  Note({
    required this.title,
    required this.content,
    this.isPinned = false,
  });

  Map<String, dynamic> toMap() => {
        "title": title,
        "content": content,
        "isPinned": isPinned,
      };

  static Note fromMap(Map map) => Note(
        title: map["title"] ?? "",
        content: map["content"] ?? "",
        isPinned: map["isPinned"] ?? false,
      );
}
