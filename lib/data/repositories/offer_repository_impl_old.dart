import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/offer.dart';
import '../../constants/app_constants.dart';

class OfferRepositoryImpl implements OfferRepository {
  final FirebaseFirestore _firestore;

  OfferRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Offer>>> getActiveOffers() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where('isActive', isEqualTo: true)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .orderBy('endDate')
          .orderBy('createdAt', descending: true)
          .get();

      final offers = querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .where((offer) => offer.isValid)
          .toList();

      return Result.success(offers);
    } catch (e) {
      return Result.failure('Failed to fetch active offers: ${e.toString()}');
    }
  }

  @override
  Future<Result<Offer>> getOfferById(String offerId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .doc(offerId)
          .get();

      if (!docSnapshot.exists) {
        return Result.failure('Offer not found');
      }

      final offer = Offer.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      return Result.success(offer);
    } catch (e) {
      return Result.failure('Failed to fetch offer: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Offer>>> getOffersByCategory(String categoryId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where('isActive', isEqualTo: true)
          .where('categoryId', isEqualTo: categoryId)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .orderBy('endDate')
          .orderBy('discountPercentage', descending: true)
          .get();

      final offers = querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .where((offer) => offer.isValid)
          .toList();

      return Result.success(offers);
    } catch (e) {
      return Result.failure('Failed to fetch category offers: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> validateOffer(String offerId, String productId) async {
    try {
      final offerResult = await getOfferById(offerId);
      if (offerResult.isFailure) {
        return Result.failure('Offer not found');
      }

      final offer = offerResult.data!;
      
      // Check if offer is still valid
      if (!offer.isValid) {
        return Result.success(false);
      }

      // Check if product is eligible for this offer
      if (offer.applicableProducts.isNotEmpty && 
          !offer.applicableProducts.contains(productId)) {
        return Result.success(false);
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure('Failed to validate offer: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Offer>>> getOffersByProduct(String productId) async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection(AppConstants.offersCollection)
          .where('isActive', isEqualTo: true)
          .where('applicableProducts', arrayContains: productId)
          .where('startDate', isLessThanOrEqualTo: now)
          .where('endDate', isGreaterThan: now)
          .orderBy('endDate')
          .orderBy('discountPercentage', descending: true)
          .get();

      final offers = querySnapshot.docs
          .map((doc) => Offer.fromJson({...doc.data(), 'id': doc.id}))
          .where((offer) => offer.isValid)
          .toList();

      return Result.success(offers);
    } catch (e) {
      return Result.failure('Failed to fetch product offers: ${e.toString()}');
    }
  }
}
