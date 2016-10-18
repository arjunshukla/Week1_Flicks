//
//  ViewController.swift
//  Flicks
//
//  Created by Arjun Shukla on 10/17/16.
//  Copyright © 2016 arjunshukla. All rights reserved.
//

import UIKit
import AFNetworking

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var viewNetworkError: UIView!
    
    @IBOutlet weak var tableViewMovies: UITableView!
    
    var arrMoviesFeed : Array<AnyObject> = []
    
    let refreshControl = UIRefreshControl()
    
    var isMoreDataLoading = false
    
    var loadingMoreView:InfiniteScrollActivityView?

    let baseURL = "https://image.tmdb.org/t/p/w342"
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize a UIRefreshControl
        
        self.title = "Now Playing"
        
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        
        // add refresh control to table view
        tableViewMovies.insertSubview(refreshControl, at: 0)
        fetchFeed(refreshControl: refreshControl)
        
        //        let tableFooterView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 320, height: 50))//UIView(frame: CGRectMake(0, 0, 320, 50))
        //        let loadingView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        //        loadingView.startAnimating()
        //        loadingView.center = tableFooterView.center
        //        tableFooterView.addSubview(loadingView)
        //        self.tableViewMovies.tableFooterView = tableFooterView
        
        tableViewMovies.delegate = self
        tableViewMovies.dataSource = self
        tableViewMovies.rowHeight = 200
//                tableViewMovies.estimatedRowHeight = 320
//                tableViewMovies.rowHeight = UITableViewAutomaticDimension
        
        // Set up Infinite Scroll loading indicator
        let frame = CGRect(x:0, y:tableViewMovies.contentSize.height, width: tableViewMovies.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.isHidden = true
        tableViewMovies.addSubview(loadingMoreView!)
        
        var insets = tableViewMovies.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableViewMovies.contentInset = insets
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //    MARK: Table View Data Source Methods...
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrMoviesFeed.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //    MARK: Table View Delegate Methods
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedCell", for: indexPath) as! MovieTableViewCell
        
        let movie = arrMoviesFeed[indexPath.row]
        
//        cell.lblMovieTitle.sizeToFit()
//        cell.lblMovieDetails.sizeToFit()
        cell.lblMovieTitle.text = movie.value(forKey: "original_title") as? String
        cell.lblMovieDetails.text = movie.value(forKey: "overview") as? String
        
        
        if let posterPath = movie.value(forKey: "poster_path") as? String {
        
        let imageURL = baseURL + posterPath
        let url = URL(string : imageURL)
        
        cell.imgMoviePoster.setImageWith(url!)
        } else {
            // No poster image. Can either set to nil (no image) or a default movie poster image
            // that you include as an asset
            cell.imgMoviePoster.image = nil
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated:true)
    }
    
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 150.0
//    }
//    
    // MARK: Infinite Scroll
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableViewMovies.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableViewMovies.bounds.size.height
            
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableViewMovies.isDragging) {
                isMoreDataLoading = true
                
                // Update position of loadingMoreView, and start loading indicator
                let frame = CGRect(x: 0, y: tableViewMovies.contentSize.height, width: tableViewMovies.bounds.size.width, height: InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                
                // ... Code to load more results ...
                fetchFeed(refreshControl: refreshControl)
            }
        }
    }
    
    // MARK: Network Calls
    func fetchFeed(refreshControl: UIRefreshControl) {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string:"https://api.themoviedb.org/3/movie/now_playing?api_key=\(apiKey)")
        let request = URLRequest(url: url!)
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )
        
        let task : URLSessionDataTask = session.dataTask(with: request,completionHandler: { (dataOrNil, response, error) in
            if let data = dataOrNil {
                if let responseDictionary = try! JSONSerialization.jsonObject(with: data, options:[]) as? NSDictionary {
                    NSLog("response: \(responseDictionary)")
                    self.isMoreDataLoading = false
                    // Stop the loading indicator
                    self.loadingMoreView!.stopAnimating()
                    self.arrMoviesFeed += responseDictionary.value(forKey: "results") as! Array<AnyObject>
                    self.tableViewMovies.reloadData()
                    refreshControl.endRefreshing()
                    self.viewNetworkError.isHidden = true
                }
            } else if ((error) != nil) {
                self.viewNetworkError.isHidden = false
            }
        });
        task.resume()
    }
    
    func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchFeed(refreshControl: refreshControl)
        //        refreshControl.endRefreshing()
        
    }

    
    // MARK: Navigation methods
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationViewController = segue.destination as! MovieDetailsViewController
        var indexPath = tableViewMovies.indexPathForSelectedRow
        destinationViewController.movie = arrMoviesFeed[(indexPath?.row)!] as! AnyObject
    }
}

