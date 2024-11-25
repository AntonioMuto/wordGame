class CrosswordCell {
  final String type; // "O", "_", "X"
  final String? rif;
  final String? questionX;
  final String? questionY;
  final String? answer;
  String? value;
  bool isCorrect = false;

  CrosswordCell({
    required this.type,
    this.rif,
    this.questionX,
    this.questionY,
    this.answer,
    this.value,
    required this.isCorrect
  });

  // Metodo per creare una cella da un JSON
  factory CrosswordCell.fromJson(Map<String, dynamic> json) {
    return CrosswordCell(
      type: json['type'] ?? '',  // Se 'type' non esiste, assegna una stringa vuota
      rif: json['rif'] ?? null,  // Se 'rif' non esiste, assegna null
      questionX: json['questionX'] ?? '',  // Se 'questionX' non esiste, assegna una stringa vuota
      questionY: json['questionY'] ?? '',  // Se 'questionY' non esiste, assegna una stringa vuota
      answer: json['answer'] ?? '',  // Se 'answer' non esiste, assegna una stringa vuota
      value: "",  // Questo è sempre vuoto, immagino
      isCorrect: false
    );
  }

  CrosswordCell copy() {
    return CrosswordCell(
      rif: rif,
      questionX: questionX,
      questionY: questionY,
      value: value,
      answer: answer,
      isCorrect: isCorrect,
      type: type
    );
  }
}