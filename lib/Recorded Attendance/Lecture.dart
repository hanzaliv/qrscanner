class Lecture {
  final String id;
  final String courseId;
  final String lectureUserId;
  final String date;
  final String from;
  final String to;
  final String studentGroupId;

  Lecture({
    required this.id,
    required this.courseId,
    required this.lectureUserId,
    required this.date,
    required this.from,
    required this.to,
    required this.studentGroupId,
  });

  factory Lecture.fromJson(Map<String, dynamic> json) {
    return Lecture(
      id: json['id'],
      courseId: json['course_id'],
      lectureUserId: json['lecture_user_id'],
      date: json['date'],
      from: json['from'],
      to: json['to'],
      studentGroupId: json['student_group_id'],
    );
  }
}


