import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoryProvider with ChangeNotifier {
  List<dynamic> categories = [];
  List<dynamic> tags = [];
  List<dynamic> medias = [];
  List<dynamic> searchedCategories = [];
  List<dynamic> searchedTags = [];
  bool fromCategory = false;
  final categorySearchController = TextEditingController();
  final postSearchController = TextEditingController();
  final tagSearchController = TextEditingController();
  String error = '';
  List<dynamic> posts = [];
  List<String> allPostsSlugFromMedia = [];
  List<dynamic> searchedPosts = [];
  int selectedPostId = 0;
  String selectedCategoryName = '';
  String selectedTagName = '';
  Map<String, dynamic> post = <String, dynamic>{};
  int page = 1;
  int count = 0;
  bool _isLoading = false; // Added loading state

  bool get isLoading => _isLoading; // Getter for loading state

  int selectedCategoryId = 0;
  int selectedTagId = 0;

  static const String siteUrl = "https://wbxpress.com/wp-json/wp/v2/";

  // Utility methods begins
  void _handleError(dynamic e) {
    _isLoading = true;
    error = 'Check your Internet Connection & tap refresh!';
    notifyListeners();
  }

  void _handleSuccess() {
    _isLoading = false;
    error = '';
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getPdfMediaForPost(int postId) async {
    const String baseUrl = '${siteUrl}media';
    final String url = '$baseUrl?parent=$postId&mime_type=application/pdf';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Parse the JSON response
        List<dynamic> data =
            response.body.isEmpty ? [] : json.decode(response.body);

        // Extract necessary information (e.g., URL, title, etc.)
        List<Map<String, dynamic>> pdfMedia = List<Map<String, dynamic>>.from(
          data.map((media) => {
                'url': media['source_url'],
                'title': media['title']['rendered'],
                // Add more properties as needed
              }),
        );

        return pdfMedia;
      } else {
        // If the request fails, print the error status code
        print('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (error) {
      // Handle exceptions
      print('Error: $error');
      return [];
    }
  }

  // Utility methods ends

  Future<void> fetchTags({List<dynamic>? newTags, int page = 1}) async {
    try {
      // Set loading state to true
      _isLoading = true;
      notifyListeners();

      // Initialize newTags if null
      newTags ??= [];

      while (true) {
        final response = await _getTagsFromApi(page);

        if (response.statusCode == 200) {
          var fetchedTags = json.decode(response.body);
          newTags.addAll(fetchedTags);

          if (fetchedTags.length == 99) {
            page++; // Increment page for the next request
          } else {
            tags = newTags;
            fetchCategories();
            _handleSuccess();
            break; // Exit the loop when all tags are fetched
          }
        } else {
          throw Exception('Failed to load categories');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<http.Response> _getTagsFromApi(int page) {
    return http.get(
      Uri.parse('${siteUrl}tags?page=$page&per_page=99'),
    );
  }

  Future<void> fetchCategories(
      {List<dynamic>? newCategories, int page = 1}) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();
      newCategories ??= [];

      while (true) {
        final response = await _getCategoriesFromApi(page);

        if (response.statusCode == 200) {
          var fetchedCategories = json.decode(response.body);
          newCategories.addAll(fetchedCategories);
          if (fetchedCategories.length == 99) {
            print(page);
            page++; // Increment page for the next request
          } else {
            categories = newCategories;
            _handleSuccess();
            break; // Exit the loop when all categories are fetched
          }
        } else {
          throw Exception('Failed to load categories');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<http.Response> _getCategoriesFromApi(int page) {
    return http.get(
      Uri.parse('${siteUrl}categories?page=$page&per_page=99'),
    );
  }

  Future<void> fetchPostsInCategory(int categoryId,
      {int selectedPage = 1}) async {
    try {
      _isLoading = true; // Set loading state to true
      page = selectedPage;
      notifyListeners();

      final response =
          await _getPostsByCategoryFromApi(categoryId, selectedPage);
      if (response.statusCode == 200) {
        List<dynamic> newPosts = json.decode(response.body);
        posts = newPosts;
        _handleSuccess();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<http.Response> _getPostsByCategoryFromApi(
      int categoryId, int selectedPage) {
    return http.get(
      Uri.parse(
          '${siteUrl}posts?categories=$categoryId&page=$selectedPage&per_page=20'),
    );
  }

  Future<void> fetchPostsInTag(int tagId, {int selectedPage = 1}) async {
    try {
      _isLoading = true; // Set loading state to true
      page = selectedPage;
      notifyListeners();

      final response = await _getPostsByTagFromApi(tagId, selectedPage);

      if (response.statusCode == 200) {
        List<dynamic> newPosts = json.decode(response.body);
        posts = newPosts;
        _handleSuccess();
      } else {
        throw Exception('Failed to load posts');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<http.Response> _getPostsByTagFromApi(int tagId, int selectedPage) {
    return http.get(
      Uri.parse('${siteUrl}posts?tags=$tagId&page=$selectedPage&per_page=20'),
    );
  }

  Future<void> fetchPost(int postId) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();

      final response = await _getPostFromApi(postId);
      if (response.statusCode == 200) {
        Map<String, dynamic> newPost = json.decode(response.body);
        post = newPost;
        _handleSuccess();
      } else {
        throw Exception('Failed to load post');
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<http.Response> _getPostFromApi(int postId) {
    const String baseURL = '${siteUrl}posts';
    final Uri uri = Uri.parse('$baseURL/$postId');
    return http.get(uri);
  }

  Future<void> searchCategories(String searchTerm,
      {int selectedSearchedPage = 1, List<dynamic>? newCategories}) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();

      const String baseURL = '${siteUrl}categories';
      List<dynamic> categories = newCategories ?? [];

      while (true) {
        final response = await http.get(
          Uri.parse(
              '$baseURL?search=$searchTerm&page=$selectedSearchedPage&per_page=99'),
        );

        if (response.statusCode == 200) {
          var tempSearchedCategories = json.decode(response.body);
          categories.addAll(tempSearchedCategories);

          if (tempSearchedCategories.length == 99) {
            selectedSearchedPage++;
          } else {
            searchedCategories = categories;
            _handleSuccess();
            break;
          }
        } else {
          throw Exception('Failed to load categories');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> searchTags(String searchTerm,
      {int selectedSearchedPage = 1, List<dynamic>? newTags}) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();

      const String baseURL = '${siteUrl}tags';
      List<dynamic> tags = newTags ?? [];

      while (true) {
        final response = await http.get(
          Uri.parse(
              '$baseURL?search=$searchTerm&page=$selectedSearchedPage&per_page=99'),
        );

        if (response.statusCode == 200) {
          var tempSearchedTags = json.decode(response.body);
          tags.addAll(tempSearchedTags);

          if (tempSearchedTags.length == 99) {
            selectedSearchedPage++;
          } else {
            searchedTags = tags;
            _handleSuccess();
            break;
          }
        } else {
          throw Exception('Failed to load tags');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> searchPostsInCategory(String searchTerm, int categoryId,
      {int selectedSearchedPage = 1, List<dynamic>? newCategoryPosts}) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();

      const String baseURL = '${siteUrl}posts?categories';
      List<dynamic> categoryPosts = newCategoryPosts ?? [];

      while (true) {
        final response = await http.get(
          Uri.parse(
            '$baseURL=$categoryId&search=$searchTerm&page=$selectedSearchedPage&per_page=99',
          ),
        );

        if (response.statusCode == 200) {
          var tempSearchedPostsInCategory = json.decode(response.body);
          categoryPosts.addAll(tempSearchedPostsInCategory);

          if (tempSearchedPostsInCategory.length == 99) {
            selectedSearchedPage++;
          } else {
            searchedPosts = categoryPosts;
            _handleSuccess();
            break;
          }
        } else {
          throw Exception('Failed to load posts');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> searchPostsInTag(String searchTerm, int tagId,
      {int selectedSearchedPage = 1, List<dynamic>? newTagPosts}) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();

      const String baseURL = '${siteUrl}posts?tags';
      List<dynamic> tagPosts = newTagPosts ?? [];

      while (true) {
        final response = await http.get(
          Uri.parse(
            '$baseURL=$tagId&search=$searchTerm&page=$selectedSearchedPage&per_page=99',
          ),
        );

        if (response.statusCode == 200) {
          var tempSearchedPostsInTags = json.decode(response.body);
          tagPosts.addAll(tempSearchedPostsInTags);

          if (tempSearchedPostsInTags.length == 99) {
            selectedSearchedPage++;
          } else {
            searchedPosts = tagPosts;
            _handleSuccess();
            break;
          }
        } else {
          throw Exception('Failed to load posts');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  Future<void> searchPosts(String searchTerm,
      {int selectedSearchedPage = 1, List<dynamic>? newPosts}) async {
    try {
      _isLoading = true; // Set loading state to true
      notifyListeners();

      const String baseURL = '${siteUrl}search?';
      List<dynamic> fetchedPosts = newPosts ?? [];

      while (true) {
        final response = await http.get(
          Uri.parse(
            '${baseURL}search=$searchTerm&page=$selectedSearchedPage',
          ),
        );

        if (response.statusCode == 200) {
          var tempSearchedPosts = json.decode(response.body);

          for (int j = 0; j < tempSearchedPosts.length; j++) {
            if (tempSearchedPosts[j]["subtype"] == 'post') {
              final response2 =
                  await _getPostFromApi(tempSearchedPosts[j]["id"]);

              if (response2.statusCode == 200) {
                fetchedPosts.add(json.decode(response2.body));
              }
            }
          }

          searchedPosts = fetchedPosts;
          _handleSuccess();
          break;
        } else {
          throw Exception('Failed to load posts');
        }
      }
    } catch (e) {
      _handleError(e);
    }
  }

  String? findMatchingUrl(String text) {
    RegExp urlExp = RegExp(r'(?:(?:https?|ftp):\/\/|www\.)[^\s/$.?#].[^\s]*');
    RegExp patternExp = RegExp(r'No[:.]\s*(\d+-[A-Z])');

    Iterable<Match> urlMatches = urlExp.allMatches(text);
    List<String> urls = urlMatches.map((match) => match.group(0)!).toList();

    Match? patternMatch = patternExp.firstMatch(text);

    if (patternMatch != null) {
      String documentNo = patternMatch.group(1)!;

      for (String url in urls) {
        if (url.contains(documentNo) &&
            url.startsWith('https://wbxpress.com/files/')) {
          return url;
        }
      }
    }

    return null;
  }

  void launchPDF(String pdfUrl) async {
    final Uri uri = Uri.parse(pdfUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not launch $pdfUrl';
    }
  }

  Future<void> downloadPDF(String pdfUrl) async {
    //You can download a single file
    Uri uri = Uri.parse(pdfUrl);
    List<String> pathSegments = uri.pathSegments;
    await FileDownloader.downloadFile(
        url: pdfUrl,
        name: pathSegments.last, //THE FILE NAME AFTER DOWNLOADING,
        downloadDestination: DownloadDestinations.publicDownloads,
        onDownloadCompleted: (String path) {
          print('FILE DOWNLOADED TO PATH: $path');
        },
        onDownloadError: (String error) {
          print('DOWNLOAD ERROR: $error');
        });
  }

  CategoryProvider() {
    page = 1;
    fetchTags();
  }
}
