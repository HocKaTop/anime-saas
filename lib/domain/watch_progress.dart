class WatchProgress {
  final String episodeId;
  final int positionSec;
  final int? durationSec;
  final bool completed;

  const WatchProgress({
    required this.episodeId,
    required this.positionSec,
    this.durationSec,
    this.completed=false,
  });

  double get progress{
    final duration =durationSec;
    if(duration == null || duration <=0){
      return 0;
    }
    return (positionSec/duration).clamp(0.0, 1.0).toDouble();
  }

  factory WatchProgress.fromJson(Map<String,dynamic> json){
    return WatchProgress(
      episodeId: json ['episodeId'] as String,
      positionSec: (json ['positionSec'] as num).toInt(),
      durationSec:(json ['durationSec'] as num?)?.toInt() ,
      completed: json['completed'] as bool,
      );
  }

  Map<String,Object?> toJson (){
    return{
      'positionSec':positionSec,
      if(durationSec != null) 'durationSec':durationSec,
    };
  }
}