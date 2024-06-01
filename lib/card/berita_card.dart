import 'package:flutter/material.dart';
import 'package:tripvel/page/berita.dart';

class BeritaCard extends StatelessWidget {
  final int id;
  final String title;
  final String deskripsi;
  final String thumbnail;
  final String authorName;
  final String authorImage;

  const BeritaCard({
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
    return Container(
      width: 218,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(11)),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.65),
      ),
      child: Material(
        clipBehavior: Clip.hardEdge,
        borderRadius: const BorderRadius.all(Radius.circular(11)),
        child: InkWell(
          onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (context) => BeritaPage(id: id, thumbnail: thumbnail))),
          child: Ink(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Column(
              children: [
                Hero(
                  tag: "berita$id",
                  child: Material(
                    child: Image.network(
                      thumbnail,
                      errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: const [
                          Icon(Icons.error),
                          SizedBox(height: 5),
                          Text(
                            'Image not loaded',
                            style: TextStyle(fontSize: 10),
                          )
                        ],
                      ),
                      width: 218,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          ClipOval(
                            child: Image.network(
                              authorImage,
                              errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) => const Icon(Icons.error, size: 13),
                              width: 13,
                              height: 13,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(authorName, style: const TextStyle(fontSize: 8)),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(deskripsi, style: const TextStyle(fontSize: 10), maxLines: 2),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
