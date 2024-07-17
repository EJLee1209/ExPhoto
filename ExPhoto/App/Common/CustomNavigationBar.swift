//
//  CustomNavigationBar.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit
import SnapKit

// 커스텀 네비게이션 바 Delegate
protocol CustomNavigationBarDelegate: AnyObject {
    ///  네비게이션 바 뒤로가기 버튼 액션
    /// - Author: EJLee1209
    func actionBtnBack()
}

final class CustomNavigationBar: UIView {
    //MARK: - UI
    /// 네비게이션 바 배경 뷰
    let backgroundView: UIView = .init()
    /// 뒤로가기 버튼
    private lazy var btnBack: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(actionBtnBack), for: .touchUpInside)
        return button
    }()
    /// 네비게이션 타이틀 라벨
    let labelNavigationTitle: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    /// 네비게이션 바 왼쪽 아이템 스택 뷰
    private lazy var leftItemStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [btnBack])
        sv.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 15
        return sv
    }()
    /// 네비게이션 바 오른쪽 아이템 스택 뷰
    private let rightItemStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [UIView()])
        sv.setContentHuggingPriority(.defaultLow, for: .horizontal)
        sv.axis = .horizontal
        sv.alignment = .center
        sv.spacing = 15
        return sv
    }()
    
    /// 네비게이션 바 오른쪽 아이템 스택 뷰
    
    //MARK: - Properties
    /// 네비게이션 바 높이
    private let navigationBarHeight: CGFloat
    /// 네비게이션 바 Delegate
    weak var delegate: CustomNavigationBarDelegate?
    
    //MARK: - init
    init(navigationBarHeight: CGFloat = 56) {
        self.navigationBarHeight = navigationBarHeight
        super.init(frame: .zero)
        
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Helpers
    ///  뷰 오토레이아웃 설정
    /// - Author: EJLee1209
    private func layout() {
        addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(navigationBarHeight)
            make.horizontalEdges.equalToSuperview()
        }
        
        [leftItemStackView, rightItemStackView, labelNavigationTitle].forEach { backgroundView.addSubview($0) }
        leftItemStackView.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(backgroundView.safeAreaLayoutGuide.snp.bottom)
            make.left.equalToSuperview().inset(16)
        }
        rightItemStackView.snp.makeConstraints { make in
            make.top.equalTo(backgroundView.safeAreaLayoutGuide.snp.top)
            make.bottom.equalTo(backgroundView.safeAreaLayoutGuide.snp.bottom)
            make.right.equalToSuperview().inset(16)
            make.left.equalTo(leftItemStackView.snp.right).offset(15)
        }
        
        labelNavigationTitle.snp.makeConstraints { make in
            make.center.equalTo(backgroundView.safeAreaLayoutGuide.snp.center)
        }
    }
    
    ///  네비게이션 바 뒤로가기 버튼 숨김/표시 설정
    /// - Author: EJLee1209
    /// - Parameters:
    /// - isHidden: Bool
    func setBackBtnIsHidden(_ isHidden: Bool) {
        btnBack.isHidden = isHidden
    }
    
    ///  네비게이션 바 타이틀 설정
    /// - Author: EJLee1209
    /// - Parameters:
    /// - title: String?
    func setNavigationTitle(_ title: String?) {
        labelNavigationTitle.text = title
    }
    
    /**
     * 네비게이션 바 타이틀 뷰 설정
     * - Author: EJLee1209
     * - Parameters:
     *   - view : UIView
     */
    func setNavigationTitle(_ view: UIView) {
        labelNavigationTitle.isHidden = true
        backgroundView.addSubview(view)
        view.snp.makeConstraints { make in
            make.center.equalTo(backgroundView.safeAreaLayoutGuide.snp.center)
        }
    }
    
    ///  네비게이션 바 타이틀 숨김/표시 설정
    /// - Author: EJLee1209
    /// - Parameters:
    /// - isHidden: Bool
    func setNavigationTitleIsHidden(_ isHidden: Bool) {
        labelNavigationTitle.isHidden = isHidden
    }
    
    ///  네비게이션 바 왼쪽 아이템 추가
    /// - Author: EJLee1209
    /// - Parameters:
    /// - views: [UIView]
    func addLeftItems(_ views: [UIView]) {
        views.forEach { leftItemStackView.addArrangedSubview($0) }
    }
    
    ///  네비게이션 바 오른쪽 아이템 추가
    /// - Author: EJLee1209
    /// - Parameters:
    /// - views: [UIView]
    func addRightItems(_ views: [UIView]) {
        views.forEach { rightItemStackView.addArrangedSubview($0) }
    }
    
    ///  네비게이션 바 배경 색상 설정
    /// - Author: EJLee1209
    /// - Parameters:
    /// - backgroundColor: UIColor
    func setNavigationBarBackgroundColor(_ backgroundColor: UIColor) {
        backgroundView.backgroundColor = backgroundColor
    }
}

//MARK: - Actions
extension CustomNavigationBar {
    ///  네비게이션 바 뒤로가기 버튼 액션
    /// - Author: EJLee1209
    /// - Parameters:
    /// - sender: UIButton
    @objc private func actionBtnBack(_ sender: UIButton) {
        delegate?.actionBtnBack()
    }
}
