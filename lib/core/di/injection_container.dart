import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_data_source.dart';
// Features - Auth
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/blocs/auth_bloc.dart';
import '../../features/orders/data/datasources/order_local_data_source.dart';
// Features - Orders
import '../../features/orders/data/datasources/order_remote_data_source.dart';
import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/data/services/order_cache_service.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/order_management_usecases.dart';
import '../../features/orders/domain/usecases/order_usecases.dart';
import '../../features/orders/domain/usecases/paginated_orders_usecases.dart';
import '../../features/orders/domain/usecases/tracking_usecases.dart';
import '../../features/orders/presentation/bloc/order_bloc.dart';
import '../../features/orders/presentation/bloc/tracking_bloc.dart';
import '../../features/products/data/datasources/product_local_data_source.dart';
// Features - Products
import '../../features/products/data/datasources/product_remote_data_source.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/product_usecases.dart';
import '../../features/products/presentation/blocs/product_bloc.dart';
// Core
import '../network/network_info.dart';

final sl = GetIt.instance; // Service Locator

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
        loginUseCase: sl(),
        registerUseCase: sl(),
        logoutUseCase: sl(),
        getCurrentUserUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      firebaseAuth: sl(),
      firestore: sl(),
    ),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Products
  // Bloc
  sl.registerFactory(() => ProductBloc(
        getProductsUseCase: sl(),
        getProductByIdUseCase: sl(),
        getFeaturedProductsUseCase: sl(),
        searchProductsUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByIdUseCase(sl()));
  sl.registerLazySingleton(() => GetFeaturedProductsUseCase(sl()));
  sl.registerLazySingleton(() => SearchProductsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Orders
  // Bloc
  sl.registerFactory(() => OrderBloc(
        getUserOrdersUseCase: sl(),
        getOrderByIdUseCase: sl(),
        placeOrderUseCase: sl(),
        updateOrderStatusUseCase: sl(),
        cancelOrderUseCase: sl(),
        searchOrdersUseCase: sl(),
        updateOrderWithAdminPermissionsUseCase: sl(),
        updateOrderWithValidationUseCase: sl(),
        getOrderStreamUseCase: sl(),
        validateOrderUpdateUseCase: sl(),
      ));

  sl.registerFactory(() => TrackingBloc(
        trackOrderUseCase: sl(),
      ));

  // Use cases
  sl.registerLazySingleton(() => GetUserOrdersUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderByIdUseCase(sl()));
  sl.registerLazySingleton(() => PlaceOrderUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderStatusUseCase(sl()));
  sl.registerLazySingleton(() => CancelOrderUseCase(sl()));
  sl.registerLazySingleton(() => SearchOrdersUseCase(sl()));
  sl.registerLazySingleton(() => TrackOrderUseCase(sl()));

  // Enhanced use cases
  sl.registerLazySingleton(() => UpdateOrderWithAdminPermissionsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderWithValidationUseCase(sl()));
  sl.registerLazySingleton(() => GetOrderStreamUseCase(sl()));
  sl.registerLazySingleton(() => ValidateOrderUpdateUseCase(sl()));

  // Performance and caching use cases
  sl.registerLazySingleton(() => GetPaginatedOrdersUseCase(
        repository: sl(),
        cacheService: sl(),
      ));
  sl.registerLazySingleton(() => PreloadOrdersUseCase(
        repository: sl(),
        cacheService: sl(),
      ));
  sl.registerLazySingleton(() => ClearOrderCacheUseCase(sl()));
  sl.registerLazySingleton(() => GetCacheStatsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<OrderRemoteDataSource>(
    () => OrderRemoteDataSourceImpl(firestore: sl()),
  );

  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // Order cache service
  sl.registerLazySingleton<OrderCacheService>(
    () => OrderCacheService(sl()),
  );

  //! Core
  sl.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(sl()),
  );

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnectionChecker.instance);
  sl.registerLazySingleton(() => FirebaseAuth.instance);
  sl.registerLazySingleton(() => FirebaseFirestore.instance);
  sl.registerLazySingleton(() => FirebaseStorage.instance);
}
