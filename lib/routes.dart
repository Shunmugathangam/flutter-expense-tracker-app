import 'package:expensetracker/home_page.dart';
import 'package:expensetracker/categories_page.dart';
 
final routes = {
  '/': (context) => new HomePage(context),
  '/categories': (context) => new CategoriesScreen(context),
};