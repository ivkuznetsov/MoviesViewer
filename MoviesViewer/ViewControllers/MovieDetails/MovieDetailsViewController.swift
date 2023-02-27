//
//  MovieDetailsViewController.swift
//  MoviesViewer
//
//  Created by Ilya Kuznetsov on 20/11/2022.
//

import Foundation
import UIComponents
import SharedUIComponents
import Database
import UIKit

class MovieDetailsViewController: BaseController {
    
    private let table = Table()
    private let movie: Movie
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
        header.movie = movie
        
        movie.objectWillChange.sink(receiveValue: { [weak self] in
            DispatchQueue.main.async {
                self?.reloadView(false)
            }
        }).retained(by: self)
        
        reloadView(false)
        
        loadingPresenter.helper.run(movie.isLoaded == true ? .none : .opaque) { [weak self] _ in
            try await self?.movie.updateDetails()
        }
    }
    
    override func reloadView(_ animated: Bool) {
        var entries: [Entry] = []
        
        let addEntry: (String, String?)->() = {
            if let detail = $1, detail.isValid {
                entries.append(Entry(title: $0, detail: detail))
            }
        }
        addEntry("Genres", movie.genres?.joined(separator: ", "))
        addEntry("Companies", movie.companies?.joined(separator: "\n"))
        addEntry("Countries", movie.countries?.joined(separator: "\n"))
        addEntry("Overview", movie.overview )
        
        table.set(.with {
            $0.addSection(header)
            
            $0.addSection(entries, cell: DetailCell.self) {
                $1.entry = $0
            }
        }, animated: animated)
    }
}
