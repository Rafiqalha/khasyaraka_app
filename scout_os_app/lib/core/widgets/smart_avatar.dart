import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Senior Flutter Architect & Backend Specialist Implementation
/// SmartAvatar widget dengan ImageKit optimization dan error handling
class SmartAvatar extends StatefulWidget {
  final String? imageUrl;
  final double size;
  final String? name;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BoxFit fit;
  final ImageKitTransformation? transformation;

  const SmartAvatar({
    Key? key,
    this.imageUrl,
    this.size = 40.0,
    this.name,
    this.placeholder,
    this.errorWidget,
    this.fit = BoxFit.cover,
    this.transformation,
  }) : super(key: key);

  @override
  State<SmartAvatar> createState() => _SmartAvatarState();
}

class _SmartAvatarState extends State<SmartAvatar> {
  bool _hasError = false;
  String? _optimizedUrl;

  @override
  void initState() {
    super.initState();
    _optimizedUrl = _getOptimizedImageUrl();
  }

  @override
  void didUpdateWidget(SmartAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      setState(() {
        _hasError = false;
        _optimizedUrl = _getOptimizedImageUrl();
      });
    }
  }

  /// Get optimized ImageKit URL with transformations
  String? _getOptimizedImageUrl() {
    if (widget.imageUrl == null || widget.imageUrl!.isEmpty) {
      return null;
    }

    String url = widget.imageUrl!;

    // Check if it's already an ImageKit URL
    if (url.contains('ik.imagekit.io')) {
      // Apply ImageKit transformations
      if (widget.transformation != null) {
        final transformation = widget.transformation!;

        // Build transformation string
        final transformations = <String>[];

        if (transformation.width != null) {
          transformations.add('w-${transformation.width}');
        }
        if (transformation.height != null) {
          transformations.add('h-${transformation.height}');
        }
        if (transformation.crop != null) {
          transformations.add('c-${transformation.crop}');
        }
        if (transformation.quality != null) {
          transformations.add('q-${transformation.quality}');
        }
        if (transformation.format != null) {
          transformations.add('f-${transformation.format}');
        }
        if (transformation.focus != null) {
          transformations.add('fo-${transformation.focus}');
        }
        if (transformation.radius != null) {
          transformations.add('r-${transformation.radius}');
        }
        if (transformation.blur != null) {
          transformations.add('bl-${transformation.blur}');
        }
        if (transformation.brightness != null) {
          transformations.add('b-${transformation.brightness}');
        }
        if (transformation.contrast != null) {
          transformations.add('co-${transformation.contrast}');
        }
        if (transformation.saturation != null) {
          transformations.add('s-${transformation.saturation}');
        }

        if (transformations.isNotEmpty) {
          final transformationString = transformations.join(',');

          // Insert transformation into URL
          if (url.contains('?')) {
            url =
                '${url.split('?')[0]}?tr=$transformationString&${url.split('?')[1]}';
          } else {
            url = '$url?tr=$transformationString';
          }
        }
      }

      return url;
    }

    // For non-ImageKit URLs, return as-is
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError || _optimizedUrl == null) {
      return _buildErrorOrPlaceholder();
    }

    return Container(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: CachedNetworkImage(
          imageUrl: _optimizedUrl!,
          fit: widget.fit,
          width: widget.size,
          height: widget.size,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) {
            // Mark as error and rebuild
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() => _hasError = true);
              }
            });
            return _buildErrorWidget();
          },
          memCacheWidth: (widget.size * 2).toInt(),
          memCacheHeight: (widget.size * 2).toInt(),
        ),
      ),
    );
  }

  Widget _buildErrorOrPlaceholder() {
    return Container(
      width: widget.size,
      height: widget.size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size / 2),
        child: _hasError ? _buildErrorWidget() : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor.withOpacity(0.8),
            Theme.of(context).primaryColor.withOpacity(0.6),
          ],
        ),
      ),
      child: Center(
        child: widget.name != null
            ? Text(
                _getInitials(widget.name!),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: widget.size * 0.4,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Icon(
                Icons.person,
                size: widget.size * 0.6,
                color: Colors.white.withOpacity(0.8),
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Center(
        child: Icon(
          Icons.broken_image,
          size: widget.size * 0.5,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }
}

/// ImageKit transformation configuration
class ImageKitTransformation {
  final int? width;
  final int? height;
  final ImageKitCrop? crop;
  final int? quality;
  final ImageKitFormat? format;
  final ImageKitFocus? focus;
  final int? radius;
  final int? blur;
  final int? brightness;
  final int? contrast;
  final int? saturation;

  const ImageKitTransformation({
    this.width,
    this.height,
    this.crop,
    this.quality = 80,
    this.format = ImageKitFormat.auto,
    this.focus = ImageKitFocus.auto,
    this.radius,
    this.blur,
    this.brightness,
    this.contrast,
    this.saturation,
  });

  /// Create optimized transformation for avatar
  factory ImageKitTransformation.avatar({
    double size = 40.0,
    int quality = 80,
  }) {
    return ImageKitTransformation(
      width: (size * 2).toInt(), // 2x for retina displays
      height: (size * 2).toInt(),
      quality: quality,
      crop: ImageKitCrop.crop,
      focus: ImageKitFocus.auto,
      format: ImageKitFormat.auto,
    );
  }

  /// Create optimized transformation for banner
  factory ImageKitTransformation.banner({
    double width = 300,
    double height = 150,
    int quality = 75,
  }) {
    return ImageKitTransformation(
      width: width.toInt(),
      height: height.toInt(),
      quality: quality,
      crop: ImageKitCrop.crop,
      focus: ImageKitFocus.auto,
      format: ImageKitFormat.auto,
    );
  }
}

/// ImageKit crop modes
enum ImageKitCrop {
  crop,
  resize,
  pad,
  fill,
  pad_resize,
  min_resize,
  force,
  at_max,
}

/// ImageKit output formats
enum ImageKitFormat { auto, jpg, png, webp, avif }

/// ImageKit focus points
enum ImageKitFocus {
  auto,
  left,
  right,
  top,
  bottom,
  center,
  top_left,
  top_right,
  bottom_left,
  bottom_right,
}

/// Convenience widget for avatar with default optimization
class OptimizedAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? name;

  const OptimizedAvatar({Key? key, this.imageUrl, this.size = 40.0, this.name})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SmartAvatar(
      imageUrl: imageUrl,
      size: size,
      name: name,
      transformation: ImageKitTransformation.avatar(size: size),
    );
  }
}
