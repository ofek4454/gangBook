import 'dart:io';

import 'package:cloudinary_sdk/cloudinary_sdk.dart';
import 'package:gangbook/private_keys.dart';

class CloudinaryRequests {
  Cloudinary cloudinary =
      Cloudinary(CLOYDINARY_API_KEY, CLOUDINARY_PRIVATE_KEY, 'gangbook');

  Future<String> uploadUserProfileImage(File image, String uid) async {
    final response = await cloudinary.uploadFile(
      filePath: image.path,
      resourceType: CloudinaryResourceType.image,
      folder: 'users/$uid',
      fileName: uid,
    );
    if (response.isSuccessful)
      return response.secureUrl;
    else
      return null;
  }

  Future<String> uploadGangImage(File image, String gangId) async {
    final response = await cloudinary.uploadFile(
      filePath: image.path,
      resourceType: CloudinaryResourceType.image,
      folder: 'gangs/$gangId',
      fileName: gangId,
    );
    if (response.isSuccessful)
      return response.secureUrl;
    else
      return null;
  }

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

  Future<String> deleteImage(String url) async {
    final response = await cloudinary.deleteFile(url: url);
    if (response.isResultOk)
      return 'success';
    else
      return 'error';
  }
}
