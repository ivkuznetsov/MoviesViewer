//
//  ExploreViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents

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
        let space: CGFloat = 15
        
        collection.layout?.minimumInteritemSpacing = space
        collection.layout?.sectionInset = UIEdgeInsets(top: 0, left: space, bottom: space, right: space)
        collection.collection.keyboardDismissMode = .onDrag
        
        navigationItem.searchController = searchVC.searchController
        reloadView(false)
        collection.loader.refreshFromBeginning(showRefresh: false)
    }
    
    override func reloadView(_ animated: Bool) {
        collection.set(objects: collection.loader.fetchedItems, animated: animated, diffable: true)
    }
    
    func load(offset: Any?, completion: @escaping ([AnyHashable], Error?, _ offset: Any?)->()) {
        operationHelper.run({ innerCompletion, _ in
            Movie.mostPopular(offset: offset).run { result in
                innerCompletion(result.error)
                completion(result.value?.ids.objects() ?? [], result.error, result.value?.next)
            }
        }, loading: collection.objects.count > 0 ? .none : .opaque, key: "feed")
    }
    
    func createCell(object: AnyHashable, collection: Collection) -> Collection.Cell? {
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
            navigationController?.pushViewController(MovieDetailsViewController(movie: object), animated: true)
        }
        return .deselectCell
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
