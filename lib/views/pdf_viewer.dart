import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';

import '../util/file_downloader.dart';

class PDFViewer extends StatelessWidget {
  final Response response;
  final String fileUrl;

  PDFViewer(this.response, this.fileUrl, {super.key});
  final fileDownloader = FileDownloader();

  @override
  Widget build(BuildContext context) {
    final fileNameWithExtension = fileUrl.split('/').last;
    final fileNameWithoutExtension = fileNameWithExtension.split('.').first;
    return SafeArea(
      child: Scaffold(
        body: FutureBuilder(
          future: fileDownloader.downloadFileLocally(
              response, fileNameWithoutExtension),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData) {
              return const Center(
                child: Text('No data available'),
              );
            }

            final filePath = snapshot.data as String; // Retrieve the file path

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.chevron_left,
                    size: 30,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        color: Colors.black,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(),
                    
                          Text(
                        "$fileNameWithoutExtension.pdf Saved to Downloads/Wbxpress Folder",
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PDFView(
                    filePath: filePath,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
