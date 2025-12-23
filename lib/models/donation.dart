class Donation {
  final String id;
  final String userId;
  final String foodItemName;
  final double quantity; // in kg
  final String? photoPath;
  final String? notes;
  final DateTime donationDate;

  Donation({
    required this.id,
    required this.userId,
    required this.foodItemName,
    required this.quantity,
    this.photoPath,
    this.notes,
    required this.donationDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'foodItemName': foodItemName,
      'quantity': quantity,
      'photoPath': photoPath,
      'notes': notes,
      'donationDate': donationDate.toIso8601String(),
    };
  }

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      userId: json['userId'],
      foodItemName: json['foodItemName'],
      quantity: (json['quantity'] as num).toDouble(),
      photoPath: json['photoPath'],
      notes: json['notes'],
      donationDate: DateTime.parse(json['donationDate']),
    );
  }
}
