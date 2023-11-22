import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

Widget searchBar(TextEditingController searchController, String hintText,
    {required Function() onSearch, required void Function() onClear}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0),
      child: TextField(
        textInputAction: TextInputAction.done,
        controller: searchController,
        focusNode: FocusNode(), // Optional: For automatic focus
        style: GoogleFonts.crimsonText(fontSize: 18),
        onChanged: (value) {
          if (value.isNotEmpty) {
            onSearch.call();
          } else {
            onClear.call();
          }
        },
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              searchController.clear();
              onClear.call();
            },
          ),
          prefixIcon: IconButton(
            icon: const Icon(Icons.search),
            onPressed: onSearch,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
        ),
      ),
    ),
  );
}

class ZoomableWidget extends StatefulWidget {
  final Widget child;

  const ZoomableWidget({super.key, required this.child});

  @override
  State<ZoomableWidget> createState() => _ZoomableWidgetState();
}

class _ZoomableWidgetState extends State<ZoomableWidget> {
  double scale = 1.0;
  double previousScale = 1.0;

  void onScaleStart(ScaleStartDetails details) {
    previousScale = scale;
  }

  void onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      scale = previousScale * details.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: onScaleStart,
      onScaleUpdate: onScaleUpdate,
      child: Transform.scale(
        scale: scale,
        child: widget.child,
      ),
    );
  }
}

Future<bool> nowlaunchUrl(Uri url) async {
  // Assuming launchUrl is a function from some external library
  if (await launchUrl(
    url,
    mode: LaunchMode.inAppWebView,
    webViewConfiguration: const WebViewConfiguration(enableDomStorage: false),
  )) {
    return true; // Return true if the navigation was successful
  } else {
    throw Exception('Could not launch $url');
  }
}

TextStyle titleTextStyle(BuildContext context) {
  double fontSize = 16;

  if (MediaQuery.of(context).size.width > 1200) {
    // Extra large device - desktop
    fontSize = 24;
  } else if (MediaQuery.of(context).size.width > 800) {
    // Large device - tablet
    fontSize = 22;
  } else if (MediaQuery.of(context).size.width > 500) {
    // Medium device
    fontSize = 18;
  } else {
    // Small device - phone
    fontSize = 16;
  }

  return GoogleFonts.raleway(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF0F0F0F),
  );
}

TextStyle excerptTextStyle(BuildContext context) {
  double fontSize = 16;

  if (MediaQuery.of(context).size.width > 1200) {
    // Extra large device - desktop
    fontSize = 22;
  } else if (MediaQuery.of(context).size.width > 800) {
    // Large device - tablet
    fontSize = 18;
  } else if (MediaQuery.of(context).size.width > 500) {
    // Medium device
    fontSize = 16;
  } else {
    // Small device - phone
    fontSize = 14;
  }

  return GoogleFonts.raleway(
    fontSize: fontSize,
     fontWeight: FontWeight.w400,
    color: const Color(0xFF183D3D),
    wordSpacing: 4,
    height: 1.5,
  );
}

TextStyle headingTextStyle(BuildContext context) {
  double fontSize = 24;

  if (MediaQuery.of(context).size.width > 1200) {
    // Extra large device - desktop
    fontSize = 30;
  } else if (MediaQuery.of(context).size.width > 800) {
    // Large device - tablet
    fontSize = 28;
  } else if (MediaQuery.of(context).size.width > 500) {
    // Medium device
    fontSize = 26;
  } else {
    // Small device - phone
    fontSize = 24;
  }

  return GoogleFonts.ralewayDots(
    fontSize: fontSize,
    fontWeight: FontWeight.bold,
    color: const Color(0xFF0F0F0F),
  );
}
