import '../../core/usecase/usecase.dart';
import '../../core/utils/result.dart';
import '../repositories/repositories.dart';
import '../../models/offer.dart';

class GetActiveOffers implements NoParamsUseCase<Result<List<Offer>>> {
  final OfferRepository repository;
  
  GetActiveOffers(this.repository);
  
  @override
  Future<Result<List<Offer>>> call() async {
    return await repository.getActiveOffers();
  }
}

class GetOfferById implements UseCase<Result<Offer>, String> {
  final OfferRepository repository;
  
  GetOfferById(this.repository);
  
  @override
  Future<Result<Offer>> call(String offerId) async {
    return await repository.getOfferById(offerId);
  }
}

class GetOffersByCategory implements UseCase<Result<List<Offer>>, String> {
  final OfferRepository repository;
  
  GetOffersByCategory(this.repository);
  
  @override
  Future<Result<List<Offer>>> call(String categoryId) async {
    return await repository.getOffersByCategory(categoryId);
  }
}

class ValidateOffer implements UseCase<Result<bool>, ValidateOfferParams> {
  final OfferRepository repository;
  
  ValidateOffer(this.repository);
  
  @override
  Future<Result<bool>> call(ValidateOfferParams params) async {
    return await repository.validateOffer(params.offerId, params.productId);
  }
}

// Parameter classes
class ValidateOfferParams {
  final String offerId;
  final String productId;
  
  const ValidateOfferParams({
    required this.offerId,
    required this.productId,
  });
}
