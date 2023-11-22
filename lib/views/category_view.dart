import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wbxpress/util/utils.dart';

import '../providers/category_provider.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    _controller.repeat(); // Start the animation
    Provider.of<CategoryProvider>(context, listen: false)
        .fetchCategories()
        .then((_) {
      _controller.reset(); // Reset the animation when fetching is done
    });
  }

  @override
  Widget build(BuildContext context) {
    final categorySearchController =
        Provider.of<CategoryProvider>(context, listen: true)
            .categorySearchController;
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          onPressed: _startAnimation,
          child: RotationTransition(
            turns: Tween(begin: 0.0, end: 1.0).animate(_controller),
            child: const Icon(Icons.refresh),
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 18.0),
                    child: Image.asset(
                      "assets/images/logo.png",
                      width: 36,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.go('/');
                    },
                    child: Row(

                      children: [
                        Text(
                          'Subjects',
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0F0F0F),
                          ),
                        ),
                        const Icon(
                          color: Color(0xFF0F0F0F),
                          Icons.chevron_right,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Padding(
            //   padding: const EdgeInsets.only(top: 18.0),
            //   child: searchBar(
            //     categorySearchController,
            //     'Search by department..',
            //     onSearch: () {
            //       Provider.of<CategoryProvider>(context, listen: false)
            //           .searchCategories(categorySearchController.text);
            //     },
            //     onClear: () {
            //       Provider.of<CategoryProvider>(context, listen: false)
            //           .fetchCategories();
            //     },
            //   ),
            // ),
             Container(
              padding: const EdgeInsets.only(top: 18.0, bottom: 8.0),
              margin: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20),
              
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Departments',
                    style: headingTextStyle(context),
                  ),
                  Text(
                    'Scroll to view available departments',
                    style: excerptTextStyle(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: CategoryListWidget(
                isSearchingTrue: categorySearchController.text.isNotEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryListWidget extends StatelessWidget {
  const CategoryListWidget({
    super.key,
    this.isSearchingTrue = false,
  });

  final bool isSearchingTrue;

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
      if (categoryProvider.isLoading || categoryProvider.error.isNotEmpty) {
        return Center(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              categoryProvider.error,
              style: titleTextStyle(context),
            ),
            const SizedBox(
              height: 20,
            ),
            const CircularProgressIndicator(),
          ],
        ));
      }

      return ListView.separated(
        separatorBuilder: (context, index) {
          return const Divider(
            thickness: 0.1,
            height: 0,
            color: Color(0xFF008170),
          );
        },
        scrollDirection: Axis.vertical,
        itemCount: isSearchingTrue
            ? categoryProvider.searchedCategories.length
            : categoryProvider.categories.length,
        itemBuilder: (context, index) {
          List<dynamic> categories = [];
          categories = isSearchingTrue
              ? categoryProvider.searchedCategories
              : categoryProvider.categories;

          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
            child: GestureDetector(
              onTap: () {
                int pageCount =
                    categoryProvider.categories[index]['count'] ~/ 20;
                pageCount = pageCount +
                    (categoryProvider.categories[index]['count'] % 20 == 0
                        ? 0
                        : 1);
                Provider.of<CategoryProvider>(context, listen: false)
                    .fromCategory = true;
                Provider.of<CategoryProvider>(context, listen: false).count =
                    pageCount;
                Provider.of<CategoryProvider>(context, listen: false)
                        .selectedCategoryId =
                    categoryProvider.categories[index]['id'];
                 Provider.of<CategoryProvider>(context, listen: false)
                        .selectedCategoryName =
                    categoryProvider.categories[index]['name'];
                Provider.of<CategoryProvider>(context, listen: false)
                    .fetchPostsInCategory(
                        categoryProvider.categories[index]['id']);

                context.go('/post');
              },
              child: Column(
                children: [
                  ListTile(
                    title: HtmlWidget(
                      categories[index]['name'],
                      textStyle: titleTextStyle(context),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
