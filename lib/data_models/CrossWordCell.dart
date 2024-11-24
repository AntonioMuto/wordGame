class CrosswordCell {
  final String type; // "O", "_", "X"
  final String? rif;
  final String? questionX;
  final String? questionY;
  final String? answer;
  String? value;

  CrosswordCell({
    required this.type,
    this.rif,
    this.questionX,
    this.questionY,
    this.answer,
    this.value
  });

  // Metodo per creare una cella da un JSON
  factory CrosswordCell.fromJson(Map<String, dynamic> json) {
    return CrosswordCell(
      type: json['type'],
      rif: json['rif'],
      questionX: json['questionX'],
      questionY: json['questionY'],
      answer: json['answer'],
      value: "",
    );
  }
}