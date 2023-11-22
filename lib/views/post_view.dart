import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wbxpress/util/utils.dart';
import 'package:http/http.dart' as http;

import '../providers/category_provider.dart';
import 'pdf_viewer.dart';

class PostView extends StatefulWidget {
  const PostView({super.key});

  @override
  State<PostView> createState() => _PostViewState();
}

class _PostViewState extends State<PostView>
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
        .fetchPostsInCategory(
            Provider.of<CategoryProvider>(context, listen: false)
                .selectedCategoryId,
            selectedPage:
                Provider.of<CategoryProvider>(context, listen: false).page)
        .then((_) {
      _controller.reset(); // Reset the animation when fetching is done
    });
  }

  @override
  Widget build(BuildContext context) {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: true);
    final postSearchController =
        Provider.of<CategoryProvider>(context, listen: true)
            .postSearchController;
    final selectedCategoryId =
        Provider.of<CategoryProvider>(context, listen: true).selectedCategoryId;
    final selectedTagId =
        Provider.of<CategoryProvider>(context, listen: true).selectedTagId;
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
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(

                      Icons.chevron_left,
                      size: 30,
                    )),
                Image.asset("assets/images/logo.png", width: 30),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(top: 18.0),
              child: searchBar(
                postSearchController,
                'Search by post title..',
                onSearch: () {
                   Provider.of<CategoryProvider>(context, listen: false).searchPosts(postSearchController.text);
                },
                onClear: () {
                  Provider.of<CategoryProvider>(context, listen: false)
                          .fromCategory
                      ? Provider.of<CategoryProvider>(context, listen: false)
                          .fetchPostsInCategory(Provider.of<CategoryProvider>(
                                  context,
                                  listen: false)
                              .selectedCategoryId)
                      : Provider.of<CategoryProvider>(context, listen: false)
                          .fetchPostsInTag(selectedTagId);
                },
              ),
            ),
            postSearchController.text.isEmpty && categoryProvider.error.isEmpty
                ? SizedBox(
                    height: 75,
                    child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: Provider.of<CategoryProvider>(context,
                                listen: false)
                            .count,
                        itemBuilder: (context, index) {
                          return PaginationWidget(
                            pageNumber: index + 1,
                            onTap: () {
                              Provider.of<CategoryProvider>(context,
                                          listen: false)
                                      .fromCategory
                                  ? Provider.of<CategoryProvider>(context,
                                          listen: false)
                                      .fetchPostsInCategory(
                                      Provider.of<CategoryProvider>(context,
                                              listen: false)
                                          .selectedCategoryId,
                                      selectedPage: index + 1,
                                    )
                                  : Provider.of<CategoryProvider>(context,
                                          listen: false)
                                      .fetchPostsInTag(
                                      Provider.of<CategoryProvider>(context,
                                              listen: false)
                                          .selectedTagId,
                                      selectedPage: index + 1,
                                    );
                            },
                          );
                        }),
                  )
                : const SizedBox(),
            Expanded(
              child: CategoryPostsListWidget(
                  isSearchingTrue: postSearchController.text.isNotEmpty),
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryPostsListWidget extends StatelessWidget {
  const CategoryPostsListWidget({
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

      return ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: isSearchingTrue
            ? categoryProvider.searchedPosts.length
            : categoryProvider.posts.length,
        itemBuilder: (context, index) {
          List<dynamic> posts = [];
          posts = isSearchingTrue
              ? categoryProvider.searchedPosts
              : categoryProvider.posts;

          return Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 6.0, vertical: 32.0),
            child: FutureBuilder(
                future: categoryProvider.getPdfMediaForPost(posts[index]["id"]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const LinearProgressIndicator(); // Show a loader while waiting for data
                  }

                  if (snapshot.hasError) {
                    return const SizedBox(
                      height: 0,
                      width: 0,
                    ); // Show an error message if there's an error
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Visibility(
                      visible: false,
                      child: Center(
                        child: Text("No data"),
                      ),
                    );
                  }
                  // print(posts[index]["title"]["rendered"]);
                  // print(snapshot.data!.length);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 15),
                        title: HtmlWidget(
                          posts[index]['title']['rendered'],
                          textStyle: titleTextStyle(context),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 18.0),
                          child: HtmlWidget(
                            posts[index]['excerpt']['rendered'],
                            textStyle: GoogleFonts.raleway(
                              fontSize: 16,
                              color: const Color(0xFF183D3D),
                              wordSpacing: 4,
                              height: 1.5,
                            ),
                            onTapUrl: (url) async {
                              return await nowlaunchUrl(
                                Uri.parse(url),
                              );
                            },
                          ),
                        ),
                      ),
                      for (var data in snapshot.data!)
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 15, right: 15, top: 20),
                          child: OutlinedButton.icon(
                              onPressed: () async {
                                // URL of the file to be downloaded

                                var fileUrl = data["url"];

                                // Extracting file name from URL
                                try {
                                  // Fetching the file and downloading it
                                  await http
                                      .get(Uri.parse(fileUrl))
                                      .then((value) {
                                    if (value.statusCode == 200) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PDFViewer(value, fileUrl),
                                        ),
                                      );
                                    } else {
                                      print(
                                          'Failed to download file. Error: ${value.statusCode}');
                                    }
                                  });
                                } catch (e) {
                                  print(e);
                                }
                              },
                              icon: const Icon(Icons.download),
                              label: Text(
                                data["title"],
                                style: GoogleFonts.libreFranklin(
                                  fontSize: 16,
                                  color: const Color(0xFF183D3D),
                                  wordSpacing: 4,
                                ),
                              )),
                        ),
                    ],
                  );
                }),
          );
        },
      );
    });
  }
}

class PaginationWidget extends StatelessWidget {
  const PaginationWidget({
    super.key,
    required this.pageNumber,
    required this.onTap,
  });

  final int pageNumber;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    bool selected =
        Provider.of<CategoryProvider>(context, listen: true).page == pageNumber;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: InkWell(
        splashColor: Colors.transparent,
        highlightColor: Colors.amber,
        onTap: () {
          onTap.call();
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            border: Border.all(width: 1.0, color: Colors.black),
          ),
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: selected ? Colors.black : Colors.white,
            ),
            child: Text(
              pageNumber.toString(),
              style: TextStyle(color: selected ? Colors.white : Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}
