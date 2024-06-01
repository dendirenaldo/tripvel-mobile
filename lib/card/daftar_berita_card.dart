import 'package:cached_network_image/cached_network_image.dart';
import 'package:tripvel/page/berita.dart';
import 'package:flutter/material.dart';

class DaftarBeritaCard extends StatelessWidget {
  final int id;
  final String title;
  final String deskripsi;
  final String thumbnail;
  final String authorName;
  final String authorImage;

  const DaftarBeritaCard({
    super.key,
    required this.id,
    required this.title,
    required this.deskripsi,
    required this.thumbnail,
    required this.authorName,
    required this.authorImage,
  });

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width - 50;

    return InkWell(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => BeritaPage(id: id, thumbnail: thumbnail))),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: authorImage,
                    placeholder: (BuildContext context, String url) => const CircularProgressIndicator(),
                    errorWidget: (BuildContext context, String url, dynamic error) => const Icon(Icons.error, size: 25),
                    width: 25,
                    height: 25,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  child: Text(
                    authorName,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                    textScaleFactor: 1.0,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(),
                  width: width / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        deskripsi,
                        style: const TextStyle(fontSize: 10, height: 1.7),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8))),
                  clipBehavior: Clip.hardEdge,
                  child: Hero(
                    tag: "berita$id",
                    child: Material(
                      child: CachedNetworkImage(
                        imageUrl: thumbnail,
                        placeholder: (BuildContext context, String url) => const CircularProgressIndicator(),
                        errorWidget: (BuildContext context, String url, dynamic error) => Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: const [
                            Icon(Icons.error),
                            SizedBox(height: 5),
                            Text(
                              'Image not loaded',
                              style: TextStyle(fontSize: 10),
                              textScaleFactor: 1.0,
                            )
                          ],
                        ),
                        width: width / 2,
                        height: (width / 2) * 9 / 16,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
