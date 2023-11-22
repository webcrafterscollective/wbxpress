import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:wbxpress/util/utils.dart';
import '../providers/category_provider.dart';

class PostContentView extends StatefulWidget {
  const PostContentView({super.key});

  @override
  State<PostContentView> createState() => _PostContentViewState();
}

class _PostContentViewState extends State<PostContentView>
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
        .fetchPost(
      Provider.of<CategoryProvider>(context, listen: false).selectedPostId,
    )
        .then((_) {
      _controller.reset(); // Reset the animation when fetching is done
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 32,
                  )),
            ),
            const Expanded(
              child: ZoomableWidget(child: PostWidget()),
            ),
          ],
        ),
      ),
    );
  }
}

class PostWidget extends StatelessWidget {
  const PostWidget({
    super.key,
  });

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

      return GestureDetector(
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 10.0),
          child: ListView(children: [
            ListTile(
              title: HtmlWidget(
                categoryProvider.post['title']['rendered'],
                textStyle: GoogleFonts.raleway(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF0F0F0F),
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 18.0),
                child: HtmlWidget(
                  categoryProvider.post['content']['rendered'],
                  textStyle: GoogleFonts.raleway(
                    fontSize: 16,
                    color: const Color(0xFF183D3D),
                    wordSpacing: 4,
                    height: 1.5,
                  ),
                  customStylesBuilder: (element) {
                    if (element.classes.contains('wp-block-table')) {
                      return {
                        'overflow-x': 'auto',
                        'white-space': 'nowrap',
                        'border-collapse': 'collapse',
                        'width': '100%',
                        'padding': '0',
                        'margin': '0',
                      };
                    }

                    if (element.localName == 'table') {
                      return {
                        'display': 'table',
                        'box-sizing': 'border-box',
                        'text-indent': 'initial',
                        'border-color': 'gray',
                        'border-collapse': 'collapse',
                        'width': '100%',
                        'border': '1px solid',
                        'padding': '0',
                        'margin': '0',
                      };
                    }

                    if (element.localName == 'td') {
                      return {
                        'border': '1px solid',
                        'padding': '4px',
                      };
                    }

                    return null;
                  },
                  onTapUrl: (url) async {
                    return await nowlaunchUrl(
                      Uri.parse(url),
                    );
                  },
                ),
              ),
            ),
          ]),
        ),
      );
    });
  }
}
