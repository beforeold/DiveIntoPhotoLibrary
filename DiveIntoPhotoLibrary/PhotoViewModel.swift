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
         targetSize: PHImageManagerMaximumSize,
//         targetSize: .init(width: 224, height: 224),
        isSynchronous: true
      ) { image, asset, userInfo in
        let isInCloud = (userInfo?[PHImageResultIsInCloudKey] as? Bool) ?? false
        let hasImage = image != nil
        let assetInfo = AssetInfo(isInCloud: isInCloud, hasImage: hasImage)
        result.append(assetInfo)
        print("handled", index + 1, image?.size.width ?? 0, image?.size.height ?? 0)
      }
    }
    print(result.filter(\.hasImage).count, ":", result.filter(\.isInCloud).count)
    print(result.count)
  }
  
  func deleteAll() {
    let assets: [PHAsset] = PhotoManager.allUserLibraryAssets(imagesOnly: false)
    PhotoManager.delete(assets) { (flag, error_) in
      print("delete result", flag)
    }
  }
}
