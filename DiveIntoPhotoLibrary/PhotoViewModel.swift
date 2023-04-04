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
  
  @Published var resourceString: String = ""
  
  lazy var assets: [PHAsset] = {
    let assets: [PHAsset] = PhotoManager.allUserLibraryAssets(imagesOnly: false)
    return assets
  }()
  
  func request() {
    PhotoManager.requestAuthorization {
      self.isAuthed = $0 == .authorized
    }
  }
  
  func onAppear() {
    checkResource()
  }
  
  func checkAssetsInfo(targetSize: CGSize) {
    let start = CFAbsoluteTimeGetCurrent()
    
    countString = ""
    
    let fetcher = ImageFetcher()
    var result: [AssetInfo] = []
    
    let enumerated = assets
      .enumerated()
      // .prefix(100)
    for (index, asset) in enumerated {
      fetcher.requestImage(
        asset: asset,
        targetSize: targetSize,
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
    
    print("time", CFAbsoluteTimeGetCurrent() - start)
  }
  
  func checkResource() {
    let start = CFAbsoluteTimeGetCurrent()
    
    var result: [ResourceInfo] = []
    for asset in assets {
      let resources = PHAssetResource.assetResources(for: asset)
      print("-------- resouce count: ", resources.count)
      
      for item in resources {
        let locallyAvailable = (item.value(forKey: "locallyAvailable") as? Bool) ?? false
        let inCloud = (item.value(forKey: "inCloud") as? Bool) ?? false
        result.append(.init(locallyAvailable: locallyAvailable, inCloud: inCloud))
        print(
          item.uniformTypeIdentifier,
          item.type.rawValue,
          item.originalFilename,
          locallyAvailable,
          inCloud
        )
        
        break
      }
    }
    let countString = "\(result.filter(\.locallyAvailable).count) : \(result.filter(\.inCloud).count)"
    self.resourceString = countString
    print("for end", countString)
    print("for end", result.count)
    
    print("time", CFAbsoluteTimeGetCurrent() - start)
  }
  
  func deleteAll() {
    PhotoManager.delete(assets) { (flag, error_) in
      print("delete result", flag)
    }
  }
}


struct AssetInfo {
  var isInCloud: Bool
  var hasImage: Bool
}

struct ResourceInfo {
  var locallyAvailable: Bool
  var inCloud: Bool
}
