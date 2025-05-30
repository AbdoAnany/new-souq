import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/result.dart';
import '../../core/failure.dart';
import '../../domain/repositories/repositories.dart';
import '../../domain/entities/category.dart';
import '../../constants/app_constants.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final FirebaseFirestore _firestore;

  CategoryRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<Result<List<Category>, Failure>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => _mapDocumentToCategory(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch categories: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Category, Failure>> getCategoryById(String categoryId) async {
    try {
      final docSnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .get();

      if (!docSnapshot.exists) {
        return Result.failure(NetworkFailure('Category not found'));
      }

      final category = _mapDocumentToCategory(docSnapshot.data()! as Map<String, dynamic>, docSnapshot.id);
      return Result.success(category);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch category: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Category>, Failure>> getSubcategories(String parentId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isEqualTo: parentId)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => _mapDocumentToCategory(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch subcategories: ${e.toString()}'));
    }
  }

  @override
  Future<Result<List<Category>, Failure>> getParentCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.categoriesCollection)
          .where('isActive', isEqualTo: true)
          .where('parentId', isNull: true)
          .orderBy('name')
          .get();

      final categories = querySnapshot.docs
          .map((doc) => _mapDocumentToCategory(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      return Result.success(categories);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to fetch parent categories: ${e.toString()}'));
    }
  }

  @override
  Future<Result<int, Failure>> getProductCount(String categoryId) async {
    try {
      final querySnapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('categoryId', isEqualTo: categoryId)
          .where('inStock', isEqualTo: true)
          .get();

      return Result.success(querySnapshot.docs.length);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to get product count: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Category, Failure>> createCategory(Category category) async {
    try {
      final docRef = await _firestore
          .collection(AppConstants.categoriesCollection)
          .add(_mapCategoryToDocument(category));

      final newCategory = category.copyWith(
        id: docRef.id,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return Result.success(newCategory);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to create category: ${e.toString()}'));
    }
  }

  @override
  Future<Result<Category, Failure>> updateCategory(Category category) async {
    try {
      final updatedCategory = category.copyWith(updatedAt: DateTime.now());
      
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(category.id)
          .update(_mapCategoryToDocument(updatedCategory));

      return Result.success(updatedCategory);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to update category: ${e.toString()}'));
    }
  }

  @override
  Future<Result<void, Failure>> deleteCategory(String categoryId) async {
    try {
      // Soft delete by setting isActive to false
      await _firestore
          .collection(AppConstants.categoriesCollection)
          .doc(categoryId)
          .update({
        'isActive': false,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });

      return Result.success(null);
    } catch (e) {
      return Result.failure(NetworkFailure('Failed to delete category: ${e.toString()}'));
    }
  }

  // Helper methods
  Category _mapDocumentToCategory(Map<String, dynamic> doc, String id) {
    return Category(
      id: id,
      name: doc['name'] ?? '',
      description: doc['description'] ?? '',
      imageUrl: doc['imageUrl'],
      parentId: doc['parentId'],
      productCount: doc['productCount'] ?? 0,
      isActive: doc['isActive'] ?? true,
      createdAt: (doc['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (doc['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> _mapCategoryToDocument(Category category) {
    return {
      'name': category.name,
      'description': category.description,
      'imageUrl': category.imageUrl,
      'parentId': category.parentId,
      'productCount': category.productCount,
      'isActive': category.isActive,
      'createdAt': Timestamp.fromDate(category.createdAt),
      'updatedAt': Timestamp.fromDate(category.updatedAt),
    };
  }
}
