import 'dart:io';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:gangbook/private_keys.dart';

class CloudinaryRequests {
  Cloudinary cloudinary =
      Cloudinary(CLOYDINARY_API_KEY, CLOUDINARY_PRIVATE_KEY, 'gangbook');

  Future<String> uploadPhoto(
      {File image, String gangId, String postId, String fileName}) async {
    final response = await cloudinary.uploadFile(
      filePath: image.path,
      resourceType: CloudinaryResourceType.image,
      folder: 'gangs/$gangId/posts/$postId/',
      fileName: fileName,
    );
    if (response.isSuccessful)
      return response.secureUrl;
    else
      return null;
  }

  Future<String> uploadVideo(
      {File video, String gangId, String postId, String fileName}) async {
    final response = await cloudinary.uploadFile(
      filePath: video.path,
      resourceType: CloudinaryResourceType.video,
      folder: 'gangs/$gangId/posts/$postId/',
      fileName: fileName,
    );
    if (response.isSuccessful)
      return response.secureUrl;
    else
      return null;
  }
}
