class Ticket {
  final String tokenId;
  final String eventName;
  final String eventDate;
  final String eventLocation;
  final String seatInfo;
  final String price;
  final int purchaseTimestamp;
  final bool used;

  Ticket({
    required this.tokenId,
    required this.eventName,
    required this.eventDate,
    required this.eventLocation,
    required this.seatInfo,
    required this.price,
    required this.purchaseTimestamp,
    required this.used,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      tokenId: json['tokenId'].toString(),
      eventName: json['eventName'] ?? 'Etkinlik',
      eventDate: json['eventDate'] ?? 'TBD',
      eventLocation: json['eventLocation'] ?? 'TBD',
      seatInfo: json['seatInfo'] ?? 'TBD',
      price: json['price'].toString(),
      purchaseTimestamp: json['purchaseTimestamp'] ?? 0,
      used: json['used'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'tokenId': tokenId,
    'eventName': eventName,
    'eventDate': eventDate,
    'eventLocation': eventLocation,
    'seatInfo': seatInfo,
    'price': price,
    'purchaseTimestamp': purchaseTimestamp,
    'used': used,
  };
}
