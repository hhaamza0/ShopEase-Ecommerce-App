import 'package:flutter/material.dart';

void main() {
  runApp(const EcommerceApp());
}

class Product {
  final int id;
  final String name;
  final String category;
  final double price;
  final String image;
  final String description;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.image,
    required this.description,
  });
}

const products = [
  Product(
    id: 1,
    name: 'Wireless Headphones',
    category: 'Electronics',
    price: 59.99,
    image: 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=800&q=80',
    description: 'Comfortable wireless headphones with clear sound and long battery life.',
  ),
  Product(
    id: 2,
    name: 'Smart Watch',
    category: 'Electronics',
    price: 89.99,
    image: 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?auto=format&fit=crop&w=800&q=80',
    description: 'Modern smartwatch with fitness tracking and a bright digital display.',
  ),
  Product(
    id: 3,
    name: 'Classic Sneakers',
    category: 'Fashion',
    price: 74.99,
    image: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
    description: 'Lightweight everyday sneakers designed for comfort and casual style.',
  ),
  Product(
    id: 4,
    name: 'Backpack',
    category: 'Fashion',
    price: 39.99,
    image: 'https://images.unsplash.com/photo-1553062407-98eeb64c6a62?auto=format&fit=crop&w=800&q=80',
    description: 'Durable backpack with a spacious interior for university and travel.',
  ),
  Product(
    id: 5,
    name: 'Desk Lamp',
    category: 'Home',
    price: 29.99,
    image: 'https://images.unsplash.com/photo-1507473885765-e6ed057f782c?auto=format&fit=crop&w=800&q=80',
    description: 'Minimal desk lamp that gives your workspace a clean modern look.',
  ),
  Product(
    id: 6,
    name: 'Coffee Maker',
    category: 'Home',
    price: 69.99,
    image: 'https://images.unsplash.com/photo-1517668808822-9ebb02f2a0e6?auto=format&fit=crop&w=800&q=80',
    description: 'Easy-to-use coffee maker for fresh coffee at home every morning.',
  ),
];

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  double get total => product.price * quantity;
}

class EcommerceApp extends StatefulWidget {
  const EcommerceApp({super.key});

  @override
  State<EcommerceApp> createState() => _EcommerceAppState();
}

class _EcommerceAppState extends State<EcommerceApp> {
  final List<CartItem> cart = [];
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  void addToCart(Product product) {
    setState(() {
      final index = cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        cart[index].quantity++;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  void increase(CartItem item) {
    setState(() => item.quantity++);
  }

  void decrease(CartItem item) {
    setState(() {
      if (item.quantity > 1) {
        item.quantity--;
      } else {
        cart.remove(item);
      }
    });
  }

  void remove(CartItem item) {
    setState(() => cart.remove(item));
  }

  double get subtotal => cart.fold(0, (sum, item) => sum + item.total);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'ShopEase',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5B4BDB)),
        scaffoldBackgroundColor: const Color(0xFFF7F7FB),
      ),
      home: HomePage(
        cart: cart,
        onAdd: addToCart,
        onOpenCart: () => navigatorKey.currentState!.push(
          MaterialPageRoute(
            builder: (_) => CartPage(
              cart: cart,
              onIncrease: increase,
              onDecrease: decrease,
              onRemove: remove,
              onCheckout: () {
                navigatorKey.currentState!.push(
                  MaterialPageRoute(
                    builder: (_) => ConfirmationPage(
                      total: subtotal,
                      itemCount: cart.fold(0, (s, i) => s + i.quantity),
                    ),
                  ),
                ).then((_) {
                  setState(() => cart.clear());
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final List<CartItem> cart;
  final void Function(Product) onAdd;
  final VoidCallback onOpenCart;

  const HomePage({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.onOpenCart,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedCategory = 'All';
  String search = '';

  List<Product> get filtered {
    return products.where((p) {
      final categoryMatch =
          selectedCategory == 'All' || p.category == selectedCategory;
      final searchMatch = p.name.toLowerCase().contains(search.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();
  }

  int get cartCount =>
      widget.cart.fold(0, (sum, item) => sum + item.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ShopEase',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        actions: [
          Stack(
            children: [
              IconButton(
                onPressed: widget.onOpenCart,
                icon: const Icon(Icons.shopping_bag_outlined),
              ),
              if (cartCount > 0)
                Positioned(
                  right: 5,
                  top: 5,
                  child: CircleAvatar(
                    radius: 9,
                    backgroundColor: Colors.red,
                    child: Text(
                      '$cartCount',
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const Text(
            'Find your favorites',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Discover products made for your everyday life.',
            style: TextStyle(color: Colors.grey, fontSize: 15),
          ),
          const SizedBox(height: 18),
          TextField(
            onChanged: (value) => setState(() => search = value),
            decoration: InputDecoration(
              hintText: 'Search for products...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Categories',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: ['All', 'Electronics', 'Fashion', 'Home'].map((cat) {
                final selected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Featured Products',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: .68,
            ),
            itemBuilder: (_, index) {
              final product = filtered[index];
              return ProductCard(
                product: product,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsPage(
                      product: product,
                      onAdd: widget.onAdd,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'product-${product.id}',
                child: Image.network(
                  product.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      const Center(child: Icon(Icons.image_not_supported)),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
              child: Text(
                product.name,
                maxLines: 2,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
              child: Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  final void Function(Product) onAdd;

  const ProductDetailsPage({
    super.key,
    required this.product,
    required this.onAdd,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  int quantity = 1;

  @override
  Widget build(BuildContext context) {
    final total = widget.product.price * quantity;

    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Hero(
              tag: 'product-${widget.product.id}',
              child: Image.network(
                widget.product.image,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 22),
          Text(
            widget.product.name,
            style: const TextStyle(fontSize: 27, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.product.price.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Description',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            widget.product.description,
            style: const TextStyle(fontSize: 15, color: Colors.black54, height: 1.5),
          ),
          const SizedBox(height: 22),
          const Text(
            'Quantity',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  if (quantity > 1) setState(() => quantity--);
                },
                icon: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text(
                  '$quantity',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton.filledTonal(
                onPressed: () => setState(() => quantity++),
                icon: const Icon(Icons.add),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed: () {
                for (int i = 0; i < quantity; i++) {
                  widget.onAdd(widget.product);
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Product added to cart')),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text('Add to Cart • \$${total.toStringAsFixed(2)}'),
            ),
          ),
        ],
      ),
    );
  }
}

class CartPage extends StatelessWidget {
  final List<CartItem> cart;
  final void Function(CartItem) onIncrease;
  final void Function(CartItem) onDecrease;
  final void Function(CartItem) onRemove;
  final VoidCallback onCheckout;

  const CartPage({
    super.key,
    required this.cart,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
    required this.onCheckout,
  });

  double get total => cart.fold(0, (sum, item) => sum + item.total);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: cart.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 14),
                  Text(
                    'Your cart is empty',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text('Add some products to continue.'),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = cart[index];
                      return Card(
                        elevation: 0,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  item.product.image,
                                  width: 82,
                                  height: 82,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 5),
                                    Text('\$${item.product.price.toStringAsFixed(2)}'),
                                    const SizedBox(height: 7),
                                    Row(
                                      children: [
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => onDecrease(item),
                                          icon: const Icon(Icons.remove_circle_outline),
                                        ),
                                        Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        IconButton(
                                          visualDensity: VisualDensity.compact,
                                          onPressed: () => onIncrease(item),
                                          icon: const Icon(Icons.add_circle_outline),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  IconButton(
                                    onPressed: () => onRemove(item),
                                    icon: const Icon(Icons.delete_outline),
                                  ),
                                  Text(
                                    '\$${item.total.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '\$${total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: onCheckout,
                          child: const Text('Confirm Order'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class ConfirmationPage extends StatelessWidget {
  final double total;
  final int itemCount;

  const ConfirmationPage({
    super.key,
    required this.total,
    required this.itemCount,
  });

  String get orderNumber => 'SE${DateTime.now().millisecondsSinceEpoch % 1000000}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Confirmation')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withOpacity(.12),
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'Order Confirmed!',
                style: TextStyle(fontSize: 29, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Thank you for shopping with ShopEase.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _InfoRow(label: 'Order Number', value: '#$orderNumber'),
                      const SizedBox(height: 12),
                      _InfoRow(label: 'Items', value: '$itemCount'),
                      const SizedBox(height: 12),
                      _InfoRow(
                        label: 'Total Price',
                        value: '\$${total.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 12),
                      const _InfoRow(
                        label: 'Delivery',
                        value: '2–4 Business Days',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
