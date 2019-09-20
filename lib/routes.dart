import 'package:expensetracker/login_page.dart';
import 'package:expensetracker/home_page.dart';
import 'package:expensetracker/categories_page.dart';
import 'package:expensetracker/charts_page.dart';
import 'package:expensetracker/summary_page.dart';
import 'package:expensetracker/settings_page.dart';
import 'package:expensetracker/search_page.dart';
import 'package:expensetracker/search_result_page.dart';
import 'package:expensetracker/budgetexpensemap_page.dart';
import 'package:expensetracker/pdfreport_page.dart';
 
final routes = {
  '/': (context) => new HomePage(context),
  '/login': (context) => new LoginPage(),
  '/categories': (context) => new CategoriesScreen(context),
  '/charts': (context) => new ChartScreen(),
  '/summary': (context) => new SummaryScreen(),
  '/settings': (context) => new SettingsPage(),
  '/searchpage': (context) => new SearchPage(),
  '/searchresult': (context) => new SearchResultPage(),
  '/budgetexpensemap': (context) => new BudgetExpenseMapScreen(context),
  '/report': (context) => new PdfReportPage()
};