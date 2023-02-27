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
    
    private let paging = Paging<Movie>()
    private let collection = PagingCollection(list: Collection())
    
    private let searchVC = SearchViewController()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        title = "Movies Viewer"
        navigationItem.backButtonTitle = "Back"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collection.list.attachTo(view)
        collection.list.view.keyboardDismissMode = .onDrag
        
        paging.firstPageCache = (save: {
            let items = ($0 as? [Movie])?.compactMap { $0.objectID.uriRepresentation().absoluteString }
            UserDefaults.standard.set(items, forKey: "firstPage")
        }, load: {
            let ids = UserDefaults.standard.array(forKey: "firstPage") ?? []
            return ids.compactMap { Movie.with(uri: URL(string: $0 as! String)!) }
        })
        
        collection.set(paging: paging) { [weak self] items in
                .with {
                    $0.addSection(items) {
                        self?.navigationController?.pushViewController(MovieDetailsViewController(movie: $0), animated: true)
                    }
                    $0.addLoading()
                }
        }
        
        paging.set(loadPage: {
            try await Movie.mostPopular(offset: $0).content
        }, with: loadingPresenter.helper)
        
        navigationItem.searchController = searchVC.searchController
        paging.refresh()
    }
}
