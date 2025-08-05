/// Görev durumu için model sınıfı
class TaskModel {
  final String taskId;
  final String status;
  final double? progress;
  final String? result;
  final String? error;

  TaskModel({
    required this.taskId,
    required this.status,
    this.progress,
    this.result,
    this.error,
  });

  /// API yanıtından TaskModel oluşturur
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    // Progress değeri API'den int veya double olarak gelebilir
    // Bu nedenle güvenli bir şekilde double'a dönüştürüyoruz
    double? progressValue;
    if (json['progress'] != null) {
      if (json['progress'] is int) {
        progressValue = (json['progress'] as int).toDouble();
      } else if (json['progress'] is double) {
        progressValue = json['progress'] as double;
      } else {
        // String veya başka bir tip olabilir, parse etmeyi dene
        try {
          progressValue = double.parse(json['progress'].toString());
        } catch (e) {
          print(
            'Progress değeri double\'a dönüştürülemedi: ${json['progress']}',
          );
        }
      }
    }

    // Result değeri String veya Map olarak gelebilir
    // Eğer Map ise, String'e dönüştürüyoruz
    String? resultValue;
    if (json['result'] != null) {
      if (json['result'] is String) {
        resultValue = json['result'] as String;
      } else if (json['result'] is Map) {
        // Map'i JSON string'e dönüştür
        try {
          // Eğer story_id varsa, doğrudan onu kullan
          if ((json['result'] as Map).containsKey('story_id')) {
            resultValue = (json['result'] as Map)['story_id'].toString();
          } else {
            // Yoksa tüm Map'i string olarak kullan
            resultValue = json['result'].toString();
          }
          print('Result Map\'ten String\'e dönüştürüldü: $resultValue');
        } catch (e) {
          print('Result dönüştürülürken hata: $e');
        }
      } else {
        // Diğer tipleri string'e dönüştür
        resultValue = json['result'].toString();
      }
    }

    return TaskModel(
      taskId: json['task_id'],
      status: json['status'],
      progress: progressValue,
      result: resultValue,
      error: json['error'],
    );
  }

  /// Görevin tamamlanıp tamamlanmadığını kontrol eder
  bool get isCompleted => status == 'completed';

  /// Görevin hata ile sonuçlanıp sonuçlanmadığını kontrol eder
  bool get hasError => status == 'failed' || error != null;

  /// Görevin hala devam edip etmediğini kontrol eder
  bool get isInProgress => status == 'in_progress' || status == 'pending';
}
