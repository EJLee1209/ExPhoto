//
//  SelectPhotoViewController.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit
import Combine
import Photos

final class SelectPhotoViewModel {}

protocol SelectPhotoDelegate: AnyObject {
    func finish(selectedImages: [UIImage?])
}

final class SelectPhotoViewController: CommonViewController<SelectPhotoViewModel> {
    private enum Const {
        static let numberOfColumns = 4.0
        static let cellSpace = 1.0
        static let length = (screenSize.width - cellSpace * (numberOfColumns - 1)) / numberOfColumns
        static let cellSize = CGSize(width: length, height: length)
        static let scale = UIScreen.main.scale
    }
    //MARK: - UI
    private let collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
            .with
            .scrollDirection(.vertical)
            .minimumLineSpacing(1)
            .minimumInteritemSpacing(0)
            .itemSize(Const.cellSize)
            .build()
    )
    
    //MARK: - Properties
    private let albumManager: AlbumManager = MyAlbumManager()
    private let photoManager: PhotoManager = MyPhotoManager()
    
    weak var delegate: SelectPhotoDelegate?
    // album 여러개에 대한 예시는 생략 (UIPickerView와 같은 것을 이용하여 currentAlbumIndex를 바꾸어주면 됨)
    private var albums = [PHFetchResult<PHAsset>]()
    private var assets = [PHAsset]()
    private var dataSource = [PhotoCellInfo]()
    private var currentAlbumIndex = 0
    var maxNumberOfItems: Int?
    private var selectedIndexArray = [Int]() // Index: count
    var showEditController: Bool = false
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        configUI()
        initCollectionView()
        
        loadAlbums { [weak self] in
            self?.loadAssets()
        }
    }
    
    //MARK: - Helpers
    private func setNavigationBar() {
        layoutNavigationBar()
        navigationBar.setBackBtnIsHidden(true)
        navigationBar.setNavigationTitle("최근 항목")
        let closeBtn = UIButton(type: .system)
        closeBtn.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeBtn.tintColor = .black
        closeBtn.snp.makeConstraints { make in
            make.size.equalTo(24)
        }
        closeBtn.addTarget(self, action: #selector(actionCloseBtn(_:)), for: .touchUpInside)
        
        let finishBtn = UIButton(type: .system)
        finishBtn.setTitle("완료", for: .normal)
        finishBtn.setTitleColor(.black, for: .normal)
        finishBtn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        finishBtn.addTarget(self, action: #selector(actionFinishBtn(_:)), for: .touchUpInside)
        navigationBar.addLeftItems([closeBtn])
        navigationBar.addRightItems([finishBtn])
    }
    
    private func configUI() {
        view.backgroundColor = .white
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    private func initCollectionView() {
        collectionView.isScrollEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = true
        collectionView.contentInset = .zero
        collectionView.backgroundColor = .clear
        collectionView.clipsToBounds = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.alwaysBounceVertical = true
        collectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
    }
    
    
    private func loadAlbums(completion: @escaping () -> Void) {
        albumManager.getAlbums(mediaType: .image) { [weak self] albumInfos in
            self?.albums = albumInfos.map(\.album)
            completion()
        }
    }
    
    private func loadAssets() {
        guard currentAlbumIndex < albums.count else { return }
        let album = albums[currentAlbumIndex]
        photoManager.convertAlbumToPHAssets(album: album) { [weak self] phAssets in
            self?.dataSource = phAssets.map { PhotoCellInfo(phAsset: $0, image: nil, selectedOrder: .none) }
            self?.collectionView.reloadData()
        }
    }
}

// MARK: - Actions
extension SelectPhotoViewController {
    @objc private func actionCloseBtn(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func actionFinishBtn(_ sender: UIButton) {
        let assets = selectedIndexArray.compactMap { idx in
            dataSource[idx].phAsset
        }
        var selectedImages: [UIImage] = []
        assets.forEach { asset in
            photoManager.fetchImage(phAsset: asset) { image in
                if let image = image?.fixOrientation() {
                    selectedImages.append(image)
                }
            }
        }
        
        if showEditController {
            if let controller = EditPhotoViewController(viewModel: .init(), imageList: selectedImages) {
                controller.modalPresentationStyle = .overFullScreen
                controller.modalTransitionStyle = .crossDissolve
                controller.delegate = self
                self.present(controller, animated: true)
            }
        } else {
            delegate?.finish(selectedImages: selectedImages)
            dismiss(animated: true)
        }
    }
}

// MARK: - UICollectionViewDataSource
extension SelectPhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let itemCell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath) as? PhotoCollectionCell else {
            return .init()
        }
        
        var itemData = dataSource[indexPath.item]
        let imageSize = CGSize(width: Const.cellSize.width * Const.scale, height: Const.cellSize.height * Const.scale)
        
        if let asset = itemData.phAsset {
            photoManager.fetchImage(
                phAsset: asset,
                size: imageSize,
                contentMode: .aspectFill) { image in
                    itemData.image = image
                    itemCell.configData(itemData)
                }
        }
        
        return itemCell
    }
}

// MARK: - UICollectionViewDelegate
extension SelectPhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let limit = maxNumberOfItems, limit <= selectedIndexArray.count {
            return
        }
        
        let info = dataSource[indexPath.item]
        let updatingIndexPaths: [IndexPath]
        
        if case .selected = info.selectedOrder {
            dataSource[indexPath.item] = .init(phAsset: info.phAsset, image: info.image, selectedOrder: .none)
            
            selectedIndexArray
                .removeAll(where: { $0 == indexPath.item })
            
            selectedIndexArray
                .enumerated()
                .forEach { order, index in
                    let order = order + 1
                    let prev = dataSource[index]
                    dataSource[index] = .init(phAsset: prev.phAsset, image: prev.image, selectedOrder: .selected(order))
                }
            updatingIndexPaths = [indexPath] + selectedIndexArray
                .map { IndexPath(row: $0, section: 0) }
        } else {
            selectedIndexArray
                .append(indexPath.item)
            
            selectedIndexArray
                .enumerated()
                .forEach { order, selectedIndex in
                    let order = order + 1
                    let prev = dataSource[selectedIndex]
                    dataSource[selectedIndex] = .init(phAsset: prev.phAsset, image: prev.image, selectedOrder: .selected(order))
                }
            
            updatingIndexPaths = selectedIndexArray
                .map { IndexPath(row: $0, section: 0) }
        }
        
        update(indexPaths: updatingIndexPaths)
    }
    
    private func update(indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: indexPaths)
        }
    }
}

// MARK: - EditphotoViewControllerDelegate
extension SelectPhotoViewController: EditphotoViewControllerDelegate {
    func finishEditPhoto(resultImages: [UIImage]) {
        delegate?.finish(selectedImages: resultImages)
        dismiss(animated: true)
    }
}
