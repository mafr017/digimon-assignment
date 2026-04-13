//
//  DigimonListViewController.swift
//  digimon-assignment
//
//  Created by Muhammad Aditya Fathur Rahman on 12/04/26.
//

import Foundation
import UIKit
import SkeletonView

final class DigimonListViewController: UIViewController {

    var viewModel = AppDependencyInjection.shared.digimonListViewModel()
    
    private var searchDebounceTimer: Timer?
    private var isLoadingMore = false
    
    // search bar
    private let searchBar: UISearchBar = {
        let sb = UISearchBar()
        sb.placeholder = "Cari Digimon..."
        sb.searchBarStyle = .minimal
        sb.translatesAutoresizingMaskIntoConstraints = false
        return sb
    }()
    
    // btn attribute
    private let attributeButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Attribute ▾"
        config.cornerStyle = .medium
        config.baseForegroundColor = .systemBlue
        let btn = UIButton(configuration: config)
        btn.isEnabled = false
        return btn
    }()

    // btn level
    private let levelButton: UIButton = {
        var config = UIButton.Configuration.tinted()
        config.title = "Level ▾"
        config.cornerStyle = .medium
        config.baseForegroundColor = .systemBlue
        let btn = UIButton(configuration: config)
        btn.isEnabled = false
        return btn
    }()

    // view filter
    private let filterStackView: UIStackView = {
        let sv = UIStackView()
        sv.axis = .horizontal
        sv.spacing = 10
        sv.distribution = .fillEqually
        sv.translatesAutoresizingMaskIntoConstraints = false
        return sv
    }()

    // list view
    private lazy var collectionView: UICollectionView = {
        let cv = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        cv.backgroundColor = .systemGroupedBackground
        cv.isSkeletonable = true
        cv.delegate = self
        cv.dataSource = self
        cv.register(DigimonCell.self, forCellWithReuseIdentifier: DigimonCell.identifier)
        cv.register(
            LoadingFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: LoadingFooterView.identifier
        )
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()

    // Error View
    private let errorView: ErrorView = {
        let v = ErrorView()
        v.isHidden = true
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()

    // digimon not found view
    private let emptyLabel: UILabel = {
        let lbl = UILabel()
        lbl.text = "Digimon tidak ditemukan"
        lbl.font = .systemFont(ofSize: 15, weight: .medium)
        lbl.textColor = .secondaryLabel
        lbl.textAlignment = .center
        lbl.isHidden = true
        lbl.translatesAutoresizingMaskIntoConstraints = false
        return lbl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupStructureView()
        setupConstraints()
        bindViewModel()
        viewModel.initialLoad()
    }

    private func setupView() {
        view.backgroundColor = .systemGroupedBackground
        navigationController?.navigationBar.prefersLargeTitles = false

        searchBar.delegate = self
        errorView.onRetry = { [weak self] in
            self?.viewModel.initialLoad()
        }
    }

    private func setupStructureView() {
        filterStackView.addArrangedSubview(attributeButton)
        filterStackView.addArrangedSubview(levelButton)

        view.addSubview(searchBar)
        view.addSubview(filterStackView)
        view.addSubview(collectionView)
        view.addSubview(errorView)
        view.addSubview(emptyLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),

            filterStackView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 4),
            filterStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            filterStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            filterStackView.heightAnchor.constraint(equalToConstant: 36),

            collectionView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            errorView.topAnchor.constraint(equalTo: filterStackView.bottomAnchor),
            errorView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            errorView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            errorView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            emptyLabel.centerXAnchor.constraint(equalTo: collectionView.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: collectionView.centerYAnchor)
        ])
    }

    private func makeLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 12
        let totalWidth = UIScreen.main.bounds.width
        let itemWidth = (totalWidth - spacing * 3) / 2
        
        layout.itemSize = CGSize(width: itemWidth, height: itemWidth + 44)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        layout.sectionInset = UIEdgeInsets(top: spacing, left: spacing, bottom: spacing, right: spacing)
        layout.footerReferenceSize = CGSize(width: totalWidth, height: 50)
        return layout
    }

    private func bindViewModel() {
        viewModel.onStateChanged = { [weak self] state in
            guard let self else { return }
            switch state {
            case .idle:
                break

            case .loading:
                self.errorView.isHidden = true
                self.emptyLabel.isHidden = true

                if self.viewModel.digimons.isEmpty {
                    self.collectionView.showAnimatedGradientSkeleton(
                        usingGradient: .init(baseColor: .systemGray5),
                        transition: .crossDissolve(0.3)
                    )
                }

            case .success:
                self.collectionView.hideSkeleton(reloadDataAfter: false)
                self.collectionView.reloadData()
                self.errorView.isHidden = true
                self.emptyLabel.isHidden = true

            case .empty:
                self.collectionView.hideSkeleton(reloadDataAfter: false)
                self.collectionView.reloadData()
                self.emptyLabel.isHidden = false
                self.errorView.isHidden = true

            case .error(let error):
                self.collectionView.hideSkeleton(reloadDataAfter: false)
                self.errorView.isHidden = false
                self.emptyLabel.isHidden = true
                self.errorView.configure(message: error.errorDescription ?? "Terjadi kesalahan")
            }
        }

        viewModel.onLoadMoreCompleted = { [weak self] in
            guard let self else { return }
            self.isLoadingMore = false
            self.collectionView.reloadData()
        }

        viewModel.onFiltersLoaded = { [weak self] in
            self?.setupFilterMenus()
        }
    }

    private func setupFilterMenus() {
        
        // Attribute Section
        var attrActions: [UIAction] = [
            UIAction(title: "Semua Attribute") { [weak self] _ in
                guard let self else { return }
                self.viewModel.applyFilter(attribute: nil, level: self.viewModel.selectedLevel)
                self.attributeButton.titleLabel?.text = "Attribute ▾"
            }
        ]

        attrActions += viewModel.attributes.map { attr in
            UIAction(title: attr.name!) { [weak self] _ in
                guard let self else { return }
                self.viewModel.applyFilter(attribute: attr.name!, level: self.viewModel.selectedLevel)
                self.attributeButton.titleLabel?.text = "\(attr.name!) ▾"
            }
        }

        attributeButton.menu = UIMenu(title: "Filter Attribute", children: attrActions)
        attributeButton.showsMenuAsPrimaryAction = true
        attributeButton.isEnabled = true

        // Level Section
        var levelActions: [UIAction] = [
            UIAction(title: "Semua Level") { [weak self] _ in
                guard let self else { return }
                self.viewModel.applyFilter(attribute: self.viewModel.selectedAttribute, level: nil)
                self.levelButton.titleLabel?.text = "Level ▾"
            }
        ]

        levelActions += viewModel.levels.map { lvl in
            UIAction(title: lvl.name!) { [weak self] _ in
                guard let self else { return }
                self.viewModel.applyFilter(attribute: self.viewModel.selectedAttribute, level: lvl.name!)
                self.levelButton.titleLabel?.text = "\(lvl.name!) ▾"
            }
        }

        levelButton.menu = UIMenu(title: "Filter Level", children: levelActions)
        levelButton.showsMenuAsPrimaryAction = true
        levelButton.isEnabled = true
    }
}

// MARK: - UICollectionViewDataSource
extension DigimonListViewController: UICollectionViewDataSource {

    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        viewModel.digimons.count
    }

    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: DigimonCell.identifier,
            for: indexPath
        ) as! DigimonCell
        cell.configure(with: viewModel.digimons[indexPath.item])
        return cell
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionFooter else {
            return UICollectionReusableView()
        }
        let footer = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: LoadingFooterView.identifier,
            for: indexPath
        ) as! LoadingFooterView

        isLoadingMore ? footer.startAnimating() : footer.stopAnimating()
        return footer
    }
}

extension DigimonListViewController: UICollectionViewDelegate {

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY       = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight   = scrollView.frame.height

        guard contentHeight > 0,
              offsetY > contentHeight - frameHeight * 1.2,
              !isLoadingMore else { return }

        isLoadingMore = true
        viewModel.loadMore()
    }

    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let digimon = viewModel.digimons[indexPath.item]
        let detailVC = DigimonDetailViewController()
        detailVC.viewModel = AppDependencyInjection.shared.digimonDetailViewModel(digimonId: digimon.id!)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

extension DigimonListViewController: SkeletonCollectionViewDataSource {

    func collectionSkeletonView(
        _ skeletonView: UICollectionView,
        cellIdentifierForItemAt indexPath: IndexPath
    ) -> ReusableCellIdentifier {
        DigimonCell.identifier
    }

    func collectionSkeletonView(
        _ skeletonView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int { 8 }
}

extension DigimonListViewController: UISearchBarDelegate {

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchDebounceTimer?.invalidate()
        searchDebounceTimer = Timer.scheduledTimer(
            withTimeInterval: 0.5,
            repeats: false
        ) { [weak self] _ in
            self?.viewModel.applySearch(searchText)
        }
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        viewModel.applySearch(nil)
    }

    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        if searchBar.text?.isEmpty == true {
            searchBar.setShowsCancelButton(false, animated: true)
        }
    }
}
