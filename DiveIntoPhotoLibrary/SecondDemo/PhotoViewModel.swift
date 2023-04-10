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
  
  @Published var isLoading: Bool = false
  
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

  }
  
  func checkAssetsInfo(targetSize: CGSize) {
    isLoading = true
    countString = ""

    DispatchQueue.global().async {
      let string = self._checkAssetsInfo(targetSize: targetSize)
      DispatchQueue.main.async {
        self.isLoading = false
        self.countString = string
      }
    }
  }
  
  private func _checkAssetsInfo(targetSize: CGSize) -> String {
    let start = CFAbsoluteTimeGetCurrent()
    
    let fetcher = ImageFetcher()
    var result: [AssetInfo] = []
    
    let assets = self.assets
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
        let assetInfo = AssetInfo(asset: asset, isInCloud: isInCloud, hasImage: hasImage)
        result.append(assetInfo)
        if image != nil {
          print("handled", index + 1, image?.size.width ?? 0, image?.size.height ?? 0)
        }
      }
    }
    
    print("for end", #function)
    print("for end result count", result.count)
    
    print("for end size", targetSize)
    
    let ratioString = """
result count: \(result.count)
size: \(targetSize)
hasImage: \(result.filter(\.hasImage).count), inCloud: \(result.filter(\.isInCloud).count)
"""
    
    print("for end ratioString", ratioString)
    
    let span = CFAbsoluteTimeGetCurrent() - start
    print("time", span)
    print("average time", span / Double(result.count))
    
    return ratioString
  }
  
  func checkResource() {
    isLoading = true
    DispatchQueue.global().async {
      let string = self._checkResource()
      DispatchQueue.main.async {
        self.isLoading = false
        self.resourceString = string
      }
    }
  }
  
  private func _checkResource() -> String {
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
        
        result.append(.init(asset: asset, locallyAvailable: locallyAvailable, inCloud: inCloud, cplResourceType: cplResourceType))
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
    
    let ratioString = "count: \(result.count)\nlocal: \(result.filter(\.locallyAvailable).count), inCloud: \(result.filter(\.inCloud).count)"
    
    print("for end ratioString", ratioString)
    
    let span = CFAbsoluteTimeGetCurrent() - start
    print("time", span)
    print("average time", span / Double(result.count))
    
    return ratioString
  }
  
  func deleteAll() {
    PhotoManager.delete(assets) { (flag, error_) in
      print("delete result", flag)
    }
  }
}


struct AssetInfo {
  var asset: PHAsset
  var isInCloud: Bool
  var hasImage: Bool
}

struct ResourceInfo {
  var asset: PHAsset
  var locallyAvailable: Bool
  var inCloud: Bool
  var cplResourceType: Int
}
