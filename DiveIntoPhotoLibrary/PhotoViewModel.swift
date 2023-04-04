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
  
  var assets: [PHAsset] {
    let assets: [PHAsset] = PhotoManager.allUserLibraryAssets(imagesOnly: false)
    return assets
  }
  
  func request() {
    PhotoManager.requestAuthorization {
      self.isAuthed = $0 == .authorized
    }
  }
  
  func onAppear() {
    checkAssetsInfo(
      targetSize: .init(width: 20, height: 20)
    )
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
    
    print("for end", #function)
    print("for end result count", result.count)
    
    print("for end size", targetSize)
    
    let ratioString = "size: \(targetSize)\nhasImage: \(result.filter(\.hasImage).count) : inCloud: \(result.filter(\.isInCloud).count)"
    self.countString = ratioString
    
    print("for end ratioString", ratioString)
    
    let span = CFAbsoluteTimeGetCurrent() - start
    print("time", span)
    print("average time", span / Double(result.count))
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
        let fileSize = (item.value(forKey: "fileSize") as? Int64) ?? 0
        let cplResourceType = (item.value(forKey: "cplResourceType") as? Int) ?? 0
        
        result.append(.init(locallyAvailable: locallyAvailable, inCloud: inCloud, cplResourceType: cplResourceType))
        print(
          item.uniformTypeIdentifier,
          item.type.rawValue,
          item.originalFilename,
          locallyAvailable,
          inCloud,
          fileSize / 1_000,
          cplResourceType
        )
        
        break
      }
    }
    
    print("for end", #function)
    print("for end result count", result.count)
    
    let ratioString = "local: \(result.filter(\.locallyAvailable).count) : inCloud: \(result.filter(\.inCloud).count)"
    self.resourceString = ratioString
    
    print("for end ratioString", ratioString)
    
    let span = CFAbsoluteTimeGetCurrent() - start
    print("time", span)
    print("average time", span / Double(result.count))
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
  var cplResourceType: Int
}
