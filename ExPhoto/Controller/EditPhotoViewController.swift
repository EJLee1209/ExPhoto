//
//  EditPhotoViewController.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit

protocol EditphotoViewControllerDelegate: AnyObject {
    func finishEditPhoto(resultImages: [UIImage])
}

final class EditPhotoViewModel {}

final class EditPhotoViewController: CommonViewController<EditPhotoViewModel> {
    //*******************************************************
    // MARK: - UI
    //*******************************************************
    /// 취소/닫기 버튼
    private lazy var closeBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("닫기", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(actionCloseBtn(_:)), for: .touchUpInside)
        return btn
    }()
    /// 완료
    private lazy var finishBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("완료", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        btn.isHidden = true
        btn.addTarget(self, action: #selector(actionFinishBtn(_:)), for: .touchUpInside)
        return btn
    }()
    /// 이전 버튼
    private lazy var prevBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        btn.tintColor = .black
        btn.tag = -1
        btn.addTarget(self, action: #selector(actionPrevOrNextBtn(_:)), for: .touchUpInside)
        return btn
    }()
    /// 다음 버튼
    private lazy var nextBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        btn.tintColor = .black
        btn.tag = 1
        btn.addTarget(self, action: #selector(actionPrevOrNextBtn(_:)), for: .touchUpInside)
        return btn
    }()
    /// 이미지 인덱스
    private let imageIndexLabel: UILabel = .init()
        .with
        .font(.systemFont(ofSize: 14, weight: .semibold))
        .text("10/10")
        .textAlignment(.center)
        .build()
    /// 이미지 뷰
    private let imageView: UIImageView = .init()
        .with
        .backgroundColor(.systemGroupedBackground)
        .contentMode(.scaleAspectFit)
        .isUserInteractionEnabled(true)
        .build()
    /// 사진 편집 프레임
    private var transparentRectView: TransparentRectView?
    /// 하단 컨텐츠 컨테이너
    private let bottomContentContainerView = UIView()
    
    //*******************************************************
    // MARK: - Properties
    //*******************************************************
    /// 사진 비율
    enum PhotoRatio: String, CaseIterable {
        case oneToOne = "1:1"
        case threeToFour = "3:4"
        case fourToThree = "4:3"
        case full = "화면맞춤"

        /// 사진 편집 프레임 사이즈 비율
        var ratio: CGFloat {
            switch self {
            case .oneToOne, .full:
                return 1.0
            case .threeToFour:
                return 3/4
            case .fourToThree:
                return 4/3
            }
        }
    }
    private var photoRatio: PhotoRatio? {
        didSet {
            photoRatioRectangles.forEach { rect in
                rect.isActive = rect.accessibilityIdentifier == photoRatio?.rawValue
            }
            self.isEditingPhoto = photoRatio != .none
        }
    }
    /// 하단 사진 비율 사각형 리스트
    private var photoRatioRectangles: [PhotoRatioRectangle] = .init()
    /// 이미지 리스트
    private var imageList: [UIImage]
    /// 결과 이미지 리스트
    private var resultImageList: [UIImage]
    /// 현재 이미지 인덱스
    private var currentImageIndex: Int = 1
    //// 현재 이미지
    private var currentImage: UIImage? {
        if currentImageIndex > imageList.count { return nil }
        return imageList[currentImageIndex-1]
    }
    /// 이미지뷰가 사용할 수 있는 영역의 크기
    /// bottomBackgroundView: 195
    /// navigationBar: 56
    private var imageViewAvailableSize: CGSize = .init(
        width: screenSize.width,
        height: screenSize.height-195-56-Utils.safeAreaTopInset()
    )
    private var isEditingPhoto: Bool = false {
        didSet {
            if isEditingPhoto {
                closeBtn.setTitle("취소", for: .normal)
                finishBtn.isHidden = false
            } else {
                closeBtn.setTitle("닫기", for: .normal)
                finishBtn.isHidden = !(currentImageIndex == imageList.count)
            }
        }
    }
    /// Delegate
    weak var delegate: EditphotoViewControllerDelegate?
    
    //*******************************************************
    // MARK: - init
    //*******************************************************
    init?(viewModel: EditPhotoViewModel, imageList: [UIImage]) {
        guard !imageList.isEmpty else { return nil }
        
        self.imageList = imageList.map { $0.resize(newWidth: screenSize.width) }
        self.resultImageList = imageList
        super.init(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //*******************************************************
    // MARK: - LifeCycle
    //*******************************************************
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBar()
        layout()
        
        setImage(currentImage)
        imageIndexLabel.text = "\(currentImageIndex)/\(imageList.count)"
    }
        
    //*******************************************************
    // MARK: - Helpers
    //*******************************************************
    private func setNavigationBar() {
        layoutNavigationBar()
        navigationBar.setBackBtnIsHidden(true)
        let navTitleStackView = UIStackView(arrangedSubviews: [prevBtn, imageIndexLabel, nextBtn])
            .with
            .axis(.horizontal)
            .spacing(12)
            .build()
        imageIndexLabel.snp.makeConstraints { make in
            make.width.equalTo(imageIndexLabel.intrinsicContentSize.width + 4)
        }
        navigationBar.setNavigationTitle(navTitleStackView)
        navigationBar.setNavigationTitle("최근 항목")
        navigationBar.addLeftItems([closeBtn])
        navigationBar.addRightItems([finishBtn])
    }
    
    private func layout() {
        view.backgroundColor = .white
        
        bottomContentContainerView.backgroundColor = .white
        view.addSubview(bottomContentContainerView)
        bottomContentContainerView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(195)
        }
        
        let contentView = UIView()
        contentView.backgroundColor = .systemGroupedBackground
        view.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.bottom.equalTo(bottomContentContainerView.snp.top)
            make.horizontalEdges.equalToSuperview()
        }
        view.layoutIfNeeded()
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(imageViewAvailableSize.width)
            make.height.equalTo(imageViewAvailableSize.height)
        }
        
        let ratioViews = PhotoRatio.allCases.map {
            let (rect, ratioView) =  makeRatioView(ratio: $0)
            photoRatioRectangles.append(rect)
            return ratioView
        }
        let stackView = UIStackView(arrangedSubviews: ratioViews)
            .with
            .axis(.horizontal)
            .distribution(.equalSpacing)
            .alignment(.bottom)
            .build()
        bottomContentContainerView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview().inset(40)
            make.top.equalToSuperview().offset(37)
        }
    }
    
    private func setImage(_ image: UIImage?) {
        imageView.image = image
        
        // 이미지 크기에 따라 이미지 뷰 리사이징
        guard let imageSize = image?.size else { return }
        let imageViewHeight = min(imageViewAvailableSize.height, imageSize.height)
        let imageViewWidth = min(imageViewAvailableSize.width, imageSize.width)
        
        var heightScale: CGFloat = 1.0
        var widthScale: CGFloat = 1.0
        if imageViewHeight < imageSize.height {
            widthScale = imageViewHeight/imageSize.height
        }
        if imageViewWidth < imageSize.width {
            heightScale = imageViewWidth/imageSize.width
        }
        
        imageView.snp.remakeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(imageViewWidth * widthScale)
            make.height.equalTo(imageViewHeight * heightScale)
        }
    }
    
    /**
     * 사진 비율 프레임 사각형 뷰 없애기
     * - Author: EJLee1209
     */
    private func clearTransparentRectView() {
        transparentRectView?.removeFromSuperview()
        photoRatio = nil
    }
    
    /**
     * 이미지 Crop 메서드
     * - Author: EJLee1209
     */
    private func cropCurrentImage() {
        guard photoRatio != .full else {
            clearTransparentRectView()
            return
        }
        
        // 사진 편집
        guard let rect = transparentRectView?.transparentRect else { return }
        
        guard let cropImage = resultImageList[currentImageIndex - 1].crop(
            toRect: rect,
            viewWidth: imageView.bounds.width,
            viewHeight: imageView.bounds.height
        ) else { return }
        
        // 크롭된 이미지 원본 저장
        resultImageList[currentImageIndex - 1] = cropImage
        // 크롭된 이미지를 다시 화면 크기에 맞도록 리사이징
        imageList[currentImageIndex-1] = cropImage.resize(newWidth: screenSize.width)
        setImage(currentImage)
        clearTransparentRectView()
    }
    
    /**
     * 사진 비율 사각형 뷰 생성 메서드
     * - Author: EJLee1209
     * - Parameters:
     *   - ratio : PhotoRatio
     * - Returns: 사진 비율 사각형 뷰, 라벨을 포함하는 스택 뷰를 튜플 형태로 리턴
     */
    private func makeRatioView(ratio: PhotoRatio) -> (PhotoRatioRectangle, UIView) {
        let rectangle = PhotoRatioRectangle()
        let label = UILabel()
            .with
            .font(.systemFont(ofSize: 12, weight: .medium))
            .textAlignment(.center)
            .text(ratio.rawValue)
            .build()
        let stackView: UIStackView = .init(arrangedSubviews: [rectangle, label])
            .with
            .axis(.vertical)
            .spacing(4)
            .alignment(.center)
            .build()
        let width: CGFloat
        let height: CGFloat
        switch ratio {
        case .oneToOne:
            width = 26
            height = 26
        case .threeToFour:
            width = 25
            height = 32
        case .fourToThree:
            width = 33
            height = 26
        case .full:
            width = 25
            height = 32
        }
        rectangle.snp.makeConstraints { make in
            make.width.equalTo(width)
            make.height.equalTo(height)
        }
        stackView.accessibilityIdentifier = ratio.rawValue
        rectangle.accessibilityIdentifier = ratio.rawValue
        stackView.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(actionRatioRect(_:)))
        stackView.addGestureRecognizer(tapGesture)
        return (rectangle, stackView)
    }
}

// MARK: - Actions
extension EditPhotoViewController {
    /**
     * 취소/닫기 버튼 액션
     * - Author: EJLee1209
     */
    @objc private func actionCloseBtn(_ sender: UIButton) {
        if isEditingPhoto {
            // 취소
            clearTransparentRectView()
        } else {
            // 닫기
            dismiss(animated: true)
        }
    }
    
    /**
     * 완료 버튼 액션
     * - Author: EJLee1209
     */
    @objc private func actionFinishBtn(_ sender: UIButton) {
        if currentImageIndex == imageList.count {
            if isEditingPhoto {
                cropCurrentImage()
            } else {
                dismiss(animated: true) { [weak self] in
                    guard let self = self else { return }
                    delegate?.finishEditPhoto(resultImages: resultImageList)
                }
            }
        } else {
            cropCurrentImage()
        }
    }
    
    /**
     * 이전/다음 버튼 액션
     * - Author: EJLee1209
     */
    @objc private func actionPrevOrNextBtn(_ sender: UIButton) {
        guard !imageList.isEmpty else { return }
        if (1...imageList.count).contains(currentImageIndex + sender.tag) {
            currentImageIndex += sender.tag
            setImage(currentImage)
            imageIndexLabel.text = "\(currentImageIndex)/\(imageList.count)"
            
            clearTransparentRectView()
        }
    }
    
    /**
     * 하단 사진 비율 사각형 탭 제스처 핸들러
     * - Author: EJLee1209
     */
    @objc private func actionRatioRect(_ gesture: UITapGestureRecognizer) {
        if let ratioRawValue = gesture.view?.accessibilityIdentifier {
            self.photoRatio = PhotoRatio(rawValue: ratioRawValue)
            guard let photoRatio = photoRatio, photoRatio != .full else {
                self.transparentRectView?.removeFromSuperview()
                return
            }
            
            self.transparentRectView?.removeFromSuperview()
            let transparentRectView = TransparentRectView()
            imageView.addSubview(transparentRectView)
            transparentRectView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.transparentRectView = transparentRectView
            view.layoutIfNeeded()
            
            let height = min(imageView.bounds.width, imageView.bounds.height) / 2
            let width = height * photoRatio.ratio
            let size = CGSize(width: width, height: height)
            
            let x = transparentRectView.center.x - width / 2
            let y = transparentRectView.center.y - height / 2
            
            transparentRectView.transparentRect = CGRect(origin: .init(x: x, y: y), size: size)
        }
    }
}
