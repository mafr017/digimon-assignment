//
//  DigimonDetailViewController.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 12/04/26.
//

import Foundation
import UIKit
import Kingfisher
import SkeletonView

final class DigimonDetailViewController: UIViewController {

    var viewModel: DigimonDetailViewModel!

    private let scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.showsVerticalScrollIndicator = false
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let contentStack: UIStackView = {
        let sv = UIStackView()
        sv.axis = .vertical
        sv.spacing = 16
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    private let digimonImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.backgroundColor = .secondarySystemBackground
        iv.layer.cornerRadius = 20
        iv.isSkeletonable = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    // MARK: - Loading / Error
    private let loadingView: UIActivityIndicatorView = {
        let v = UIActivityIndicatorView(style: .large)
        v.hidesWhenStopped = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    private let errorView: ErrorView = {
        let v = ErrorView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemGroupedBackground
        navigationItem.largeTitleDisplayMode = .never

        setupLoadingAndError()
        bindViewModel()
        viewModel.load()
    }

    private func setupLoadingAndError() {
        view.addSubview(loadingView)
        view.addSubview(errorView)

        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            errorView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        errorView.onRetry = { [weak self] in
            self?.errorView.isHidden = true
            self?.viewModel.load()
        }
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .loading:
                self.loadingView.startAnimating()
                self.errorView.isHidden = true

            case .success(let detail):
                self.loadingView.stopAnimating()
                self.errorView.isHidden = true
                self.title = detail.name
                self.buildUI(with: detail)

            case .error(let error):
                self.loadingView.stopAnimating()
                self.errorView.isHidden = false
                self.errorView.configure(message: error.errorDescription ?? "Terjadi kesalahan")
            }
        }
    }

    private func buildUI(with detail: Digimon) {
        view.addSubview(scrollView)
        scrollView.addSubview(contentStack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -32),
            contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])

        contentStack.addArrangedSubview(digimonImageView)
        digimonImageView.heightAnchor.constraint(equalToConstant: 240).isActive = true
        digimonImageView.kf.setImage(with: URL(string: (detail.images?[0].href)!))

        let tagSection = makeSectionCard(title: "Info") {
            let tags = [(detail.levels?[0].level)!, (detail.attributes?[0].attribute),(detail.types?[0].type)!]
            return self.makeTagCloud(items: tags as! [String])
        }
        contentStack.addArrangedSubview(tagSection)

        if detail.descriptions != nil {
            let descSection = makeSectionCard(title: "Deskripsi") {
                let lbl = UILabel()
                lbl.text = detail.descriptions?[1].description
                lbl.font = .systemFont(ofSize: 14)
                lbl.textColor = .secondaryLabel
                lbl.numberOfLines = 0
                return lbl
            }
            contentStack.addArrangedSubview(descSection)
        }

        if detail.skills != nil {
            let skillSection = makeSectionCard(title: "Skills") {
                let stack = UIStackView()
                stack.axis = .vertical
                stack.spacing = 12
                detail.skills?.prefix(3).forEach { skill in
                    stack.addArrangedSubview(self.makeSkillRow(skill))
                }
                return stack
            }
            contentStack.addArrangedSubview(skillSection)
        }
    }


    private func makeSectionCard(title: String, content: () -> UIView) -> UIView {
        let container = UIView()
        container.backgroundColor = .secondarySystemBackground
        container.layer.cornerRadius = 14
        container.clipsToBounds = true

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        let contentView = content()
        contentView.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(titleLabel)
        container.addSubview(contentView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),

            contentView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14)
        ])

        return container
    }

    private func makeTagCloud(items: [String], color: UIColor = .systemBlue) -> UIView {
        let outer = UIStackView()
        outer.axis = .vertical
        outer.spacing = 8

        var currentRow = UIStackView()
        currentRow.axis = .horizontal
        currentRow.spacing = 8

        var rowCount = 0
        items.forEach { item in
            if rowCount == 3 {
                currentRow.addArrangedSubview(UIView())
                outer.addArrangedSubview(currentRow)
                currentRow = UIStackView()
                currentRow.axis = .horizontal
                currentRow.spacing = 8
                rowCount = 0
            }
            currentRow.addArrangedSubview(makeTag(item, color: color))
            rowCount += 1
        }
        if rowCount > 0 {
            currentRow.addArrangedSubview(UIView())
            outer.addArrangedSubview(currentRow)
        }

        return outer
    }
    
    private func makeTag(_ text: String, color: UIColor = .systemBlue) -> UIView {
        let container = UIView()
        container.backgroundColor = color.withAlphaComponent(0.12)
        container.layer.cornerRadius = 8

        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = color
        label.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(label)
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
            label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10)
        ])
        return container
    }
    
    private func makeSkillRow(_ skill: Skill) -> UIView {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4

        let nameLabel = UILabel()
        nameLabel.text = skill.skill
        nameLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        nameLabel.textColor = .label

        let descLabel = UILabel()
        descLabel.text = skill.description
        descLabel.font = .systemFont(ofSize: 13)
        descLabel.textColor = .secondaryLabel
        descLabel.numberOfLines = 0

        stack.addArrangedSubview(nameLabel)
        stack.addArrangedSubview(descLabel)

        let separator = UIView()
        separator.backgroundColor = .separator
        separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        stack.addArrangedSubview(separator)

        return stack
    }
}
