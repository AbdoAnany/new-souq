
import '/core/import_core.dart';

/// Reusable card widget with consistent styling and responsive behavior
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.margin,
    this.elevation,
    this.color,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final BoxBorder? border;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget card = Card(
      elevation: elevation ?? 1,
      color: color,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.cardBorderRadius),
        side: border != null 
          ? BorderSide(
              color: border is Border 
                ? (border as Border).top.color 
                : theme.colorScheme.outline,
              width: border is Border 
                ? (border as Border).top.width 
                : 1,
            )
          : BorderSide.none,
      ),
      child: Container(
        width: width,
        height: height,
        padding: padding ?? const EdgeInsets.all(AppDimensions.mediumPadding),
        child: child,
      ),
    );

    if (onTap != null) {
      card = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(AppDimensions.cardBorderRadius),
        child: card,
      );
    }

    if (margin != null) {
      card = Container(
        margin: margin,
        child: card,
      );
    }

    return card;
  }
}

/// Specialized card for product display
class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.title,
    required this.price,
    this.imageUrl,
    this.onTap,
    this.onAddToCart,
    this.isInCart = false,
    this.discount,
  });

  final String title;
  final String price;
  final String? imageUrl;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final bool isInCart;
  final String? discount;

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    
    return AppCard(
      onTap: onTap,
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Stack(
            children: [
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color:  AppColorScheme.surfaceContainerHighest,
                  borderRadius:  BorderRadius.vertical(
                    top: Radius.circular(AppDimensions.cardBorderRadius),
                  ),
                ),
                child: imageUrl != null
                  ? ClipRRect(
                      borderRadius:  BorderRadius.vertical(
                        top: Radius.circular(AppDimensions.cardBorderRadius),
                      ),
                      child: Image.network(
                        imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      ),
                    )
                  : _buildImagePlaceholder(),
              ),
              
              // Discount badge
              if (discount != null)
                Positioned(
                  top: AppDimensions.smallPadding,
                  left: AppDimensions.smallPadding,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.smallPadding,
                      vertical: AppDimensions.smallPadding,
                    ),
                    decoration: BoxDecoration(
                      color: AppColorScheme.error,
                      borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
                    ),
                    child: Text(
                      discount!,
                      style: AppTextTheme.textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          
          // Product Details
          Padding(
            padding: const EdgeInsets.all(AppDimensions.smallPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextTheme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppDimensions.smallPadding),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      price,
                      style: AppTextTheme.textTheme.titleMedium?.copyWith(
                        color: AppColorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    if (onAddToCart != null)
                      IconButton(
                        onPressed: onAddToCart,
                        icon: Icon(
                          isInCart ? Icons.check_circle : Icons.add_shopping_cart,
                          color: isInCart ? AppColorScheme.success : AppColorScheme.primary,
                        ),
                        iconSize: AppDimensions.mediumPadding,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: AppDimensions.mediumPadding,
                          minHeight: AppDimensions.mediumPadding,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.image,
        size: AppDimensions.mediumIconSize,
        color: AppColorScheme.onSurfaceVariant,
      ),
    );
  }
}


/// Loading card for shimmer effects
class LoadingCard extends StatelessWidget {
  const LoadingCard({
    super.key,
    this.height = 200,
    this.width,
  });

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AppCard(
      width: width,
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          Container(
            height: height * 0.6,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.borderRadius),
            ),
          ),
          
          const SizedBox(height: AppDimensions.smallPadding),
          
          // Title placeholder
          Container(
            height: 16,
            width: double.infinity,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
            ),
          ),
          
          const SizedBox(height: AppDimensions.smallPadding),
          
          // Price placeholder
          Container(
            height: 14,
            width: 80,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppDimensions.cardBorderRadius),
            ),
          ),
        ],
      ),
    );
  }
}
