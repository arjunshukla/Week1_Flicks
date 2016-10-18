//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Arjun Shukla on 10/17/16.
//  Copyright © 2016 arjunshukla. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController, UIScrollViewDelegate {

    @IBOutlet weak var scrollView: UIScrollView!
    let baseURL = "https://image.tmdb.org/t/p/w342"
    var movie = [:] as AnyObject
//    var posterImage : UIImage = as UIImage
    @IBOutlet weak var imgMoviePoster: UIImageView!
    
    @IBOutlet weak var lblMovieDetails: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let contentWidth = scrollView.bounds.width
        let contentHeight = scrollView.bounds.height * 1.5
        scrollView.contentSize = CGSize(width:contentWidth, height:contentHeight)
        scrollView.addSubview(lblMovieDetails)
        lblMovieDetails.text = movie.value(forKey: "overview") as? String
        self.title = movie.value(forKey: "original_title") as? String
        
        let posterPath = movie.value(forKey: "poster_path") as? String
        
        let imageURL = baseURL + posterPath!
        let url = URL(string : imageURL)
        
        self.imgMoviePoster.setImageWith(url!)
        
        // Do any additional setup after loading the view.
    }

    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return lblMovieDetails
    }

}
