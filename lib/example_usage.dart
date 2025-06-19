// // Example of how to use the new Clean Architecture structure
// // This file demonstrates the usage patterns for the implemented features

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// // Import the new Clean Architecture components
// import 'core/di/injection_container.dart' as di;
// import 'features/auth/presentation/blocs/auth_bloc.dart';
// import 'features/products/presentation/blocs/product_bloc.dart';
// import 'core/extensions/context_extensions.dart';

// class ExampleUsage extends StatelessWidget {
//   const ExampleUsage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         BlocProvider<AuthBloc>(
//           create: (context) => di.sl<AuthBloc>()..add(CheckAuthStatusEvent()),
//         ),
//         BlocProvider<ProductBloc>(
//           create: (context) => di.sl<ProductBloc>()..add(GetProductsEvent()),
//         ),
//       ],
//       child: const ExampleScreen(),
//     );
//   }
// }

// class ExampleScreen extends StatelessWidget {
//   const ExampleScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Clean Architecture Example'),
//       ),
//       body: Column(
//         children: [
//           // Authentication Section
//           BlocConsumer<AuthBloc, AuthState>(
//             listener: (context, state) {
//               if (state is AuthError) {
//                 context.showErrorSnackBar(state.message);
//               } else if (state is AuthAuthenticated) {
//                 context.showSuccessSnackBar('Welcome ${state.user.fullName}!');
//               }
//             },
//             builder: (context, state) {
//               if (state is AuthLoading) {
//                 return const CircularProgressIndicator();
//               } else if (state is AuthAuthenticated) {
//                 return Card(
//                   child: ListTile(
//                     leading: const Icon(Icons.person),
//                     title: Text(state.user.fullName),
//                     subtitle: Text(state.user.email),
//                     trailing: state.user.isAdmin
//                         ? const Chip(
//                             label: Text('Admin'),
//                             backgroundColor: Colors.red,
//                           )
//                         : null,
//                   ),
//                 );
//               } else {
//                 return ElevatedButton(
//                   onPressed: () {
//                     // Example login
//                     context.read<AuthBloc>().add(
//                           const LoginEvent(
//                             email: 'user@example.com',
//                             password: 'password123',
//                           ),
//                         );
//                   },
//                   child: const Text('Login'),
//                 );
//               }
//             },
//           ),
          
//           const SizedBox(height: 20),
          
//           // Products Section
//           Expanded(
//             child: BlocBuilder<ProductBloc, ProductState>(
//               builder: (context, state) {
//                 if (state is ProductLoading) {
//                   return const Center(child: CircularProgressIndicator());
//                 } else if (state is ProductLoaded) {
//                   return ListView.builder(
//                     itemCount: state.products.length,
//                     itemBuilder: (context, index) {
//                       final product = state.products[index];
//                       return Card(
//                         child: ListTile(
//                           leading: product.primaryImageUrl != null
//                               ? Image.network(
//                                   product.primaryImageUrl!,
//                                   width: 50,
//                                   height: 50,
//                                   fit: BoxFit.cover,
//                                 )
//                               : const Icon(Icons.image),
//                           title: Text(product.name),
//                           subtitle: Text('\$${product.effectivePrice}'),
//                           trailing: product.hasDiscount
//                               ? Chip(
//                                   label: Text(
//                                     '${product.discountPercentage.toInt()}% OFF',
//                                   ),
//                                   backgroundColor: Colors.green,
//                                 )
//                               : null,
//                         ),
//                       );
//                     },
//                   );
//                 } else if (state is ProductError) {
//                   return Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(Icons.error, size: 48, color: Colors.red),
//                         const SizedBox(height: 16),
//                         Text(state.message),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             context.read<ProductBloc>().add(GetProductsEvent());
//                           },
//                           child: const Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//                 return const SizedBox.shrink();
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Example of how to initialize the dependency injection
// class AppInitializer {
//   static Future<void> initialize() async {
//     // Initialize dependency injection
//     await di.init();
    
//     // Any other initialization code...
//   }
// }

// // Example of how to use validators
// class ExampleForm extends StatefulWidget {
//   @override
//   _ExampleFormState createState() => _ExampleFormState();
// }

// class _ExampleFormState extends State<ExampleForm> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           TextFormField(
//             controller: _emailController,
//             decoration: const InputDecoration(labelText: 'Email'),
//             validator: (value) => Validators.validateEmail(value),
//           ),
//           TextFormField(
//             controller: _passwordController,
//             decoration: const InputDecoration(labelText: 'Password'),
//             obscureText: true,
//             validator: (value) => Validators.validatePassword(value),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 // Form is valid, proceed with submission
//                 context.read<AuthBloc>().add(
//                       LoginEvent(
//                         email: _emailController.text,
//                         password: _passwordController.text,
//                       ),
//                     );
//               }
//             },
//             child: const Text('Submit'),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // Note: You'll need to import the validators and other components
// // This is just a demonstration of usage patterns
