//
//  PhotoViewModel.swift
//  DiveIntoPhotoLibrary
//
//  Created by Brook_Mobius on 2023/4/3.
//

import SwiftUI
import Photos

class PhotoViewModel: ObservableObject {
  static let shared: PhotoViewModel = .init()
  
  @Published var isAuthed: Bool = false
  
  @Published var countString: String = ""
  
  func request() {
    PhotoManager.requestAuthorization {
      self.isAuthed = $0 == .authorized
    }
  }
  
  struct AssetInfo {
    var isInCloud: Bool
    var hasImage: Bool
  }
  
  func checkAssetsInfo() {
    countString = ""
    
    let fetcher = ImageFetcher()
    let assets: [PHAsset] = PhotoManager.allUserLibraryAssets(imagesOnly: false)
    var result: [AssetInfo] = []
    
    let enumerated = assets
      .enumerated()
      // .prefix(100)
    for (index, asset) in enumerated {
      fetcher.requestImage(
        asset: asset,
//         targetSize: .init(width: 20, height: 20),
//        targetSize: .init(width: 80, height: 80),
         targetSize: .init(width: 224, height: 224),
//        targetSize: defaultTargetSize(),
//         targetSize: PHImageManagerMaximumSize,
        isSynchronous: true
//        isNetworkAccessAllowed: true
      ) { image, asset, userInfo in
        let isInCloud = (userInfo?[PHImageResultIsInCloudKey] as? Bool) ?? false
        let hasImage = image != nil
        let assetInfo = AssetInfo(isInCloud: isInCloud, hasImage: hasImage)
        result.append(assetInfo)
        if image != nil {
          print("handled", index + 1, image?.size.width ?? 0, image?.size.height ?? 0)
        }
      }
    }
    let countString = "\(result.filter(\.hasImage).count) : \(result.filter(\.isInCloud).count)"
    self.countString = countString
    print("for end", countString)
    print("for end", result.count)
  }
  
  func deleteAll() {
    let assets: [PHAsset] = PhotoManager.allUserLibraryAssets(imagesOnly: false)
    PhotoManager.delete(assets) { (flag, error_) in
      print("delete result", flag)
    }
  }
}
