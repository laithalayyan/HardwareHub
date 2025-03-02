/*import 'package:get/get.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../data/project_data/project_model.dart';

class WishlistController extends GetxController {
  var favoriteProducts = <Product>[].obs;
  var favoriteProjects = <Project>[].obs;

  // Check if a product is favorite
  bool isFavorite(String productId) {
    return favoriteProducts.any((product) => product.id == productId);
  }

  // Check if a project is favorite
  bool isFavoriteProject(String projectId) {
    return favoriteProjects.any((project) => project.id == projectId);
  }

  // Toggle favorite product
  void toggleFavorite(Product product) {
    if (isFavorite(product.id)) {
      favoriteProducts.removeWhere((p) => p.id == product.id);
    } else {
      favoriteProducts.add(product);
    }
  }

  // Toggle favorite project
  void toggleFavoriteProject(Project project) {
    if (isFavoriteProject(project.id)) {
      favoriteProjects.removeWhere((p) => p.id == project.id);
    } else {
      favoriteProjects.add(project);
    }
  }
}
*/

import 'package:get/get.dart';
import '../../../../data/products_data/product_model.dart';
import '../../../../data/project_data/project_model.dart';

class WishlistController extends GetxController {
  // Use separate Maps to store favorite status for products and projects
  final RxMap<String, bool> _favoriteProducts = <String, bool>{}.obs;
  final RxMap<String, bool> _favoriteProjects = <String, bool>{}.obs;

  // Use separate lists to store favorite products and projects for the UI
  final RxList<Product> favoriteProducts = <Product>[].obs;
  final RxList<Project> favoriteProjects = <Project>[].obs;

  // Check if a product is favorite
  bool isFavoriteProduct(String productId) {
    return _favoriteProducts[productId] ?? false;
  }

  // Check if a project is favorite
  bool isFavoriteProject(String projectId) {
    return _favoriteProjects[projectId] ?? false;
  }

  // Toggle favorite product
  void toggleFavoriteProduct(Product product) {
    if (_favoriteProducts.containsKey(product.id)) {
      _favoriteProducts[product.id] = !_favoriteProducts[product.id]!;
    } else {
      _favoriteProducts[product.id] = true;
    }

    // Update the favoriteProducts list
    if (_favoriteProducts[product.id] == true) {
      favoriteProducts.add(product);
    } else {
      favoriteProducts.removeWhere((p) => p.id == product.id);
    }

    update(); // Notify listeners
  }

  // Toggle favorite project
  void toggleFavoriteProject(Project project) {
    if (_favoriteProjects.containsKey(project.id)) {
      _favoriteProjects[project.id] = !_favoriteProjects[project.id]!;
    } else {
      _favoriteProjects[project.id] = true;
    }

    // Update the favoriteProjects list
    if (_favoriteProjects[project.id] == true) {
      favoriteProjects.add(project);
    } else {
      favoriteProjects.removeWhere((p) => p.id == project.id);
    }

    update(); // Notify listeners
  }
}