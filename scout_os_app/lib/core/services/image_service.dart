import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../network/api_dio_provider.dart';

/// Senior Flutter Architect & Backend Specialist Implementation
/// ImageService untuk ImageKit CDN handling dengan optimization dan error handling
class ImageService {
  static final ImageService _instance = ImageService._internal();
  factory ImageService() => _instance;
  ImageService._internal();

  // ImageKit Configuration
  static const String _imageKitBaseUrl = 'https://ik.imagekit.io/l4q0qxxp9';
  static const String _imageKitEndpoint = '/api/v1/users/me/avatar';

  final Dio _dio = ApiDioProvider.getDio();

  /// Get optimized ImageKit URL for user avatar
  String getOptimizedAvatarUrl(
    String? avatarPath, {
    int? width,
    int? height,
    int quality = 80,
    String format = 'auto',
    String crop = 'crop',
    String focus = 'auto',
  }) {
    if (avatarPath == null || avatarPath.isEmpty) {
      return '';
    }

    // If it's already a full URL, optimize it
    if (avatarPath.startsWith('http')) {
      return _optimizeImageUrl(
        avatarPath,
        width,
        height,
        quality,
        format,
        crop,
        focus,
      );
    }

    // If it's a relative path, construct full ImageKit URL
    final fullUrl = '$_imageKitBaseUrl$avatarPath';
    return _optimizeImageUrl(
      fullUrl,
      width,
      height,
      quality,
      format,
      crop,
      focus,
    );
  }

  /// Optimize ImageKit URL with transformations
  String _optimizeImageUrl(
    String url,
    int? width,
    int? height,
    int quality,
    String format,
    String crop,
    String focus,
  ) {
    if (!url.contains('ik.imagekit.io')) {
      return url; // Not an ImageKit URL, return as-is
    }

    final transformations = <String>[];

    if (width != null) transformations.add('w-$width');
    if (height != null) transformations.add('h-$height');
    transformations.add('q-$quality');
    if (format != 'auto') transformations.add('f-$format');
    transformations.add('c-$crop');
    transformations.add('fo-$focus');

    final transformationString = transformations.join(',');

    // Add transformation to URL
    if (url.contains('?')) {
      final parts = url.split('?');
      return '${parts[0]}?tr=$transformationString&${parts[1]}';
    } else {
      return '$url?tr=$transformationString';
    }
  }

  /// Upload avatar to ImageKit via backend
  Future<String?> uploadAvatar(String filePath) async {
    try {
      debugPrint('🔵 [IMAGE_SERVICE] Uploading avatar: $filePath');

      final formData = FormData.fromMap({
        'avatar': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post(_imageKitEndpoint, data: formData);

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final avatarUrl = data['avatar_url'] as String?;

        debugPrint(
          '✅ [IMAGE_SERVICE] Avatar uploaded successfully: $avatarUrl',
        );
        return avatarUrl;
      }

      return null;
    } on DioException catch (e) {
      debugPrint('❌ [IMAGE_SERVICE] Upload failed: ${e.message}');
      if (e.response?.statusCode == 413) {
        throw ImageUploadException('File too large. Maximum size is 5MB.');
      } else if (e.response?.statusCode == 415) {
        throw ImageUploadException(
          'Invalid file format. Please use JPG, PNG, or WebP.',
        );
      } else if (e.response?.statusCode == 401) {
        throw ImageUploadException(
          'Authentication required. Please login again.',
        );
      }
      throw ImageUploadException('Upload failed: ${e.message}');
    } catch (e) {
      debugPrint('❌ [IMAGE_SERVICE] Unexpected error: $e');
      throw ImageUploadException('Upload failed: $e');
    }
  }

  /// Delete avatar from ImageKit via backend
  Future<bool> deleteAvatar() async {
    try {
      debugPrint('🔵 [IMAGE_SERVICE] Deleting avatar...');

      final response = await _dio.delete(_imageKitEndpoint);

      if (response.statusCode == 200) {
        debugPrint('✅ [IMAGE_SERVICE] Avatar deleted successfully');
        return true;
      }

      return false;
    } on DioException catch (e) {
      debugPrint('❌ [IMAGE_SERVICE] Delete failed: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('❌ [IMAGE_SERVICE] Unexpected error: $e');
      return false;
    }
  }

  /// Get avatar URL with fallback to default
  String getAvatarUrlWithFallback(
    String? avatarPath, {
    int? width,
    int? height,
    int quality = 80,
  }) {
    final optimizedUrl = getOptimizedAvatarUrl(
      avatarPath,
      width: width,
      height: height,
      quality: quality,
    );

    // Return optimized URL if available, otherwise return default
    if (optimizedUrl.isNotEmpty) {
      return optimizedUrl;
    }

    // Return default avatar URL
    return getDefaultAvatarUrl(width: width, height: height);
  }

  /// Get default avatar URL
  String getDefaultAvatarUrl({int? width, int? height}) {
    final defaultPath = '/default-avatar.png';
    return getOptimizedAvatarUrl(defaultPath, width: width, height: height);
  }

  /// Validate image file
  bool isValidImageFile(String filePath) {
    final validExtensions = ['jpg', 'jpeg', 'png', 'webp', 'gif'];
    final extension = filePath.split('.').last.toLowerCase();

    return validExtensions.contains(extension);
  }

  /// Get image file size in MB
  Future<double> getImageFileSize(String filePath) async {
    try {
      final file = await Dio().head(filePath);
      final contentLength = file.headers.value('content-length');

      if (contentLength != null) {
        final bytes = int.parse(contentLength);
        return bytes / (1024 * 1024); // Convert to MB
      }

      return 0.0;
    } catch (e) {
      debugPrint('❌ [IMAGE_SERVICE] Failed to get file size: $e');
      return 0.0;
    }
  }

  /// Preload image for better performance
  Future<void> preloadImage(String imageUrl) async {
    try {
      await Dio().get(imageUrl);
      debugPrint('✅ [IMAGE_SERVICE] Image preloaded: $imageUrl');
    } catch (e) {
      debugPrint('⚠️ [IMAGE_SERVICE] Failed to preload image: $e');
    }
  }

  /// Generate placeholder avatar URL with user initials
  String generatePlaceholderAvatarUrl(
    String name, {
    int? width,
    int? height,
    String backgroundColor = '4F46E5',
    String textColor = 'FFFFFF',
  }) {
    final initials = _getInitials(name);
    final size = width ?? height ?? 200;

    // Using a placeholder service like UI Avatars
    return 'https://ui-avatars.com/api/?name=${initials.split('').join('+')}&size=$size&background=$backgroundColor&color=$textColor&bold=true';
  }

  /// Get initials from name
  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty) {
      return parts[0][0].toUpperCase();
    }
    return '?';
  }

  /// Create optimized thumbnail URL
  String createThumbnailUrl(String imageUrl, {int size = 150}) {
    return getOptimizedAvatarUrl(
      imageUrl,
      width: size,
      height: size,
      quality: 75,
      crop: 'crop',
      focus: 'auto',
    );
  }

  /// Create banner URL
  String createBannerUrl(String imageUrl, {int width = 800, int height = 200}) {
    return getOptimizedAvatarUrl(
      imageUrl,
      width: width,
      height: height,
      quality: 85,
      crop: 'fill',
      focus: 'auto',
    );
  }
}

/// Custom exception for image upload errors
class ImageUploadException implements Exception {
  final String message;

  const ImageUploadException(this.message);

  @override
  String toString() => 'ImageUploadException: $message';
}

/// Image optimization presets
class ImagePresets {
  /// Avatar preset for profile pictures
  static String avatar({double size = 40.0}) {
    return 'w-${(size * 2).toInt()},h-${(size * 2).toInt()},q-80,c-crop,fo-auto,f-auto';
  }

  /// Thumbnail preset for galleries
  static String thumbnail({int size = 150}) {
    return 'w-$size,h-$size,q-75,c-crop,fo-auto,f-auto';
  }

  /// Banner preset for headers
  static String banner({int width = 800, int height = 200}) {
    return 'w-$width,h-$height,q-85,c-fill,fo-auto,f-auto';
  }

  /// High quality preset for detailed images
  static String highQuality({int width = 1200, int height = 800}) {
    return 'w-$width,h-$height,q-90,f-auto';
  }

  /// Low quality preset for placeholders
  static String lowQuality({int width = 300, int height = 300}) {
    return 'w-$width,h-$height,q-60,f-auto';
  }
}
