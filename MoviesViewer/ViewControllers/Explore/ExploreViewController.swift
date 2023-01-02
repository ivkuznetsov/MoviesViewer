//
//  ExploreViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import UIComponents
import CommonUtils

class ExploreViewController: BaseController {
    
    private let collection = PagingCollection()
    private let searchVC = SearchViewController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Movies Viewer"
        navigationItem.backButtonTitle = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.list.attachTo(view)
        collection.footerLoadingInset = CGSize(width: 0, height: 300)
        collection.list.list.set(cellsPadding: 15)
        collection.list.list.keyboardDismissMode = .onDrag
        
        collection.list.set(cellsInfo: [.init(Movie.self, MovieCell.self, { $1.movie = $0 },
                                              size: { [unowned self] _ in
            MovieCell.size(contentWidth: collection.list.list.defaultWidth, space: 15)
        }, action: { [unowned self] in
            navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
            return .deselect
        })])
        
        collection.firstPageCache = (save: {
            let items = ($0 as? [Movie])?.compactMap { $0.objectID.uriRepresentation().absoluteString }
            UserDefaults.standard.set(items, forKey: "firstPage")
        }, load: {
            let ids = UserDefaults.standard.array(forKey: "firstPage") ?? []
            return ids.compactMap { Movie.object(uri: URL(string: $0 as! String)!) }
        })
        
        collection.load = { [unowned self] offset, _ in
            loadingPresenter.helper.run(collection.page != nil ? .none : .opaque, reuseKey: "feed") {
                Movie.mostPopular(offset: offset).convertOnMain { ids, next in
                    LoadedPage(ids.objects(), offset: next)
                }
            }
        }
        
        navigationItem.searchController = searchVC.searchController
        collection.refresh()
    }
}
