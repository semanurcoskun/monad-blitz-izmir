class Transaction {
  final String tokenId;
  final String buyer;
  final String seller;
  final String price;
  final DateTime timestamp;

  Transaction({
    required this.tokenId,
    required this.buyer,
    required this.seller,
    required this.price,
    required this.timestamp,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      tokenId: json['tokenId'].toString(),
      buyer: json['buyer'] ?? '',
      seller: json['seller'] ?? '',
      price: json['price'].toString(),
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.fromMillisecondsSinceEpoch(
              (json['timestamp'] as num).toInt() * 1000,
            ),
    );
  }

  Map<String, dynamic> toJson() => {
    'tokenId': tokenId,
    'buyer': buyer,
    'seller': seller,
    'price': price,
    'timestamp': timestamp.toIso8601String(),
  };
}
