//
//  AlbumManager.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import Photos

protocol AlbumManager {
    func getAlbums(mediaType: MediaType, completion: @escaping ([AlbumInfo]) -> Void)
}

final class MyAlbumManager: AlbumManager {
    func getAlbums(mediaType: MediaType, completion: @escaping ([AlbumInfo]) -> Void) {
        // 0. albums 변수 선언
        var albums = [AlbumInfo]()
        defer { completion(albums) }
        
        // 1. query 설정
        let fetchOptions = PHFetchOptions()
            .with
            .predicate(getPredicate(mediaType: mediaType))
            .sortDescriptors(getSortDescriptors)
            .build()
        
        // 2. standard 앨범을 query로 이미지 가져오기
        let standardFetchResult = PHAsset.fetchAssets(with: fetchOptions)
        albums.append(.init(fetchResult: standardFetchResult, albumName: mediaType.title))
        
        // 3. smart 앨범을 query로 이미지 가져오기
        let smartAlbums = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .any,
            options: PHFetchOptions()
        )
        smartAlbums.enumerateObjects { [weak self] phAssetCollection, index, pointer in
            guard let self, index <= smartAlbums.count - 1 else {
                pointer.pointee = true
                return
            }
            
            // 값을 빠르게 받아오지 못하는 경우
            if phAssetCollection.estimatedAssetCount == NSNotFound {
                // 쿼리를 날려서 가져오기
                let fetchOptions = PHFetchOptions()
                    .with
                    .predicate(getPredicate(mediaType: mediaType))
                    .sortDescriptors(getSortDescriptors)
                    .build()
                let fetchResult = PHAsset.fetchAssets(in: phAssetCollection, options: fetchOptions)
                albums.append(.init(fetchResult: fetchResult, albumName: mediaType.title))
            }
        }
    }
    
    private func getPredicate(mediaType: MediaType) -> NSPredicate {
        let format = "mediaType == %d"
        switch mediaType {
        case .all:
            return .init(
                format: format + " || " + format,
                PHAssetMediaType.image.rawValue,
                PHAssetMediaType.video.rawValue
            )
        case .image:
            return .init(
                format: format,
                PHAssetMediaType.image.rawValue
            )
        case .video:
            return .init(
                format: format,
                PHAssetMediaType.video.rawValue
            )
        }
    }
    
    private let getSortDescriptors = [
        NSSortDescriptor(key: "creationDate", ascending: false),
        NSSortDescriptor(key: "modificationDate", ascending: false)
    ]
}

struct AlbumInfo: Identifiable {
    let id: String?
    let name: String
    let album: PHFetchResult<PHAsset>
    
    init(fetchResult: PHFetchResult<PHAsset>, albumName: String) {
        id = nil
        name = albumName
        album = fetchResult
    }
}


enum MediaType {
    case all
    case image
    case video
    
    var title: String {
        switch self {
        case .all:
            return "이미지와 비디오"
        case .image:
            return "이미지"
        case .video:
            return "비디오"
        }
    }
}
