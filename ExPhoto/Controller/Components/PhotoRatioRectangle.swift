//
//  PhotoRatioRectangle.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit

final class PhotoRatioRectangle: UIView {
    private let rect: UIView = .init()
    private var vertexes: [UIView] = []
    private var isLayoutSubViews: Bool = false
    var isActive: Bool = false {
        didSet {
            if isActive {
                rect.layer.borderColor = UIColor.systemBlue.cgColor
                vertexes.forEach { $0.isHidden = false }
            } else {
                rect.layer.borderColor = UIColor.black.cgColor
                vertexes.forEach { $0.isHidden = true }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        rect.layer.borderColor = UIColor.black.cgColor
        rect.layer.borderWidth = 2
        
        addSubview(rect)
        rect.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(2)
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        guard !isLayoutSubViews else { return }
        VertexPosition.allCases.forEach {
            let vertex = makeVertext(position: $0)
            addSubview(vertex)
            vertexes.append(vertex)
        }
        isLayoutSubViews.toggle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    enum VertexPosition: CaseIterable {
        case topLeft, topRight, bottomLeft, bottomRight
        
        func getOrigin(_ rect: CGRect, size: CGSize) -> CGPoint {
            switch self {
            case .topLeft:
                return rect.origin
            case .topRight:
                return .init(x: rect.maxX - size.width, y: rect.minY)
            case .bottomLeft:
                return .init(x: rect.minX, y: rect.maxY - size.height)
            case .bottomRight:
                return .init(x: rect.maxX - size.width, y: rect.maxY - size.height)
            }
        }
    }
    
    private func makeVertext(
        position: VertexPosition
    ) -> UIView {
        let size = CGSize(width: 5, height: 5)
        let origin = position.getOrigin(self.bounds, size: size)
        let view = UIView(frame: .init(origin: origin, size: size))
        view.backgroundColor = .systemBlue
        view.isHidden = true
        return view
    }
}
