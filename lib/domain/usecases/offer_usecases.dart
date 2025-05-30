import '../../core/usecase/usecase.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../repositories/repositories.dart';
import '../entities/offer.dart';

class GetActiveOffers implements NoParamsUseCase<List<Offer>> {
  final OfferRepository repository;
  
  GetActiveOffers(this.repository);
  
  @override
  Future<Result<List<Offer>, Failure>> call() async {
    return await repository.getActiveOffers();
  }
}

class GetOfferById implements UseCase<Offer, String> {
  final OfferRepository repository;
  
  GetOfferById(this.repository);
  
  @override
  Future<Result<Offer, Failure>> call(String offerId) async {
    return await repository.getOfferById(offerId);
  }
}

class GetOffersByCategory implements UseCase<List<Offer>, String> {
  final OfferRepository repository;
  
  GetOffersByCategory(this.repository);
    @override
  Future<Result<List<Offer>, Failure>> call(String categoryId) async {
    return await repository.getOffersByCategory(categoryId);
  }
}

class ValidateOffer implements UseCase<bool, ValidateOfferParams> {
  final OfferRepository repository;
  
  ValidateOffer(this.repository);
  
  @override
  Future<Result<bool, Failure>> call(ValidateOfferParams params) async {
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
