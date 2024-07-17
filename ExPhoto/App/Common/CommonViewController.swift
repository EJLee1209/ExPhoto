//
//  CommonViewController.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/18/24.
//

import UIKit
import Combine

typealias DataHandler<T> = (T) -> Void
typealias VoidHandler = () -> Void

class CommonViewController<T>: UIViewController {
    //MARK: - UI
    /// 네비게이션 바
    let navigationBar: CustomNavigationBar = .init()
    
    //MARK: - Properties
    /// 뷰모델
    let viewModel: T
    /// Cancellable 인스턴스 메모리 관리를 위한 Set 컬렉션
    var cancellables: Set<AnyCancellable> = .init()
    
    //MARK: - init
    init(viewModel: T) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        // 네비게이션 바 Delegate 설정
        navigationBar.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //MARK: - Helpers
    ///  커스텀 네비게이션 바 오토레이아웃 설정
    ///  네비게이션 바를 사용할 뷰 컨트롤러에서 명시적으로 호출
    /// - Author: EJLee1209
    func layoutNavigationBar() {
        view.addSubview(navigationBar)
        navigationBar.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(navigationBar.backgroundView.snp.height)
        }
    }
}

//MARK: - CustomNavigationBarDelegate
extension CommonViewController: CustomNavigationBarDelegate {
    func actionBtnBack() {
        navigationController?.popViewController(animated: true)
    }
}
