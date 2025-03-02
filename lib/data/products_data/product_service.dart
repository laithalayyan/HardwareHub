import 'product_model.dart';

class ProductService {
  static List<Product> getProducts() {
    return [
      Product(
        id: 'prod1',
        name: 'Stepper Motor Nema 23',
        category: 'Motors',
        imageUrl: 'assets/images/products/nike-shoes.png',
        price: 150.0,
        inStock: true,
        description: 'High torque stepper motor Nema 23, perfect for robotics and CNC machines.',
        stockQuantity : 10,
      ),
      Product(
        id: 'prod2',
        name: 'Stepper Motor Nema 34',
        category: 'Motors',
        imageUrl: 'assets/images/products/nike-shoes.png',
        price: 200.0,
        inStock: true,
        description: 'High torque stepper motor Nema 23, perfect for robotics and CNC machines.',
        stockQuantity : 10,
      ),
      Product(
        id: 'prod3',
        name: 'DC Motor 12V',
        category: 'Motors',
        imageUrl: 'assets/images/products/nike-shoes.png',
        price: 120.0,
        inStock: true,
        description: 'High torque stepper motor Nema 23, perfect for robotics and CNC machines.',
        stockQuantity : 10,
      ),
      Product(
        id: 'prod4',
        name: 'Servo Motor MG995',
        category: 'Motors',
        imageUrl: 'assets/images/products/nike-shoes.png',
        price: 180.0,
        inStock: true,
        description: 'High torque stepper motor Nema 23, perfect for robotics and CNC machines.',
        stockQuantity : 10,
      ),
    ];
  }
}
