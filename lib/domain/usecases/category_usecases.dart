import '../../core/usecase/usecase.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../repositories/repositories.dart';
import '../entities/category.dart';

class GetCategories implements NoParamsUseCase<List<Category>> {
  final CategoryRepository repository;
  
  GetCategories(this.repository);
  
  @override
  Future<Result<List<Category>, Failure>> call() async {
    return await repository.getCategories();
  }
}

class GetSubcategories implements UseCase<List<Category>, String> {
  final CategoryRepository repository;
  
  GetSubcategories(this.repository);
  
  @override
  Future<Result<List<Category>, Failure>> call(String parentId) async {
    return await repository.getSubcategories(parentId);
  }
}

class GetCategoryById implements UseCase<Category, String> {
  final CategoryRepository repository;
  
  GetCategoryById(this.repository);
  
  @override
  Future<Result<Category, Failure>> call(String categoryId) async {
    return await repository.getCategoryById(categoryId);
  }
}
