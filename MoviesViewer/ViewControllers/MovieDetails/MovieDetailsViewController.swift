//
//  MovieDetailsViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import UIComponents
import CommonUtils
import Database
import UIKit

class MovieDetailsViewController: BaseController {
    
    private let table = Table()
    @DBObservable private var movie: Movie?
    private let header = MovieHeaderView.loadFromNib()
    
    init(movie: Movie) {
        self.movie = movie
        super.init()
        let button = FavoriteButton()
        button.movie = movie
        navigationItem.rightBarButtonItem = button
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        table.attachTo(view)
        table.view.tableHeaderView = UIView()
        table.view.separatorInset = .zero
        table.set(cellsInfo: [.init(Entry.self, DetailCell.self, { $1.entry = $0 })])
        header.movie = movie
        
        _movie.didChange = { [weak self] replaced in
            self?.reloadView(false)
        }
        reloadView(false)
        
        loadingPresenter.helper.run(movie?.isLoaded == true ? .none : .opaque) { [weak self] in
            self?.movie?.updateDetails()
        }
    }
    
    override func reloadView(_ animated: Bool) {
        guard let movie = movie else {
            navigationController?.popViewController(animated: true)
            return
        }

        var objects: [AnyHashable] = [header]
        
        let addEntry: (String, String?)->() = {
            if let detail = $1, detail.isValid {
                objects.append(Entry(title: $0, detail: detail))
            }
        }
        addEntry("Genres", movie.genres?.joined(separator: ", "))
        addEntry("Companies", movie.companies?.joined(separator: "\n"))
        addEntry("Countries", movie.countries?.joined(separator: "\n"))
        addEntry("Overview", movie.overview )
        
        table.set(objects, animated: animated)
    }
}
