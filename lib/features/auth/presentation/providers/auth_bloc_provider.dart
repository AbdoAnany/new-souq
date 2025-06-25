import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/network/network_info.dart';
import '../../data/datasources/auth_local_data_source.dart';
import '../../data/datasources/auth_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../blocs/auth_bloc.dart';

// External dependencies providers
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) {
  return SharedPreferences.getInstance();
});

final internetConnectionCheckerProvider = Provider<InternetConnectionChecker>((ref) {
  return InternetConnectionChecker.instance;
});

// Data source providers
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    firebaseAuth: ref.read(firebaseAuthProvider),
    firestore: ref.read(firestoreProvider),
  );
});

final authLocalDataSourceProvider = FutureProvider<AuthLocalDataSource>((ref) async {
  final sharedPrefs = await ref.read(sharedPreferencesProvider.future);
  return AuthLocalDataSourceImpl(sharedPreferences: sharedPrefs);
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfoImpl(ref.read(internetConnectionCheckerProvider));
});

// Repository provider
final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final localDataSource = await ref.read(authLocalDataSourceProvider.future);
  return AuthRepositoryImpl(
    remoteDataSource: ref.read(authRemoteDataSourceProvider),
    localDataSource: localDataSource,
    networkInfo: ref.read(networkInfoProvider),
  );
});

// Use case providers
final loginUseCaseProvider = FutureProvider<LoginUseCase>((ref) async {
  final repository = await ref.read(authRepositoryProvider.future);
  return LoginUseCase(repository);
});

final registerUseCaseProvider = FutureProvider<RegisterUseCase>((ref) async {
  final repository = await ref.read(authRepositoryProvider.future);
  return RegisterUseCase(repository);
});

final logoutUseCaseProvider = FutureProvider<LogoutUseCase>((ref) async {
  final repository = await ref.read(authRepositoryProvider.future);
  return LogoutUseCase(repository);
});

final getCurrentUserUseCaseProvider = FutureProvider<GetCurrentUserUseCase>((ref) async {
  final repository = await ref.read(authRepositoryProvider.future);
  return GetCurrentUserUseCase(repository);
});

// AuthBloc provider - simplified approach without complex syncing for now
final authBlocProvider = FutureProvider<AuthBloc>((ref) async {
  final loginUseCase = await ref.read(loginUseCaseProvider.future);
  final registerUseCase = await ref.read(registerUseCaseProvider.future);
  final logoutUseCase = await ref.read(logoutUseCaseProvider.future);
  final getCurrentUserUseCase = await ref.read(getCurrentUserUseCaseProvider.future);
  
  final authBloc = AuthBloc(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
  
  return authBloc;
});
