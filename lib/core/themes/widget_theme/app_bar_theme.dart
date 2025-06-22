import '/core/import_core.dart';


AppBarTheme get appBarTheme {
  return AppBarTheme(
    centerTitle: true,
    elevation: 0,
    backgroundColor: AppColorScheme.onSecondary,
    titleTextStyle: AppTextTheme.textTheme.headlineSmall!.copyWith(
      color: AppColorScheme.primary,
    ),
    iconTheme: IconThemeData(
      color: AppColorScheme.onPrimary,
    ),
  );
}
