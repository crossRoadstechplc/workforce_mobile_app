class EvaluationListData {
  const EvaluationListData({this.items = const []});
  final List<EvaluationSummary> items;
}

class EvaluationSummary {
  const EvaluationSummary({
    required this.id,
    required this.number,
    required this.status,
    required this.cycleName,
    required this.periodStart,
    required this.periodEnd,
    this.selfDueAt,
    this.overallSelf,
    this.overallEvaluator,
  });

  final String id;
  final String number;
  final String status;
  final String cycleName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? selfDueAt;
  final double? overallSelf;
  final double? overallEvaluator;

  bool get needsSelfScore => status == 'OPEN' || status == 'SELF_DRAFT';
  bool get resultsVisible => status == 'EVALUATOR_SUBMITTED' || status == 'FINALIZED';

  factory EvaluationSummary.fromJson(Map<String, dynamic> json) {
    final cycle = json['cycle'] as Map<String, dynamic>? ?? const {};
    return EvaluationSummary(
      id: json['id'] as String,
      number: json['number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      cycleName: cycle['name']?.toString() ?? 'Evaluation',
      periodStart: DateTime.tryParse(cycle['periodStart']?.toString() ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(cycle['periodEnd']?.toString() ?? '') ?? DateTime.now(),
      selfDueAt: cycle['selfDueAt'] == null ? null : DateTime.tryParse(cycle['selfDueAt'].toString()),
      overallSelf: (json['overallSelf'] as num?)?.toDouble(),
      overallEvaluator: (json['overallEvaluator'] as num?)?.toDouble(),
    );
  }
}

class EvaluationDetail {
  const EvaluationDetail({
    required this.id,
    required this.number,
    required this.status,
    required this.cycleName,
    required this.periodStart,
    required this.periodEnd,
    required this.employeeName,
    this.jobTitle,
    this.supervisorName,
    this.scores = const [],
    this.goals = const [],
    this.periodSnapshot = const {},
    this.focusCompetency,
    this.actionPlan,
    this.overallSelf,
    this.overallEvaluator,
  });

  final String id;
  final String number;
  final String status;
  final String cycleName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final String employeeName;
  final String? jobTitle;
  final String? supervisorName;
  final List<EvaluationScoreItem> scores;
  final List<EvaluationGoalItem> goals;
  final Map<String, dynamic> periodSnapshot;
  final String? focusCompetency;
  final String? actionPlan;
  final double? overallSelf;
  final double? overallEvaluator;

  bool get needsSelfScore => status == 'OPEN' || status == 'SELF_DRAFT';
  bool get resultsVisible => status == 'EVALUATOR_SUBMITTED' || status == 'FINALIZED';

  factory EvaluationDetail.fromJson(Map<String, dynamic> json) {
    final cycle = json['cycle'] as Map<String, dynamic>? ?? const {};
    final employee = json['employee'] as Map<String, dynamic>? ?? const {};
    final supervisor = employee['supervisor'] as Map<String, dynamic>?;
    return EvaluationDetail(
      id: json['id'] as String,
      number: json['number']?.toString() ?? '',
      status: json['status']?.toString() ?? 'OPEN',
      cycleName: cycle['name']?.toString() ?? 'Evaluation',
      periodStart: DateTime.tryParse(cycle['periodStart']?.toString() ?? '') ?? DateTime.now(),
      periodEnd: DateTime.tryParse(cycle['periodEnd']?.toString() ?? '') ?? DateTime.now(),
      employeeName: employee['name']?.toString() ?? '',
      jobTitle: employee['jobTitle']?.toString(),
      supervisorName: supervisor?['name']?.toString(),
      scores: (json['scores'] as List<dynamic>? ?? const [])
          .map((e) => EvaluationScoreItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      goals: (json['goals'] as List<dynamic>? ?? const [])
          .map((e) => EvaluationGoalItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      periodSnapshot: json['periodSnapshot'] as Map<String, dynamic>? ?? const {},
      focusCompetency: json['focusCompetency']?.toString(),
      actionPlan: json['actionPlan']?.toString(),
      overallSelf: (json['overallSelf'] as num?)?.toDouble(),
      overallEvaluator: (json['overallEvaluator'] as num?)?.toDouble(),
    );
  }
}

class EvaluationScoreItem {
  EvaluationScoreItem({
    required this.itemKey,
    required this.section,
    required this.label,
    this.selfScore,
    this.evaluatorScore,
    this.evaluatorComment,
  });

  final String itemKey;
  final String section;
  final String label;
  int? selfScore;
  final int? evaluatorScore;
  final String? evaluatorComment;

  factory EvaluationScoreItem.fromJson(Map<String, dynamic> json) => EvaluationScoreItem(
        itemKey: json['itemKey'] as String,
        section: json['section']?.toString() ?? 'METRIC',
        label: json['label']?.toString() ?? '',
        selfScore: (json['selfScore'] as num?)?.toInt(),
        evaluatorScore: (json['evaluatorScore'] as num?)?.toInt(),
        evaluatorComment: json['evaluatorComment']?.toString(),
      );
}

class EvaluationGoalItem {
  EvaluationGoalItem({
    required this.id,
    required this.skill,
    this.previousSelfScore,
    this.previousEvaluatorScore,
    this.improvementSelfScore,
    this.improvementEvaluatorScore,
    this.targetDate,
    this.criteria,
  });

  final String id;
  final String skill;
  final int? previousSelfScore;
  final int? previousEvaluatorScore;
  int? improvementSelfScore;
  final int? improvementEvaluatorScore;
  DateTime? targetDate;
  String? criteria;

  factory EvaluationGoalItem.fromJson(Map<String, dynamic> json) => EvaluationGoalItem(
        id: json['id'] as String,
        skill: json['skill']?.toString() ?? '',
        previousSelfScore: (json['previousSelfScore'] as num?)?.toInt(),
        previousEvaluatorScore: (json['previousEvaluatorScore'] as num?)?.toInt(),
        improvementSelfScore: (json['improvementSelfScore'] as num?)?.toInt(),
        improvementEvaluatorScore: (json['improvementEvaluatorScore'] as num?)?.toInt(),
        targetDate: json['targetDate'] == null ? null : DateTime.tryParse(json['targetDate'].toString()),
        criteria: json['criteria']?.toString(),
      );
}
