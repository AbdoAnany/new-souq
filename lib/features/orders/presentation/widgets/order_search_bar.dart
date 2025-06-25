import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../utils/responsive_util.dart';

class OrderSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController? controller;

  const OrderSearchBar({
    Key? key,
    required this.onSearch,
    this.controller,
  }) : super(key: key);

  @override
  State<OrderSearchBar> createState() => _OrderSearchBarState();
}

class _OrderSearchBarState extends State<OrderSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    // Only dispose if we created the controller internally
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {}); // Rebuild to update suffixIcon visibility
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(ResponsiveUtil.spacing(
        mobile: 16,
        tablet: 18,
        desktop: 20,
      )),
      child: TextField(
        controller: _controller,
        decoration: InputDecoration(
          hintText: 'Search by order number...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    widget.onSearch('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        onChanged: widget.onSearch,
      ),
    );
  }
}
