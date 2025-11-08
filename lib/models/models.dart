class User {
  final int? id;
  final String username;
  final String password;
  final String? name;
  final String createdAt;

  User({
    this.id,
    required this.username,
    required this.password,
    this.name,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'name': name,
      'created_at': createdAt,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as int?,
      username: map['username'] as String,
      password: map['password'] as String,
      name: map['name'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}

class Run {
  final int? id;
  final int userId;
  final String title;
  final double distance;
  final int duration;
  final String pace;
  final int? calories;
  final int? avgPaceSpm;
  final int? elevationGain;
  final String runDate;
  final String createdAt;

  Run({
    this.id,
    required this.userId,
    required this.title,
    required this.distance,
    required this.duration,
    required this.pace,
    this.calories,
    this.avgPaceSpm,
    this.elevationGain,
    required this.runDate,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'distance': distance,
      'duration': duration,
      'pace': pace,
      'calories': calories,
      'avg_pace_spm': avgPaceSpm,
      'elevation_gain': elevationGain,
      'run_date': runDate,
      'created_at': createdAt,
    };
  }

  factory Run.fromMap(Map<String, dynamic> map) {
    return Run(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      distance: map['distance'] as double,
      duration: map['duration'] as int,
      pace: map['pace'] as String,
      calories: map['calories'] as int?,
      avgPaceSpm: map['avg_pace_spm'] as int?,
      elevationGain: map['elevation_gain'] as int?,
      runDate: map['run_date'] as String,
      createdAt: map['created_at'] as String,
    );
  }

  String get durationFormatted {
    final hours = duration ~/ 3600;
    final minutes = (duration % 3600) ~/ 60;
    final seconds = duration % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

class UserStats {
  final double totalDistance;
  final int totalRuns;
  final String averagePace;
  final String totalTime;

  UserStats({
    required this.totalDistance,
    required this.totalRuns,
    required this.averagePace,
    required this.totalTime,
  });

  factory UserStats.fromMap(Map<String, dynamic> map) {
    return UserStats(
      totalDistance: map['total_distance'] as double,
      totalRuns: map['total_runs'] as int,
      averagePace: map['average_pace'] as String,
      totalTime: map['total_time'] as String,
    );
  }
}