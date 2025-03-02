import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../services/supabase_service.dart';
import 'order_confirmation_page.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({Key? key}) : super(key: key);

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  String _paymentMethod = 'Credit Card';
  
  final List<String> _paymentMethods = [
    'Credit Card', 
    'PayPal', 
    'Apple Pay', 
    'Google Pay'
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    super.dispose();
  }
  
  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      
      // Get user profile data
      final userProfile = await supabaseService.getUserProfile();
      
      // Pre-fill form with user data if available
      if (userProfile.isNotEmpty) {
        setState(() {
          _nameController.text = userProfile['full_name'] ?? '';
          _emailController.text = userProfile['email'] ?? '';
          _phoneController.text = userProfile['phone'] ?? '';
          _addressController.text = userProfile['address'] ?? '';
          _cityController.text = userProfile['city'] ?? '';
          _stateController.text = userProfile['state'] ?? '';
          _zipController.text = userProfile['zip'] ?? '';
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      
      // Create shipping address string
      final shippingAddress = '${_addressController.text}, ${_cityController.text}, ${_stateController.text} ${_zipController.text}';
      
      // Create order data
      final orderData = {
        'id': 'order_${DateTime.now().millisecondsSinceEpoch}',
        'created_at': DateTime.now().toIso8601String(),
        'status': 'Processing',
        'total_amount': cartProvider.totalAmount,
        'shipping_address': shippingAddress,
        'payment_method': _paymentMethod,
        'customer_name': _nameController.text,
        'customer_email': _emailController.text,
        'customer_phone': _phoneController.text,
        'items': cartProvider.items.entries.map((entry) {
          return {
            'product_id': entry.key,
            'name': entry.value.name,
            'quantity': entry.value.quantity,
            'price': entry.value.price,
            'image_url': entry.value.imageUrl,
          };
        }).toList(),
      };
      
      // Create the order in the database
      final createdOrder = await supabaseService.createOrder(orderData);
      
      // Clear the cart
      cartProvider.clear();
      
      // Navigate to order confirmation page
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => OrderConfirmationPage(orderData: createdOrder),
          ),
        );
      }
    } catch (e) {
      print('Error placing order: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error placing order: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Checkout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOrderSummary(cartProvider),
                    const SizedBox(height: 24),
                    _buildShippingForm(),
                    const SizedBox(height: 24),
                    _buildPaymentMethod(),
                    const SizedBox(height: 32),
                    _buildPlaceOrderButton(),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...cartProvider.items.entries.map((entry) {
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(item.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '${item.quantity} x \$${item.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Shipping',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Free',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildShippingForm() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Shipping Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@') || !value.contains('.')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your city';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _zipController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPaymentMethod() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Payment Method',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _paymentMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.payment),
              ),
              items: _paymentMethods.map((method) {
                IconData icon;
                switch (method) {
                  case 'Credit Card':
                    icon = Icons.credit_card;
                    break;
                  case 'PayPal':
                    icon = Icons.account_balance_wallet;
                    break;
                  case 'Apple Pay':
                    icon = Icons.apple;
                    break;
                  case 'Google Pay':
                    icon = Icons.g_mobiledata;
                    break;
                  default:
                    icon = Icons.payment;
                }
                
                return DropdownMenuItem<String>(
                  value: method,
                  child: Row(
                    children: [
                      Icon(icon, size: 20),
                      const SizedBox(width: 8),
                      Text(method),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            if (_paymentMethod == 'Credit Card')
              Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: 'Card Number',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.credit_card),
                      hintText: '•••• •••• •••• ••••',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (_paymentMethod == 'Credit Card') {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your card number';
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date',
                            border: OutlineInputBorder(),
                            hintText: 'MM/YY',
                          ),
                          validator: (value) {
                            if (_paymentMethod == 'Credit Card') {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'CVV',
                            border: OutlineInputBorder(),
                            hintText: '•••',
                          ),
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          validator: (value) {
                            if (_paymentMethod == 'Credit Card') {
                              if (value == null || value.isEmpty) {
                                return 'Required';
                              }
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (_paymentMethod != 'Credit Card')
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      _paymentMethod == 'PayPal'
                          ? Icons.account_balance_wallet
                          : _paymentMethod == 'Apple Pay'
                              ? Icons.apple
                              : Icons.g_mobiledata,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'You will be redirected to $_paymentMethod to complete your payment.',
                      style: TextStyle(
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPlaceOrderButton() {
    final cartProvider = Provider.of<CartProvider>(context);
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: cartProvider.items.isEmpty || _isLoading ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Place Order - \$${cartProvider.totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
} 