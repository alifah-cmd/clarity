class Answer {
  final String id;
  final String text;
  final bool isCorrect;

  Answer({required this.id, required this.text, this.isCorrect = false});

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      text: map['answer_text'],
      isCorrect: map['is_correct'],
    );
  }
}

class Question {
  final String id;
  final String text;
  final List<Answer> answers;

  Question({required this.id, required this.text, required this.answers});

  factory Question.fromMap(Map<String, dynamic> map, List<Answer> answers) {
    return Question(
      id: map['id'],
      text: map['question_text'],
      answers: answers,
    );
  }
}

class Quiz {
  final String id;
  final String classId;
  final String title;
  final List<Question> questions;

  Quiz({
    required this.id,
    required this.classId,
    required this.title,
    required this.questions,
  });
}
