//
//  PhotoManager.swift
//  DiveIntoPhotoLibrary
//
//  Created by Brook_Mobius on 2023/4/3.
//

import Foundation
import Photos

import Photos
import UIKit

class PhotoManager {
  static func requestAuthorization(
    handler: @escaping (PHAuthorizationStatus) -> Void
  ) {
    PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
      DispatchQueue.ensureMain {
        handler(status)
      }
    }
  }
  
  static var isAuthorized: Bool {
    return PHPhotoLibrary.authorizationStatus(for: .readWrite) == .authorized
  }
  
  static var authorizationStatus: PHAuthorizationStatus {
    return PHPhotoLibrary.authorizationStatus(for: .readWrite)
  }
  
  static func allUserLibraryAssets(imagesOnly: Bool = true) -> [PHAsset] {
    let result: PHFetchResult<PHAsset> = allUserLibraryAssets(imagesOnly: imagesOnly)
    return result.toArray()
  }
  
  /// get the recent smart album, from the oldest one to latest one
  static func allUserLibraryAssets(imagesOnly: Bool = true) -> PHFetchResult<PHAsset> {
    guard let first = userLibraryCollection() else {
      return PHFetchResult<PHAsset>()
    }
    
    let options = PhotoManager.makeFetchOptions(imagesOnly: imagesOnly)
    let assetResult = PHAsset.fetchAssets(in: first, options: options)
    
    return assetResult
  }
  
  private static func makeFetchOptions(imagesOnly: Bool) -> PHFetchOptions {
    let options = PHFetchOptions()
    if imagesOnly {
      // images and filter screenshots
      // an os bug for mediaSubtypes == 0 case
      // workaround: https://developer.apple.com/forums/thread/44133
      // format: "mediaType == %d && (NOT ((mediaSubtype & %d) != 0))",
      options.predicate = NSPredicate(
        format: "mediaType == %d",
        PHAssetMediaType.image.rawValue,
        PHAssetMediaSubtype.photoScreenshot.rawValue
      )
    }
    return options
  }

  static func userLibraryCollection() -> PHAssetCollection? {
    let userLibraryCollections = PHAssetCollection.fetchAssetCollections(
      with: .smartAlbum,
      subtype: .smartAlbumUserLibrary,
      options: nil
    )
    return userLibraryCollections.firstObject
  }
  
  static func allPhotos(imagesOnly: Bool = true) -> [PHAsset] {
    let result: PHFetchResult<PHAsset> = allPhotos(imagesOnly: imagesOnly)
    return result.toArray()
  }
  
  static func allPhotos(imagesOnly: Bool = true) -> PHFetchResult<PHAsset> {
    let options = PhotoManager.makeFetchOptions(imagesOnly: imagesOnly)
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    
    let assetResult = PHAsset.fetchAssets(with: options)
    
    return assetResult
  }
  
  static func delete(_ assets: [PHAsset], completionHandler: ((Bool, Error?) -> Void)? = nil) {
    let changes = {
      PHAssetChangeRequest.deleteAssets(assets as NSFastEnumeration)
    }
    PHPhotoLibrary.shared().performChanges(changes) { finished, error in
      DispatchQueue.ensureMain {
        completionHandler?(finished, error)
      }
    }
  }
  
  static func allScreenshots() -> PHFetchResult<PHAsset> {
    let userLibraryCollections = PHAssetCollection.fetchAssetCollections(
      with: .smartAlbum,
      subtype: .smartAlbumScreenshots,
      options: nil
    )
    
    let collection = userLibraryCollections.firstObject ?? .init()
    
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
    return PHAsset.fetchAssets(in: collection, options: options)
  }
}

struct AssetFileSizeHelper {
  static func fileSize(asset: PHAsset) -> Int64 {
    let resources = PHAssetResource.assetResources(for: asset)
    let total = resources.reduce(0) { (partialResult, resource) -> Int64 in
      let fileSize = resource.value(forKey: "fileSize") as? Int64
      return partialResult + (fileSize ?? 0)
    }
    
    return total
  }
  
  static func fileSize(assets: [PHAsset]) -> Int64 {
    return assets.reduce(0) { partialResult, asset in
      return partialResult + AssetFileSizeHelper.fileSize(asset: asset)
    }
  }
}


//  PHFetchResult+Extension.swift
import Foundation
import Photos

extension PHFetchResult<PHAsset> {
  public func toArray() -> [PHAsset] {
    return toSwiftArray(result: self)
  }
}

extension PHFetchResult<PHCollection> {
  public func toArray() -> [PHCollection] {
    return toSwiftArray(result: self)
  }
}


/// 由于无法在 extension 中应用 OC 的泛型，因此抽一个函数提供给具体的 Object 调用
fileprivate func toSwiftArray<T: AnyObject>(result: PHFetchResult<T>) -> [T] {
  var temp: [T] = []
  result.enumerateObjects { asset, _, _ in
    temp.append(asset)
  }
  
  return temp
}

//  DispatchQueue+Extension.swift
extension DispatchQueue {
  public static func ensureMain(_ block: () -> Void) {
    if OperationQueue.current === OperationQueue.main {
      block()
    } else {
      self.main.sync(execute: block)
    }
  }
}
