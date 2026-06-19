import 'package:mongo_dart/mongo_dart.dart';

import '../models/cheapshark.dart';

class MongoDatabase {
  static const String mongoUrl =
      'mongodb+srv://<USER>:<PASSWORD>@cluster0.nbnn2uz.mongodb.net/MediaExplorer?retryWrites=true&w=majority&appName=Cluster0';

  static const String collectionName = 'cheapshark';

  static late Db db;
  static late DbCollection collection;

  static Future<void> connect() async {
    db = await Db.create(mongoUrl);
    await db.open();
    collection = db.collection(collectionName);
  }

  static Future<List<CheapSharkDeal>> getDeals() async {
    final List<Map<String, dynamic>> data = await collection.find().toList();

    return data.map((item) {
      return CheapSharkDeal.fromMap(item);
    }).toList();
  }

  static Future<List<CheapSharkDeal>> getDealsPaged({required int skip, required int limit}) async {
    final List<Map<String, dynamic>> data = await collection
        .find(where.skip(skip).limit(limit))
        .toList();

    return data.map((item) {
      return CheapSharkDeal.fromMap(item);
    }).toList();
  }

  static Future<void> insertDeal(CheapSharkDeal deal) async {
    await collection.insertOne(deal.toMap());
  }

  static Future<void> updateDeal(CheapSharkDeal deal) async {
    await collection.updateOne(
      where.eq('dealId', deal.dealId),
      modify
          .set('title', deal.title)
          .set('storeId', deal.storeId)
          .set('gameId', deal.gameId)
          .set('salePrice', deal.salePrice)
          .set('normalPrice', deal.normalPrice)
          .set('isOnSale', deal.isOnSale)
          .set('savings', deal.savings)
          .set('metacriticScore', deal.metacriticScore)
          .set('steamRatingText', deal.steamRatingText)
          .set('steamRatingPercent', deal.steamRatingPercent)
          .set('steamRatingCount', deal.steamRatingCount)
          .set('thumb', deal.thumb)
          .set('dealRating', deal.dealRating),
    );
  }

  static Future<void> deleteDeal(String dealId) async {
    await collection.deleteOne(where.eq('dealId', dealId));
  }
}
