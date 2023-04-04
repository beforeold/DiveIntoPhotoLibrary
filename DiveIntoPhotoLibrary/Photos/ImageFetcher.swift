//
//  ImageFetcher.swift
//  DiveIntoPhotoLibrary
//
//  Created by Brook_Mobius on 2023/4/3.
//

import UIKit
import Photos

class ImageFetcher {
  /// get thumbnail of the asset
  @discardableResult
  func requestImage(
    asset: PHAsset,
    targetSize: CGSize = defaultTargetSize(),
    isSynchronous: Bool = false,
    isNetworkAccessAllowed: Bool = false,
    completion: @escaping (UIImage?, PHAsset, [AnyHashable: Any]?) -> Void
  ) -> PHImageRequestID {
    // let begin = CFAbsoluteTimeGetCurrent()
    
    let options = PHImageRequestOptions()
    options.isSynchronous = isSynchronous
    options.isNetworkAccessAllowed = isNetworkAccessAllowed
    
    var hasCallback = false
    let id = PHImageManager.default().requestImage(
      for: asset,
      targetSize: targetSize,
      contentMode: .aspectFill,
      options: options
    ) { image, info in
      if isSynchronous && hasCallback {
        return
      }
      hasCallback = true
      completion(image, asset, info)
    }
    
    return id
  }
  
  func cancelImageRequest(_ requestId: PHImageRequestID) {
    PHImageManager.default().cancelImageRequest(requestId)
  }
}


func defaultTargetSize() -> CGSize {
  let column: CGFloat = 3
  let spacing: CGFloat = 1
  let scale: CGFloat = ImageFetcher.scale
  let itemLength = scale * (UIScreen.main.bounds.width - (column - 1) * spacing) / column
  let size = CGSize(width: itemLength, height: itemLength)
  return size
}


extension ImageFetcher {
  static var scale: CGFloat {
    return UIScreen.main.scale
  }
}

extension CGSize {
  var imageFetcherScaled: CGSize {
    let scale = ImageFetcher.scale
    return .init(width: width * scale, height: height * scale)
  }
}

