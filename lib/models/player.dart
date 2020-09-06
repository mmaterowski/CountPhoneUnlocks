class Player {
  final int id;
  final String timestamp;

  Player(this.id, this.timestamp);

  Player.fromJson(Map<String, dynamic> json)
      : timestamp = getStringFromDate(
                new DateTime.fromMillisecondsSinceEpoch(json['timestamp']))
            .toString(),
        id = json['id'];

  Map<String, dynamic> toJson() => {
        'timestamp': timestamp,
        'id': id,
      };
}

getStringFromDate(DateTime dateTime) {
  return dateTime.year.toString() +
      "/" +
      dateTime.month.toString() +
      "/" +
      dateTime.day.toString();
}
