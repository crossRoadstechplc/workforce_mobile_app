import 'package:dio/dio.dart';
import '../../../core/api/api_endpoints.dart';
import '../../../core/api/api_exception.dart';
import 'evaluation_models.dart';

class EvaluationRepository {
  EvaluationRepository(this._dio);
  final Dio _dio;

  Future<List<EvaluationSummary>> list() async {
    try {
      final r = await _dio.get<Map<String, dynamic>>(ApiEndpoints.evaluations, queryParameters: {'page': 1, 'pageSize': 50});
      final data = r.data?['data'] as Map<String, dynamic>? ?? const {};
      final list = data['items'] as List<dynamic>? ?? const [];
      return list.map((e) => EvaluationSummary.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<EvaluationDetail> get(String id) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('${ApiEndpoints.evaluations}/$id');
      return EvaluationDetail.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<EvaluationDetail> saveDraft(String id, EvaluationDetail draft) async {
    try {
      final r = await _dio.patch<Map<String, dynamic>>(
        '${ApiEndpoints.evaluations}/$id',
        data: {
          'scores': draft.scores.map((s) => {'itemKey': s.itemKey, 'selfScore': s.selfScore}).toList(),
          'goals': draft.goals
              .map(
                (g) => {
                  'id': g.id,
                  'improvementSelfScore': g.improvementSelfScore,
                  'targetDate': g.targetDate == null ? null : _date(g.targetDate!),
                  'criteria': g.criteria,
                },
              )
              .toList(),
        },
      );
      return EvaluationDetail.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<EvaluationDetail> submit(String id) async {
    try {
      final r = await _dio.post<Map<String, dynamic>>('${ApiEndpoints.evaluations}/$id/submit', data: {});
      return EvaluationDetail.fromJson(r.data!['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

String _date(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
