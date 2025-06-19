import '/core/import_core.dart';


AppBarTheme get appBarTheme {
  return AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: AppColorScheme.primary,
    titleTextStyle: AppTextTheme.textTheme.headlineSmall!.copyWith(
      color: AppColorScheme.onPrimary,
    ),
    iconTheme: IconThemeData(
      color: AppColorScheme.onPrimary,
    ),
  );
}
