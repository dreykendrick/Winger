import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../../shared/design_system/tokens/design_tokens.dart';
import '../../domain/entities/product_media.dart';

class MediaGallery extends StatefulWidget {
  final List<ProductMedia> mediaList;

  const MediaGallery({super.key, required this.mediaList});

  @override
  State<MediaGallery> createState() => _MediaGalleryState();
}

class _MediaGalleryState extends State<MediaGallery> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mediaList.isEmpty) {
      return Container(
        height: 280,
        color: Colors.grey.shade100,
        child: const Icon(Icons.image_not_supported_outlined,
            size: 64, color: Colors.grey),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.mediaList.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) {
              return CachedNetworkImage(
                imageUrl: widget.mediaList[index].url,
                fit: BoxFit.cover,
                placeholder: (context, url) =>
                    Container(color: Colors.grey.shade200),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey.shade100,
                  child: const Icon(Icons.broken_image_outlined,
                      size: 48, color: Colors.grey),
                ),
              );
            },
          ),
        ),
        if (widget.mediaList.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.mediaList.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentIndex == index ? 16 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentIndex == index
                      ? WingerTokens.primaryEmerald
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
