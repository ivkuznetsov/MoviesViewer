//
//  SearchViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents
import SharedUIComponents

class SearchViewController: BaseController, UISearchResultsUpdating {
    
    private(set) var searchController: UISearchController!
    private let collection = PagingCollection(hasRefreshControl: false)
    private var lastSearchQuery: String = ""
    
    override init() {
        super.init()
        
        searchController = UISearchController(searchResultsController: self)
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.list.attachTo(view)
        collection.list.view.set(cellsPadding: 15)
        (collection.list.emptyStateView as! NoObjectsView).header.text = "No Results"
        collection.list.view.keyboardDismissMode = .onDrag
        
        collection.list.addCell(for: Movie.self,
                                type: MovieCell.self,
                                fill: { $1.movie = $0 },
                                size: { [unowned self] _ in
            MovieCell.size(contentWidth: collection.list.view.defaultWidth, space: 15)
        }, action: { [unowned self] in
            presentingViewController?.navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
        })
        
        collection.list.showNoData = { [unowned self] in
            lastSearchQuery.count > 2 && $0.isEmpty
        }
        
        collection.paging.set(loadPage: { @MainActor [weak self] offset in
            try await Movie.search(query: self?.searchController.searchBar.text ?? "", offset: offset).content
        }, with: loadingPresenter.helper)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, query != lastSearchQuery else { return }
        
        loadingPresenter.helper.cancelOperations()
        lastSearchQuery = query
        
        if query.count > 2 {
            collection.paging.refresh()
        } else {
            collection.paging.content = .empty
        }
    }
}
