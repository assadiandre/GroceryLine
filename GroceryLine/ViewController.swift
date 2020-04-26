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
        mapTableView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        var lat:Double = 37.8444245
        var lon:Double = -122.2423746
        
        if let userLocation = manager.location {
            lat = userLocation.coordinate.latitude
            lon = userLocation.coordinate.longitude
        }
        
        camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 10.0)
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
    

    func fetchPlaceData(placeId:String,  completion: @escaping(_ data: DataFeed) -> ()) {
        let urlString = baseUrl + placeId
        print(urlString)
        let url = URL(string: urlString)
        let session = URLSession.shared
        let dataTask = session.dataTask(with: url!) { (data, response, error) in
            if error == nil && data != nil {
                //Parse JSOn
                let decoder = JSONDecoder()
                do {
                    let dataFeed = try decoder.decode(DataFeed.self, from: data!)
                    completion(dataFeed)
                } catch {
                    print("error",error)
                }
            }
        }
        dataTask.resume()
    }
    
    func getPopularity(dataFeed:DataFeed) -> Int {
         let date = Date()
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "EEEE"
         let dayOfTheWeekString = dateFormatter.string(from: date)
         let hour = Calendar.current.component(.hour, from: Date())
         var dno = -1

        // Make pop up
         switch dayOfTheWeekString {
         case "Monday":
             dno = 0
             print(String(dataFeed.populartimes[0].name ?? "someday"))
             return Int( dataFeed.populartimes[0].data[hour] )
         case "Tuesday":
             dno = 1
             print(String(dataFeed.populartimes[1].name ?? "someday"))
             return Int(dataFeed.populartimes[1].data[hour])
             // statements
         case "Wednesday":
             dno = 2
             print(String(dataFeed.populartimes[2].name ?? "someday"))
             return Int(dataFeed.populartimes[2].data[hour])
         case "Thursday":
             dno = 3
             print(String(dataFeed.populartimes[3].name ?? "someday"))
             return Int(dataFeed.populartimes[3].data[hour])
         case "Friday":
             dno = 4
             print(String(dataFeed.populartimes[4].name ?? "someday"))
             return Int(dataFeed.populartimes[4].data[hour])
         case "Saturday":
             dno = 5
             print(String(dataFeed.populartimes[5].name ?? "someday"))
             return Int(dataFeed.populartimes[5].data[hour])
         case "Sunday":
             dno = 6
             print(hour)
             print(String(dataFeed.populartimes[6].name ?? "someday"))
             return Int(dataFeed.populartimes[6].data[hour])
         default:
             dno = -1
             // statements
         }
        return 0
    }
    
    func getCurrentPopularity(dataFeed:DataFeed) -> Int? {
        return (dataFeed.current_popularity)
    }
    
    func getHighestAveragePopularity(dataFeed:DataFeed) -> (average:Int, highest:Int) {
        var highest = 0
        var accumulated = 0
        var dividend = 0
        for day in dataFeed.populartimes {
            for val in day.data {
                if val > highest {
                    highest = Int(val)
                }
                accumulated += Int(val)
                if val != 0 {
                    dividend += 1
                }
            }
        }
        return ( average: accumulated / dividend, highest:highest  )
    }
    
    func getLineTime(currentPopularity:Int) -> String { // Random Distribution
        if currentPopularity < 35 {
            return "0-5min"
        } else if currentPopularity < 50 {
            return "10-15min"
        } else if currentPopularity < 70 {
            return "20-25min"
        } else {
            return "25-30min"
        }
    }
    
    func displayCurrentPopularity(dataFeed:DataFeed, place:GMSPlace) {
        let currentPopularity = self.getPopularity(dataFeed: dataFeed)
        var lineTime:String?
        
        if let activePopularity = self.getCurrentPopularity(dataFeed:dataFeed) {
            lineTime = self.getLineTime(currentPopularity: activePopularity)
        } else {
            lineTime = self.getLineTime(currentPopularity: currentPopularity)
        }
        if let placeName = place.name, let lineTime = lineTime {
            let alert = UIAlertController(title: "Line Time", message: "The estimated wait time at \(placeName) is \(lineTime)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    


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
            fetchPlaceData(placeId: placeId){ (data) -> () in
                DispatchQueue.main.async {
                    self.displayCurrentPopularity(dataFeed:data,place:place)
                }
             }
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

