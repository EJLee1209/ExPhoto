//
//  PhotoCollectionCell.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit
import Photos

enum SelectionOrder {
    case none
    case selected(Int)
}

struct PhotoCellInfo {
    var phAsset: PHAsset?
    var image: UIImage?
    var selectedOrder: SelectionOrder
}

final class PhotoCollectionCell: UICollectionViewCell, Reusable {
    private let imageView: UIImageView = .init()
        .then {
            $0.backgroundColor = .lightGray
            $0.isUserInteractionEnabled = false
            $0.contentMode = .scaleAspectFill
            $0.clipsToBounds = true
        }
    
    private let orderLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .systemBlue
        label.textColor = .white
        label.textAlignment = .center
        label.layer.borderWidth = 1
        label.layer.borderColor = UIColor.white.cgColor
        label.font = .systemFont(ofSize: 12, weight: .bold)
        return label
    }()
    
    private let highlightedView: UIView = .init()
        .then {
            $0.backgroundColor = .white.withAlphaComponent(0.2)
        }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        imageView.addSubview(highlightedView)
        highlightedView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        highlightedView.addSubview(orderLabel)
        orderLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.right.equalToSuperview().inset(10)
            make.size.equalTo(16)
        }
        orderLabel.layer.cornerRadius = 8
        orderLabel.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        configData(nil)
    }
    
    func configData(_ data: PhotoCellInfo?) {
        imageView.image = data?.image
        
        if case let .selected(order) = data?.selectedOrder {
            highlightedView.isHidden = false
            orderLabel.text = String(order)
        } else {
            highlightedView.isHidden = true
        }
    }
}
