//
//  ViewController.swift
//  GroceryLine
//
//  Created by Andre Assadi on 4/25/20.
//  Copyright © 2020 AndreAssadiProjects. All rights reserved.
//

import UIKit
import MapKit
import GooglePlaces
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    let manager = CLLocationManager()
    var mapView:GMSMapView?
    var camera:GMSCameraPosition?
    var baseUrl = "https://groceryline.herokuapp.com/"
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var mapTableView: UITableView!
    var mapTableViewDelegate: MapTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()

        setupSearchController()
        resultsViewController?.delegate = self
        
        // Fetch Nearest Data Here
        // Data = .....
        
        // IMPORTANT: phonydata is testing data
        let phonyData:[Int] = [1, 2]
        mapTableViewDelegate = MapTableViewDelegate(data:phonyData)
        mapTableViewDelegate?.didSelectRow = didSelectRow
        mapTableView.delegate = mapTableViewDelegate
        mapTableView.dataSource = mapTableViewDelegate

    }
    
    override func viewDidAppear(_ animated: Bool) {
        var lat:Double = 37.8444245
        var lon:Double = -122.2423746
        
        if let userLocation = manager.location {
            lat = userLocation.coordinate.latitude
            lon = userLocation.coordinate.longitude
        }
        
        camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera!)
        mapView?.isMyLocationEnabled = true
        mainView.addSubview(mapView!)
        
        // GET NEAREST PLACES
        //var testCoords = CLLocationCoordinate2D(latitude:37.8444245,longitude:-122.2423746)
        //fetchNearestPlaces(location:testCoords)
        
        manager.delegate = self
        manager.startUpdatingLocation()

    }
    
    // TableView functions:
    func didSelectRow(dataItem: Int, cell: UITableViewCell) {
        print("User Selected a Row!")
    }
    
    // SearchBar display:
    func setupSearchController() {
        resultsViewController = GMSAutocompleteResultsViewController()
        searchController = UISearchController(searchResultsController: resultsViewController)
        searchController?.searchResultsUpdater = resultsViewController

        let searchBar = searchController!.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        navigationItem.titleView = searchController?.searchBar
        definesPresentationContext = true
        searchController?.hidesNavigationBarDuringPresentation = false
    }
    

    func fetchPlaceData(placeId:String) {
        let urlString = baseUrl + placeId
        print(urlString)
        let url = URL(string: urlString)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!){(data, response, error) in
            if error == nil && data != nil {
                //Parse JSOn
                let decoder = JSONDecoder()
                do {
                    let dataFeed = try decoder.decode(DataFeed.self, from: data!)
                    print("FETCHED DATA: ",dataFeed)
                } catch {
                    print("error",error)
                }
            }
        }
        dataTask.resume()
    }

//    func fetchNearestPlaces( location:CLLocationCoordinate2D ) {
//        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=AIzaSyBb10HJkDvVvJQThvtmulz7gkrzQJCrZAA&location=\(location.latitude),\(location.longitude)&radius=8000&keyword=grocery"
//        let url = URL(string: urlString)
//        let session = URLSession.shared
//        let dataTask = session.dataTask(with: url!){(data, response, error) in
//            if error == nil && data != nil {
//                //Parse JSOn
//                print("FOUND DATA: ")
//                do {
//                    // make sure this JSON is in the format we expect
//                    if let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
//                        // try to read out a string array
//                        print( json["results"] )
//                        print(json.count)
//                    }
//                } catch let error as NSError {
//                    print("Failed to load: \(error.localizedDescription)")
//                }
//
//            }
//        }
//        dataTask.resume()
//    }



}

extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        guard let mapView = mapView else {
            return
        }
        searchController?.isActive = false
        let newLocation = GMSCameraPosition.camera(withLatitude: place.coordinate.latitude,
                                                   longitude: place.coordinate.longitude,
                                             zoom: 10 )
        mapView.camera = newLocation
        mapView.clear()
        
        if let placeId = place.placeID {
            fetchPlaceData(placeId: placeId)
        }
        let position = place.coordinate
        let marker = GMSMarker(position: position)
        marker.title = place.name
        marker.map = mapView
    }
    
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// Example Request:
//        if let url = URL(string: "https://jsonplaceholder.typicode.com/todos/1") {
//            print("WORKED")
//            let task = URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
//                print("DATA:")
//                if let data = data as? JSON {
//                    print(data["userId"])
//                }
//              })
//
//              task.resume()
//        }
        
