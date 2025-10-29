import 'package:flutter/material.dart';

import '../../data/models/photo_gallery_item.dart';
import 'photo_grid_item.dart';

class PhotoGrid extends StatelessWidget {
  final List<PhotoGalleryItem> photos;
  final Function(PhotoGalleryItem) onPhotoTap;

  const PhotoGrid({
    super.key,
    required this.photos,
    required this.onPhotoTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
        childAspectRatio: 1,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return PhotoGridItem(
          photo: photo,
          onTap: () => onPhotoTap(photo),
        );
      },
    );
  }
}

