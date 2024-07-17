//
//  ViewController.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit

final class HomeViewModel {}

class HomeViewController: CommonViewController<HomeViewModel> {
    private let collectionView: UICollectionView = .init(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout()
            .with
            .minimumLineSpacing(0)
            .minimumInteritemSpacing(0)
            .scrollDirection(.horizontal)
            .build()
    )
    private lazy var selectPhotoBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("사진 선택", for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        btn.backgroundColor = .systemIndigo
        btn.setTitleColor(.white, for: .normal)
        btn.addTarget(self, action: #selector(actionSelectPhotoBtn(_:)), for: .touchUpInside)
        return btn
    }()
    
    private let photoAuthManager: PhotoAuthManager = MyPhotoAuthManager()
    private var selectedImages: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        layout()
        initCollectionView()
    }
    
    private func layout() {
        view.backgroundColor = .white
        layoutNavigationBar()
        navigationBar.setNavigationTitle("홈")
        navigationBar.setBackBtnIsHidden(true)
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        view.addSubview(selectPhotoBtn)
        selectPhotoBtn.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
            make.height.equalTo(63)
        }
        selectPhotoBtn.clipsToBounds = true
        selectPhotoBtn.layer.cornerRadius = 16
    }
    
    private func initCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.isPagingEnabled = true
        collectionView.register(PhotoCollectionCell.self, forCellWithReuseIdentifier: PhotoCollectionCell.identifier)
    }
}

// MARK: - Actions
extension HomeViewController {
    @objc private func actionSelectPhotoBtn(_ sender: UIButton) {
        photoAuthManager.requestAuthorization { [weak self] result in
            switch result {
            case .success:
                let controller = SelectPhotoViewController(viewModel: .init())
                controller.delegate = self
                controller.modalPresentationStyle = .overFullScreen
                controller.showEditController = true
                self?.present(controller, animated: true)
            case .failure:
                return
            }
        }
    }
}

// MARK: - UICollectionViewDataSource
extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCollectionCell.identifier, for: indexPath
        ) as? PhotoCollectionCell else {
            return .init()
        }
        let image = selectedImages[indexPath.item]
        cell.configData(.init(image: image, selectedOrder: .none))
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension HomeViewController: UICollectionViewDelegate {
    
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension HomeViewController: SelectPhotoDelegate {
    func finish(selectedImages: [UIImage?]) {
        self.selectedImages = selectedImages
        collectionView.reloadData()
    }
}
