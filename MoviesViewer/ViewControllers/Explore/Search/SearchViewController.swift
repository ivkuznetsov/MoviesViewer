//
//  SearchViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents
import CommonUtils

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
        collection.footerLoadingInset = CGSize(width: 0, height: 300)
        collection.list.view.set(cellsPadding: 15)
        (collection.list.emptyStateView as! NoObjectsView).header.text = "No Results"
        collection.list.view.keyboardDismissMode = .onDrag
        
        collection.list.set(cellsInfo: [.init(Movie.self, MovieCell.self, { $1.movie = $0 },
                                              size: { [unowned self] _ in
            MovieCell.size(contentWidth: collection.list.view.defaultWidth, space: 15)
        }, action: { [unowned self] in
            presentingViewController?.navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
            return .deselect
        })])
        
        collection.list.showNoData = { [unowned self] in
            lastSearchQuery.count > 2 && $0.isEmpty
        }
        
        collection.loadPage = { [unowned self] offset, _, completion in
            loadingPresenter.helper.run(collection.content == nil ? .opaque : .none, reuseKey: "feed") {
                Movie.search(query: self.searchController.searchBar.text ?? "", offset: offset).convertOnMain { ids, next in
                    PagedContent(ids.objects(), next: next)
                }.completionOnMain(completion)
            }
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, query != lastSearchQuery else { return }
        
        loadingPresenter.helper.cancelOperations()
        lastSearchQuery = query
        
        if query.count > 2 {
            collection.refresh()
        } else {
            collection.content = nil
        }
    }
}
