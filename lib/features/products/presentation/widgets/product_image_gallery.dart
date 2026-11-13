import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImageGallery extends StatefulWidget {
  final List<String> imageUrls;

  const ProductImageGallery({super.key, required this.imageUrls});

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  late final PageController _pageController;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _preloadNearbyImages(_selectedIndex);
      }
    });
  }

  void _preloadNearbyImages(int index) {
    final indexes = [index - 1, index + 1];

    for (final imageIndex in indexes) {
      if (imageIndex < 0 || imageIndex >= widget.imageUrls.length) {
        continue;
      }

      final imageUrl = widget.imageUrls[imageIndex];

      if (imageUrl.isEmpty) continue;

      precacheImage(
        CachedNetworkImageProvider(imageUrl, maxWidth: 900, maxHeight: 900),
        context,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _openFullScreen(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _FullScreenProductImage(
          imageUrls: widget.imageUrls,
          initialIndex: index,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                itemCount: widget.imageUrls.length,
                onPageChanged: (index) {
                  setState(() => _selectedIndex = index);
                  _preloadNearbyImages(index);
                },
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _openFullScreen(index),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: CachedNetworkImage(
                        imageUrl: widget.imageUrls[index],
                        fit: BoxFit.contain,
                        width: double.infinity,

                        memCacheWidth: 900,
                        memCacheHeight: 900,
                        maxWidthDiskCache: 1200,
                        maxHeightDiskCache: 1200,

                        placeholder: (_, _) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (_, _, _) =>
                            const Icon(Icons.broken_image_outlined, size: 60),
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                right: 16,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedIndex + 1}/${widget.imageUrls.length}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              Positioned(
                right: 16,
                top: 12,
                child: IconButton.filledTonal(
                  onPressed: () => _openFullScreen(_selectedIndex),
                  icon: const Icon(Icons.fullscreen),
                ),
              ),
            ],
          ),
        ),

        if (widget.imageUrls.length > 1)
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.imageUrls.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedIndex == index;

                return GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 65,
                    margin: const EdgeInsets.symmetric(horizontal: 5),
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: widget.imageUrls[index],
                      fit: BoxFit.contain,

                      memCacheWidth: 200,
                      memCacheHeight: 200,
                      maxWidthDiskCache: 300,
                      maxHeightDiskCache: 300,

                      placeholder: (_, _) => const Center(
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),

                      errorWidget: (_, _, _) =>
                          const Icon(Icons.broken_image, size: 20),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _FullScreenProductImage extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const _FullScreenProductImage({
    required this.imageUrls,
    required this.initialIndex,
  });

  @override
  State<_FullScreenProductImage> createState() =>
      _FullScreenProductImageState();
}

class _FullScreenProductImageState extends State<_FullScreenProductImage> {
  late final PageController _controller;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('${_currentIndex + 1}/${widget.imageUrls.length}'),
      ),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return InteractiveViewer(
            minScale: 0.8,
            maxScale: 4,
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.imageUrls[index],
                fit: BoxFit.contain,
                memCacheWidth: 1600,
                memCacheHeight: 1600,
                placeholder: (_, _) => const CircularProgressIndicator(),
                errorWidget: (_, _, _) => const Icon(
                  Icons.broken_image,
                  color: Colors.white,
                  size: 60,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
