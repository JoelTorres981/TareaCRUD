import 'package:mongo_dart/mongo_dart.dart';

class CheapSharkDeal {
  final ObjectId? mongoId;
  final String dealId;
  final String title;
  final String storeId;
  final String gameId;
  final double salePrice;
  final double normalPrice;
  final bool isOnSale;
  final double savings;
  final int metacriticScore;
  final String steamRatingText;
  final int steamRatingPercent;
  final int steamRatingCount;
  final String thumb; // URL to game thumbnail
  final double dealRating;

  CheapSharkDeal({
    this.mongoId,
    required this.dealId,
    required this.title,
    required this.storeId,
    required this.gameId,
    required this.salePrice,
    required this.normalPrice,
    required this.isOnSale,
    required this.savings,
    required this.metacriticScore,
    required this.steamRatingText,
    required this.steamRatingPercent,
    required this.steamRatingCount,
    required this.thumb,
    required this.dealRating,
  });

  /// Factory constructor to parse deal from CheapShark API JSON response
  factory CheapSharkDeal.fromJson(Map<String, dynamic> json) {
    return CheapSharkDeal(
      dealId: json['dealID'] as String? ?? '',
      title: json['title'] as String? ?? 'N/A',
      storeId: json['storeID'] as String? ?? '',
      gameId: json['gameID'] as String? ?? '',
      salePrice: double.tryParse(json['salePrice']?.toString() ?? '') ?? 0.0,
      normalPrice: double.tryParse(json['normalPrice']?.toString() ?? '') ?? 0.0,
      isOnSale: json['isOnSale'] == '1' || json['isOnSale'] == 1,
      savings: double.tryParse(json['savings']?.toString() ?? '') ?? 0.0,
      metacriticScore: int.tryParse(json['metacriticScore']?.toString() ?? '') ?? 0,
      steamRatingText: json['steamRatingText'] as String? ?? 'N/A',
      steamRatingPercent: int.tryParse(json['steamRatingPercent']?.toString() ?? '') ?? 0,
      steamRatingCount: int.tryParse(json['steamRatingCount']?.toString() ?? '') ?? 0,
      thumb: json['thumb'] as String? ?? '',
      dealRating: double.tryParse(json['dealRating']?.toString() ?? '') ?? 0.0,
    );
  }

  /// Factory constructor to load deal from MongoDB Map
  factory CheapSharkDeal.fromMap(Map<String, dynamic> map) {
    return CheapSharkDeal(
      mongoId: map['_id'] as ObjectId?,
      dealId: map['dealId'] ?? '',
      title: map['title'] ?? '',
      storeId: map['storeId'] ?? '',
      gameId: map['gameId'] ?? '',
      salePrice: (map['salePrice'] ?? 0.0).toDouble(),
      normalPrice: (map['normalPrice'] ?? 0.0).toDouble(),
      isOnSale: map['isOnSale'] ?? false,
      savings: (map['savings'] ?? 0.0).toDouble(),
      metacriticScore: map['metacriticScore'] ?? 0,
      steamRatingText: map['steamRatingText'] ?? '',
      steamRatingPercent: map['steamRatingPercent'] ?? 0,
      steamRatingCount: map['steamRatingCount'] ?? 0,
      thumb: map['thumb'] ?? '',
      dealRating: (map['dealRating'] ?? 0.0).toDouble(),
    );
  }

  /// Convert CheapSharkDeal instance to Map for MongoDB persistence
  Map<String, dynamic> toMap() {
    return {
      if (mongoId != null) '_id': mongoId,
      'dealId': dealId,
      'title': title,
      'storeId': storeId,
      'gameId': gameId,
      'salePrice': salePrice,
      'normalPrice': normalPrice,
      'isOnSale': isOnSale,
      'savings': savings,
      'metacriticScore': metacriticScore,
      'steamRatingText': steamRatingText,
      'steamRatingPercent': steamRatingPercent,
      'steamRatingCount': steamRatingCount,
      'thumb': thumb,
      'dealRating': dealRating,
    };
  }
}
