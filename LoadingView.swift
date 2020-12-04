//
//  LoadingView.swift
//
//  Created by tomieq on 17.08.2018.
//  Copyright © 2018 tomieq. All rights reserved.
//

import UIKit

class LoadingView: UIView {
    
    private let overlay: UIView = {
        let v = UIView()
        v.backgroundColor = .white
        return v
    }()
    
    private let progressIndicator: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.whiteLarge)
        v.color = .gray
        v.startAnimating()
        return v
    }()
    
    private let info: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        return label
    }()
    
    static func on(parentView: UIView, info: String? = nil) -> LoadingView {
        let v = LoadingView(frame: parentView.frame)
        v.info.text = info
        parentView.addSubview(v, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
            ])
        return v
    }

    static func fullWindow(info: String? = nil) -> LoadingView {
        guard let parentView = UIApplication.shared.keyWindow else { fatalError() }
        let v = LoadingView(frame: parentView.frame)
        v.info.text = info
        parentView.addSubview(v, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
            ])
        return v
    }
    
    private override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(self.overlay, constraints: [
            equal(\.leadingAnchor),
            equal(\.trailingAnchor),
            equal(\.topAnchor),
            equal(\.bottomAnchor)
            ])
        self.overlay.addSubview(self.progressIndicator, constraints: [
            equal(\.centerYAnchor),
            equal(\.centerXAnchor)
            ])
        
        self.overlay.addSubview(self.info, constraints: [
            equal(\.topAnchor, anchor: self.progressIndicator.bottomAnchor, constant: 16.0),
            equal(\.centerXAnchor)
            ])
    }

}
