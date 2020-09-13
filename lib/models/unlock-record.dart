class UnlockRecord {
  final int id;
  final DateTime timestamp;

  UnlockRecord(this.id, this.timestamp);

  UnlockRecord.fromJson(Map<String, dynamic> json)
      : timestamp = new DateTime.fromMillisecondsSinceEpoch(json['timestamp']),
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'id': id,
      };
}
