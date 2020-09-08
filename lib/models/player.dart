class Player {
  final int id;
  final DateTime timestamp;

  Player(this.id, this.timestamp);

  Player.fromJson(Map<String, dynamic> json)
      : timestamp = new DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'id': id,
      };
}
