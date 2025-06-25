import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../utils/responsive_util.dart';
import '../../domain/entities/order_entity.dart';
import '../bloc/order_bloc.dart';
import '../bloc/order_event.dart';
import '../bloc/order_state.dart';
import '../widgets/order_list_item.dart';
import '../widgets/order_search_bar.dart';

class OrderListScreen extends StatefulWidget {
  final String userId;

  const OrderListScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;
  OrderStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final state = context.read<OrderBloc>().state;
      if (state is OrdersLoaded && !state.hasReachedMax) {
        context.read<OrderBloc>().add(GetUserOrdersEvent(
              userId: widget.userId,
              page: state.currentPage + 1,
              status: _selectedStatus,
            ));
      }
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          sl<OrderBloc>()..add(GetUserOrdersEvent(userId: widget.userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            onTap: (index) {
              _selectedStatus =
                  index == 0 ? null : OrderStatus.values[index - 1];
              context.read<OrderBloc>().add(GetUserOrdersEvent(
                    userId: widget.userId,
                    status: _selectedStatus,
                  ));
            },
            tabs: const [
              Tab(text: 'All'),
              Tab(text: 'Pending'),
              Tab(text: 'Confirmed'),
              Tab(text: 'Processing'),
              Tab(text: 'Shipped'),
              Tab(text: 'Delivered'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Search bar
            OrderSearchBar(
              onSearch: (query) {
                if (query.isNotEmpty) {
                  context.read<OrderBloc>().add(SearchOrdersEvent(
                        userId: widget.userId,
                        query: query,
                      ));
                } else {
                  context.read<OrderBloc>().add(GetUserOrdersEvent(
                        userId: widget.userId,
                        status: _selectedStatus,
                      ));
                }
              },
            ),

            // Order list
            Expanded(
              child: BlocBuilder<OrderBloc, OrderState>(
                builder: (context, state) {
                  if (state is OrderLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrdersLoaded) {
                    return _buildOrderList(state.orders, state.hasReachedMax);
                  } else if (state is OrderSearchResults) {
                    return _buildOrderList(state.orders, true);
                  } else if (state is OrderError) {
                    print('Error loading orders: ${state.message}');
                    return _buildErrorWidget(state.message);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderList(List<OrderEntity> orders, bool hasReachedMax) {
    if (orders.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<OrderBloc>().add(RefreshOrdersEvent(widget.userId));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(ResponsiveUtil.spacing(
          mobile: 16,
          tablet: 20,
          desktop: 24,
        )),
        itemCount: orders.length + (hasReachedMax ? 0 : 1),
        itemBuilder: (context, index) {
          if (index >= orders.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            );
          }

          return OrderListItem(
            order: orders[index],
            onTap: () => _navigateToOrderDetails(orders[index]),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_bag_outlined,
            size: ResponsiveUtil.iconSize(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'No orders found',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            'Your orders will appear here once you place them.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtil.iconSize(
              mobile: 64,
              tablet: 72,
              desktop: 80,
            ),
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              context.read<OrderBloc>().add(RefreshOrdersEvent(widget.userId));
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _navigateToOrderDetails(OrderEntity order) {
    Navigator.pushNamed(
      context,
      '/order-details',
      arguments: order.id,
    );
  }
}
