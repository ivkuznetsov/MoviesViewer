//
//  ExploreViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 19/11/2022.
//

import UIKit
import SharedUIComponents
import UIComponents

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
        collection.list.view.set(cellsPadding: 15)
        collection.list.view.keyboardDismissMode = .onDrag
        
        collection.list.setCell(for: Movie.self,
                                type: MovieCell.self,
                                fill: { $1.movie = $0 },
                                size: { [unowned self] _ in
            MovieCell.size(contentWidth: collection.list.view.defaultWidth, space: 15)
        }, action: { [unowned self] in
            navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
        })
        
        collection.firstPageCache = (save: {
            let items = ($0 as? [Movie])?.compactMap { $0.objectID.uriRepresentation().absoluteString }
            UserDefaults.standard.set(items, forKey: "firstPage")
        }, load: {
            let ids = UserDefaults.standard.array(forKey: "firstPage") ?? []
            return ids.compactMap { Movie.object(uri: URL(string: $0 as! String)!) }
        })
        
        collection.loadPage = { [unowned self] offset, _, completion in
            loadingPresenter.helper.run(collection.content != nil ? .none : .opaque, reuseKey: "feed") {
                Movie.mostPopular(offset: offset).convertOnMain { ids, next in
                    PagedContent(ids.objects(), next: next)
                }.completionOnMain(completion)
            }
        }
        
        navigationItem.searchController = searchVC.searchController
        collection.refresh()
    }
}
