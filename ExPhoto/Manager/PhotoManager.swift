//
//  PhotoManager.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import Photos
import UIKit

protocol PhotoManager {
    func convertAlbumToPHAssets(
        album: PHFetchResult<PHAsset>,
        completion: @escaping ([PHAsset]) -> Void
    )
    
    func fetchImage(
        phAsset: PHAsset,
        size: CGSize,
        contentMode: PHImageContentMode,
        completion: @escaping (UIImage) -> Void
    )
    
    func fetchImage(
        phAsset: PHAsset,
        completion: @escaping (UIImage?) -> Void
    )
}

final class MyPhotoManager: NSObject, PhotoManager {
    private let imageManager = PHCachingImageManager()
    weak var delegate: PHPhotoLibraryChangeObserver?
    
    override init() {
        super.init()
        // PHPhotoLibraryChangeObserver 델리게이트
        // PHPhotoLibrary: 변경사항을 알려 데이터 리프레시에 사용
        PHPhotoLibrary.shared().register(self)
    }
    
    deinit {
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
    
    func convertAlbumToPHAssets(album: PHFetchResult<PHAsset>, completion: @escaping ([PHAsset]) -> Void) {
        var phAssets = [PHAsset]()
        defer { completion(phAssets) }
        
        guard 0 < album.count else { return }
        album.enumerateObjects { asset, index, stopPointer in
            guard index <= album.count - 1 else {
                stopPointer.pointee = true
                return
            }
            phAssets.append(asset)
        }
    }
    
    func fetchImage(
        phAsset: PHAsset,
        size: CGSize,
        contentMode: PHImageContentMode,
        completion: @escaping (UIImage) -> Void
    ) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = true
        
        imageManager.requestImage(
            for: phAsset,
            targetSize: size,
            contentMode: contentMode,
            options: options,
            resultHandler: { image, _ in
                guard let image else { return }
                completion(image)
            }
        )
    }
    
    func fetchImage(
        phAsset: PHAsset,
        completion: @escaping (UIImage?) -> Void
    ) {
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        
        imageManager.requestImageDataAndOrientation(
            for: phAsset,
            options: options
        ) { data, dataUTI, orientation, info in
            guard let data = data else {
                completion(nil)
                return
            }
            let image = UIImage(data: data)
            completion(image)
        }
    }
}

extension MyPhotoManager: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        delegate?.photoLibraryDidChange(changeInstance)
    }
}
