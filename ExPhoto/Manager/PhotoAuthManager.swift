//
//  PhotoAuthManager.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import Photos
import UIKit

protocol PhotoAuthManager {
    var authorizationStatus: PHAuthorizationStatus { get }
    var isAuthorizationLimited: Bool { get }
    
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void)
}

extension PhotoAuthManager {
    var isAuthorizationLimited: Bool {
        authorizationStatus == .limited
    }
    
    fileprivate func goToSetting() {
        guard
            let url = URL(string: UIApplication.openSettingsURLString),
            UIApplication.shared.canOpenURL(url)
        else { return }
            
        UIApplication.shared.open(url, completionHandler: nil)
    }
}

final class MyPhotoAuthManager: PhotoAuthManager {
    var authorizationStatus: PHAuthorizationStatus {
        PHPhotoLibrary.authorizationStatus(for: .readWrite)
    }
    
    func requestAuthorization(completion: @escaping (Result<Void, NSError>) -> Void) {
        switch authorizationStatus {
        case .authorized, .limited:
            completion(.success(()))
        case .notDetermined:
            completion(.failure(.init()))
        case .denied:
            DispatchQueue.main.async {
                self.goToSetting()
            }
            completion(.failure(.init()))
        default:
            break
        }
        
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                completion(.success(()))
            }
        }
    }
}
