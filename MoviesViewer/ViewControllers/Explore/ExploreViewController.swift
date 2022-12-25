//
//  ExploreViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents
import CommonUtils

class ExploreViewController: BaseController, PagingLoaderDelegate, CollectionDelegate, PagingCachable {
    
    private var collection: PagingCollection!
    private let searchVC = SearchViewController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Movies Viewer"
        navigationItem.backButtonTitle = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection = PagingCollection(view: view, pagingDelegate: self)
        collection.loader.footerLoadingInset = CGSize(width: 0, height: 300)
        collection.list.set(cellsPadding: 15)
        collection.list.keyboardDismissMode = .onDrag
        
        navigationItem.searchController = searchVC.searchController
        reloadView(false)
        collection.loader.refresh(showLoading: false)
    }
    
    override func reloadView(_ animated: Bool) {
        collection.set(collection.loader.fetchedItems, animated: animated)
    }
    
    func load(offset: Any?, showLoading: Bool, completion: @escaping ([AnyHashable]?, Error?, Any?) -> ()) {
        operationHelper.run({ innerCompletion, _ in
            Movie.mostPopular(offset: offset).run { result in
                innerCompletion(result.error)
                completion(result.value?.ids.objects() ?? [], result.error, result.value?.next)
            }
        }, loading: collection.objects.count > 0 ? .none : .opaque, key: "feed")
    }
    
    func createCell(object: AnyHashable, collection: Collection) -> UICollectionView.Cell? {
        if let object = object as? Movie {
            return .init(MovieCell.self, { $0.movie = object })
        }
        return nil
    }
    
    func cellSizeFor(object: AnyHashable, collection: Collection) -> CGSize? {
        MovieCell.size(contentWidth: collection.list.defaultWidth, space: 15)
    }
    
    func action(object: AnyHashable, collection: Collection) -> Collection.Result? {
        if let object = object as? Movie {
            navigationController?.pushViewController(MovieDetailsViewController(movie: object), animated: true)
        }
        return .deselect
    }
    
    func saveFirstPageInCache(objects: [AnyHashable]) {
        UserDefaults.standard.set((objects as? [Movie])?.compactMap { $0.objectID.uriRepresentation().absoluteString }, forKey: "firstPage")
    }
    
    func loadFirstPageFromCache() -> [AnyHashable] {
        if let ids = UserDefaults.standard.array(forKey: "firstPage") {
            return ids.compactMap { Movie.object(uri: URL(string: $0 as! String)!) }
        }
        return []
    }
}
