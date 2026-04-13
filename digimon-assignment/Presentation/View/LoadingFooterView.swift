//
//  LoadingFooterView.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 12/04/26.
//

import Foundation
import UIKit

final class LoadingFooterView: UICollectionReusableView {

    static let identifier = "LoadingFooterView"

    private let spinner: UIActivityIndicatorView = {
        let s = UIActivityIndicatorView(style: .medium)
        s.hidesWhenStopped = true
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("Programmatic only")
    }

    func startAnimating() { spinner.startAnimating() }
    func stopAnimating()  { spinner.stopAnimating() }
}
