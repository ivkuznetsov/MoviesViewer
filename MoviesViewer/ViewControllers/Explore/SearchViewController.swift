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
    
    private let paging = Paging<Movie>()
    private let collection = PagingCollection.make(refreshControl: false) {
        $0.header.text = "No Results"
    }
    
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
        collection.list.view.keyboardDismissMode = .onDrag
        collection.list.showNoData = { [unowned self] in
            lastSearchQuery.count > 2 && $0.numberOfItems == 0
        }
        
        collection.set(paging: paging) { [weak self] items in
                .with {
                    $0.addSection(items) {
                        self?.presentingViewController?
                            .navigationController?
                            .pushViewController(MovieDetailsViewController(movie: $0), animated: true)
                    }
                    $0.addLoading()
                }
        }
        
        paging.set(loadPage: { [weak self] offset in
            try await Movie.search(query: self?.searchController.searchBar.text ?? "", offset: offset).content
        }, with: loadingPresenter.helper)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, query != lastSearchQuery else { return }
        
        loadingPresenter.helper.cancelOperations()
        lastSearchQuery = query
        
        if query.count > 2 {
            paging.refresh()
        } else {
            paging.content = .empty
        }
    }
}
