import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/category_provider.dart';
import '../util/utils.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
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
    Provider.of<CategoryProvider>(context, listen: false).fetchTags().then((_) {
      _controller.reset(); // Reset the animation when fetching is done
    });
  }

  @override
  Widget build(BuildContext context) {
    final tagSearchController =
        Provider.of<CategoryProvider>(context, listen: true)
            .tagSearchController;
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
                      context.go('/category');
                    },
                    child: Row(

                      children: [
                        Text(
                          'Departments',
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
            //     tagSearchController,
            //     'Search by subject ...',
            //     onSearch: () {
            //       Provider.of<CategoryProvider>(context, listen: false)
            //           .searchTags(tagSearchController.text);
            //     },
            //     onClear: () {
            //       Provider.of<CategoryProvider>(context, listen: false)
            //           .fetchTags();
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
                    'Subjects',
                    style: headingTextStyle(context),
                  ),
                   Text(
                    'Scroll to view available subjects',
                    style: excerptTextStyle(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TagsChipWrapWidget(
                isSearchingTrue: tagSearchController.text.isNotEmpty,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TagsChipWrapWidget extends StatelessWidget {
  const TagsChipWrapWidget({
    this.isSearchingTrue = false,
    super.key,
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
              style: const TextStyle(
                fontSize: 18,
              ),
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
            ? categoryProvider.searchedTags.length
            : categoryProvider.tags.length, // Total number of cards
        itemBuilder: (BuildContext context, int index) {
          final tags = isSearchingTrue
              ? categoryProvider.searchedTags
              : categoryProvider.tags;
          return GestureDetector(
            onTap: () {
              int pageCount = tags[index]['count'] ~/ 20;
              pageCount = pageCount + (tags[index]['count'] % 20 == 0 ? 0 : 1);
              Provider.of<CategoryProvider>(context, listen: false)
                  .fromCategory = false;
              Provider.of<CategoryProvider>(context, listen: false).count =
                  pageCount;
              Provider.of<CategoryProvider>(context, listen: false)
                  .selectedTagId = tags[index]['id'];
              Provider.of<CategoryProvider>(context, listen: false)
                  .fetchPostsInTag(tags[index]['id']);
              Provider.of<CategoryProvider>(context, listen: false)
                        .selectedTagName =
                    tags[index]['name'];

              context.go('/post');
            },
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 6.0, vertical: 12.0),
              child: Column(
                children: [
                  ListTile(
                    title: HtmlWidget(
                      (tags[index]['name']),
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
