import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gizmoglobe_client/screens/product/edit_product/edit_product_view.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_cubit.dart';
import 'package:gizmoglobe_client/screens/product/product_detail/product_detail_state.dart';
import 'package:gizmoglobe_client/widgets/general/gradient_icon_button.dart';
import 'package:intl/intl.dart';

import '../../../enums/processing/process_state_enum.dart';
import '../../../enums/product_related/product_status_enum.dart';
import '../../../objects/product_related/product.dart';
import '../../../widgets/dialog/information_dialog.dart';
import '../../../data/database/database.dart';
import '../../../enums/stakeholders/employee_role.dart';
import '../../../widgets/general/status_badge.dart';
import '../../../widgets/general/gradient_text.dart';


class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  static Widget newInstance(Product product) =>
      BlocProvider(
        create: (context) => ProductDetailCubit(product),
        child: ProductDetailScreen(product: product),
      );

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductDetailCubit get cubit => context.read<ProductDetailCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) => GradientIconButton(
            icon: Icons.chevron_left,
            onPressed: () => {
              if (widget.product != state.product) {
                Navigator.pop(context, ProcessState.success)
              } else {
                Navigator.pop(context, state.processState)
              }
            },
            fillColor: Colors.transparent,
          ),
        ),
        actions: const [
          // IconButton(
          //   icon: Icon(Icons.share),
          //   onPressed: () {
          //     // Implement share functionality
          //   },
          // ),
          // IconButton(
          //   icon: Icon(Icons.favorite_border),
          //   onPressed: () {
          //     // Implement wishlist functionality
          //   },
          // ),
        ],
        title: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) => GradientText(
            text: state.product.productName,
          ),
        ),
      ),
      body: BlocBuilder<ProductDetailCubit, ProductDetailState>(
        builder: (context, state) {
          return Stack(
            children: [
              // Main content in SingleChildScrollView
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image Section - smaller size
                    Container(
                      height: MediaQuery.of(context).size.height * 0.25,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                      ),
                      child: Image.network(
                        'https://ramleather.vn/wp-content/uploads/2022/07/woocommerce-placeholder-200x200-1.jpg',
                        fit: BoxFit.contain,
                      ),
                    ),
                    
                    // Product Info Section
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Basic Information Section
                          Text(
                            'Basic Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[300],
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          _buildInfoRow(
                            icon: Icons.inventory_2,
                            title: 'Product',
                            value: state.product.productName,
                          ),
                          
                          _buildInfoRow(
                            icon: Icons.category,
                            title: 'Category',
                            value: state.product.category.toString().split('.').last,
                          ),
                          
                          _buildInfoRow(
                            icon: Icons.business,
                            title: 'Manufacturer',
                            value: state.product.manufacturer.manufacturerName,
                          ),
                          
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              children: [
                                Icon(Icons.circle, size: 20, color: Colors.grey[500]),
                                const SizedBox(width: 8),
                                const Text(
                                  'Status: ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                StatusBadge(status: state.product.status),
                              ],
                            ),
                          ),
                          
                          // Thêm thông tin về giá và discount
                          _buildPriceSection(
                            sellingPrice: state.product.sellingPrice,
                            discount: state.product.discount,
                          ),
                          
                          SizedBox(height: 24),
                          
                          // Status Information Section
                          Text(
                            'Status Information',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[300],
                            ),
                          ),
                          SizedBox(height: 16),
                          
                          Row(
                            children: [
                              StatusBadge(status: state.product.status),
                              const SizedBox(width: 16),
                              Icon(
                                state.product.stock > 0 ? Icons.check_circle : Icons.error,
                                color: state.product.stock > 0 ? Colors.green : Colors.red,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Stock: ${state.product.stock}',
                                style: TextStyle(
                                  color: state.product.stock > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          _buildInfoRow(
                            icon: Icons.calendar_today,
                            title: 'Release Date',
                            value: DateFormat('dd/MM/yyyy').format(state.product.release),
                          ),
                          const SizedBox(height: 24),
                          
                          // Technical Specifications Section
                          Text(
                            'Technical Specifications',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[300],
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          ..._buildProductSpecificDetails(context, state.product, state.technicalSpecs),

                          const SizedBox(height: 16),
                          // Add padding at bottom to prevent content from being hidden behind buttons
                          const SizedBox(height: 80), // Height for the bottom buttons
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Sticky footer with buttons
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: BlocConsumer<ProductDetailCubit, ProductDetailState>(
                    listener: (context, state) {
                      if (state.processState == ProcessState.success) {
                        showDialog(
                            context: context,
                            builder:  (context) =>
                                InformationDialog(
                                  title: state.dialogName.toString(),
                                  content: state.notifyMessage.toString(),
                                  onPressed: () {},
                                )
                        );
                      } else if (state.processState == ProcessState.failure) {
                        showDialog(
                            context: context,
                            builder:  (context) =>
                                InformationDialog(
                                  title: state.dialogName.toString(),
                                  content: state.notifyMessage.toString(),
                                  onPressed: () {
                                    cubit.toIdle();
                                  },
                                )
                        );
                      }
                    },
                    builder: (context, state) => FutureBuilder<bool>(
                      future: Database().isUserAdmin(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data == true) {
                          return Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    ProcessState processState = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditProductScreen.newInstance(state.product),
                                      ),
                                    );

                                    if (processState == ProcessState.success) {
                                      cubit.updateProduct();
                                    }
                                  },
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  label: const Text('Edit', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    cubit.toLoading();
                                    cubit.changeProductStatus();
                                  },
                                  icon: Icon(
                                    state.product.status == ProductStatusEnum.discontinued
                                        ? Icons.refresh
                                        : Icons.cancel,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    state.product.status == ProductStatusEnum.discontinued
                                        ? 'Re-activate'
                                        : 'Discontinue',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.product.status == ProductStatusEnum.discontinued
                                        ? Colors.blue
                                        : Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }
                        return Container();
                      },
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatusChip(dynamic status) {
    // Xác định màu sắc dựa trên status
    Color chipColor;
    Color textColor;
    
    switch(status.toString().toLowerCase()) {
      case 'active':
        chipColor = Colors.green.withOpacity(0.1);
        textColor = Colors.green;
        break;
      case 'discontinued':
        chipColor = Colors.red.withOpacity(0.1);
        textColor = Colors.red;
        break;
      case 'pending':
        chipColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        break;
      default:
        chipColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        status.toString(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[500]),
          SizedBox(width: 8),
          Text(
            '$title: ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildProductSpecificDetails(
    BuildContext context, 
    Product product,
    Map<String, String> specs
  ) {
    return specs.entries.map((entry) => 
      _buildSpecificationRow(entry.key, entry.value)
    ).toList();
  }

  Widget _buildSpecificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection({
    required double sellingPrice,
    required double discount,
  }) {
    final discountedPrice = sellingPrice * (1 - discount);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(Icons.attach_money, size: 20, color: Colors.grey[500]),
          SizedBox(width: 8),
          Text(
            'Price: ',
            style: TextStyle(
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          if (discount > 0) ...[
            Text(
              '\$${sellingPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w400,
                decoration: TextDecoration.lineThrough,
                fontSize: 14,
              ),
            ),
            SizedBox(width: 8),
            Text(
              '\$${discountedPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green[300],
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '-${(discount * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.red[300],
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ] else
            Text(
              '\$${sellingPrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
        ],
      ),
    );
  }
}