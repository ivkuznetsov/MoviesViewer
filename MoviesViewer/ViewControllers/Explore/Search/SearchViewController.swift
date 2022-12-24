//
//  SearchViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents

class SearchViewController: BaseController, UISearchResultsUpdating, PagingLoaderDelegate, CollectionDelegate {
    
    private(set) var searchController: UISearchController!
    private var collection: PagingCollection!
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
        
        collection = PagingCollection(view: view, pagingDelegate: self)
        collection.loader.footerLoadingInset = CGSize(width: 0, height: 300)
        let space: CGFloat = 15
        
        collection.layout?.minimumInteritemSpacing = space
        collection.layout?.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: space, right: space)
        collection.noObjectsView.title.text = "No Results"
        collection.collection.keyboardDismissMode = .onDrag
    }
    
    override func reloadView(_ animated: Bool) {
        collection.set(objects: collection.loader.fetchedItems, animated: false)
    }
    
    func load(offset: Any?, completion: @escaping ([AnyHashable], Error?, _ offset: Any?)->()) {
        let text = searchController.searchBar.text ?? ""
        
        operationHelper.run({ innerCompletion, _ in
            Movie.search(query: text, offset: offset).run { result in
                innerCompletion(result.error)
                completion(result.value?.ids.objects() ?? [], result.error, result.value?.next)
            }
        }, loading: collection.loader.fetchedItems.count > 0 ? .none : .opaque, key: "feed")
    }
    
    func hasRefreshControl() -> Bool { false }
    
    func shouldShowNoData(_ objects: [AnyHashable], collection: Collection) -> Bool {
        lastSearchQuery.count > 2 && self.collection.loader.fetchedItems.isEmpty
    }
    
    func createCell(object: AnyHashable, collection: Collection) -> UICollectionView.Cell? {
        if let object = object as? Movie {
            return .init(MovieCell.self, { $0.movie = object })
        }
        return nil
    }
    
    func cellSizeFor(object: AnyHashable, collection: Collection) -> CGSize? {
        MovieCell.size(contentWidth: collection.collection.width, space: 15)
    }
    
    func action(object: AnyHashable, collection: Collection) -> Collection.Result? {
        if let object = object as? Movie {
            presentingViewController?.navigationController?.pushViewController(MovieDetailsViewController(movie: object), animated: true)
        }
        return .deselect
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text, query != lastSearchQuery else { return }
        
        operationHelper.cancelOperations()
        lastSearchQuery = query
        
        if query.count > 2 {
            collection.loader.refreshFromBeginning(showRefresh: false)
        } else {
            collection.loader.set(fetchedItems: [], offset: nil)
            reloadView(false)
        }
    }
}
