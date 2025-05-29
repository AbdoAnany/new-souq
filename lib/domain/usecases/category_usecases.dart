import '../../core/usecase/usecase.dart';
import '../../core/utils/result.dart';
import '../repositories/repositories.dart';
import '../../models/category.dart';

class GetCategories implements NoParamsUseCase<Result<List<Category>>> {
  final ProductRepository repository;
  
  GetCategories(this.repository);
  
  @override
  Future<Result<List<Category>>> call() async {
    return await repository.getCategories();
  }
}

class GetSubcategories implements UseCase<Result<List<Category>>, String> {
  final ProductRepository repository;
  
  GetSubcategories(this.repository);
  
  @override
  Future<Result<List<Category>>> call(String parentId) async {
    return await repository.getSubcategories(parentId);
  }
}

class GetCategoryById implements UseCase<Result<Category>, String> {
  final CategoryRepository repository;
  
  GetCategoryById(this.repository);
  
  @override
  Future<Result<Category>> call(String categoryId) async {
    return await repository.getCategoryById(categoryId);
  }
}
