//
//  TransparentRectView.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//
import UIKit

class TransparentRectView: UIView {
    //*******************************************************
    // MARK: - UI
    //*******************************************************
    private let frameView: UIImageView = .init(image: UIImage(named: "photo_edit_frame"))
    private var overlayLayer: CAShapeLayer?
    private var cornerViews: [UIView] = []

    //*******************************************************
    // MARK: - Properties
    //*******************************************************
    var transparentRect: CGRect = CGRect(x: 50, y: 50, width: 200, height: 200) {
        didSet {
            setNeedsDisplay()
        }
    }
    private let cornerSize: CGFloat = 30.0
    private var isBlockMoveRect: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        setupGestures()
        
        frameView.frame = transparentRect
        addSubview(frameView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // 검정색으로 전체 View를 채웁니다.
        context.setFillColor(UIColor.black.withAlphaComponent(0.4).cgColor)
        context.fill(self.bounds)
        
        // 투명한 사각형을 그립니다.
        context.clear(transparentRect)
        frameView.frame = transparentRect
        
        updateCornerViews()
    }
    
    private func setupGestures() {
        self.isUserInteractionEnabled = true
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        self.addGestureRecognizer(panGesture)
        
        cornerViews.removeAll()
        // 네 꼭짓점에 드래그 제스처 추가
        addCornerGesture(at: CGPoint(x: transparentRect.minX, y: transparentRect.minY)) // top-left
        addCornerGesture(at: CGPoint(x: transparentRect.maxX, y: transparentRect.minY)) // top-right
        addCornerGesture(at: CGPoint(x: transparentRect.minX, y: transparentRect.maxY)) // bottom-left
        addCornerGesture(at: CGPoint(x: transparentRect.maxX, y: transparentRect.maxY)) // bottom-right
    }
    
    private func addCornerGesture(at point: CGPoint) {
        let cornerView = UIView(frame: CGRect(x: point.x - cornerSize / 2, y: point.y - cornerSize / 2, width: cornerSize, height: cornerSize))
        cornerView.isUserInteractionEnabled = true
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleCornerPan(_:)))
        cornerView.addGestureRecognizer(panGesture)
        cornerViews.append(cornerView)
        self.addSubview(cornerView)
    }
    
    private func updateCornerViews() {
        cornerViews[0].center = CGPoint(x: transparentRect.minX, y: transparentRect.minY) // top-left
        cornerViews[1].center = CGPoint(x: transparentRect.maxX, y: transparentRect.minY) // top-right
        cornerViews[2].center = CGPoint(x: transparentRect.minX, y: transparentRect.maxY) // bottom-left
        cornerViews[3].center = CGPoint(x: transparentRect.maxX, y: transparentRect.maxY) // bottom-right
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard !isBlockMoveRect else { return }
        
        let translation = gesture.translation(in: self)
        var newRect = transparentRect
        newRect.origin.x += translation.x
        newRect.origin.y += translation.y
        
        // 뷰의 경계를 벗어나지 않도록 위치를 제한합니다.
        newRect.origin.x = max(0, min(newRect.origin.x, self.bounds.width - newRect.width))
        newRect.origin.y = max(0, min(newRect.origin.y, self.bounds.height - newRect.height))
        
        transparentRect = newRect
        gesture.setTranslation(.zero, in: self)
    }

    @objc private func handleCornerPan(_ gesture: UIPanGestureRecognizer) {
        guard let cornerView = gesture.view else { return }

        let translation = gesture.translation(in: self)
        var newRect = transparentRect
        if cornerView == cornerViews[0] { // top-left
            newRect.size.width -= translation.x
            newRect.size.height -= translation.y
            
            if newRect.size.width > 100 {
                newRect.origin.x += translation.x
            }
            if newRect.size.height > 100 {
                newRect.origin.y += translation.y
            }
        } else if cornerView == cornerViews[1] { // top-right
            if newRect.size.height > 100 {
                newRect.origin.y += translation.y
            }
            newRect.size.width += translation.x
            newRect.size.height -= translation.y
        } else if cornerView == cornerViews[2] { // bottom-left
            if newRect.size.width > 100 {
                newRect.origin.x += translation.x
            }
            newRect.size.width -= translation.x
            newRect.size.height += translation.y
        } else if cornerView == cornerViews[3] { // bottom-right
            newRect.size.width += translation.x
            newRect.size.height += translation.y
        }
        
        // 뷰의 경계를 벗어나지 않도록 크기를 제한합니다.
        newRect.size.width = min(newRect.size.width, self.bounds.width - newRect.origin.x)
        newRect.size.height = min(newRect.size.height, self.bounds.height - newRect.origin.y)
        // 최소 사이즈보다 작아지지 않도록 제한
        newRect.size.width = max(newRect.size.width, 100)
        newRect.size.height = max(newRect.size.height, 100)
        
        transparentRect = newRect
        gesture.setTranslation(.zero, in: self)
        
        isBlockMoveRect = true
        if gesture.state == .ended {
            isBlockMoveRect = false
        }
    }
}
