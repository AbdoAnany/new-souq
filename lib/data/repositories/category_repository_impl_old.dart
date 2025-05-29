import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/utils/result.dart';
import '../../domain/repositories/repositories.dart';
import '../../models/category.dart';
import '../../constants/app_constants.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Category>>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure('Failed to fetch categories: ${e.toString()}');
    }
  }

  @override
  Future<Result<Category>> getCategoryById(String categoryId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();

      if (!docSnapshot.exists) {
        return Result.failure('Category not found');
      }

      final category = Category.fromJson({...docSnapshot.data()!, 'id': docSnapshot.id});
      return Result.success(category);
    } catch (e) {
      return Result.failure('Failed to fetch category: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Category>>> getSubcategories(String parentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isEqualTo: parentId)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure('Failed to fetch subcategories: ${e.toString()}');
    }
  }

  @override
  Future<Result<List<Category>>> getParentCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isNull: true)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => Category.fromJson({...doc.data(), 'id': doc.id}))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure('Failed to fetch parent categories: ${e.toString()}');
    }
  }

  @override
  Future<Result<int>> getProductCount(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true)
          .get();

      return Result.success(querySnapshot.docs.length);
    } catch (e) {
      return Result.failure('Failed to get product count: ${e.toString()}');
    }
  }
}
