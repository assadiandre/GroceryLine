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
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var mapView: MKMapView!
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    let manager = CLLocationManager()
    
    @IBOutlet weak var mapTableView: UITableView!
    var mapTableViewDelegate: MapTableViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.requestWhenInUseAuthorization()
        manager.requestAlwaysAuthorization()
        
        let span = MKCoordinateSpan(latitudeDelta: 0.0275, longitudeDelta: 0.0275)
        if let userLocation = manager.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else { // For Testing Purposes
            let phonyLocation = CLLocationCoordinate2D(latitude:37.8444245,longitude:-122.2423746)
            let region = MKCoordinateRegion(center: phonyLocation, span: span)
            mapView.setRegion(region, animated: true)
            
        }
        mapView.showsUserLocation = true
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
        
        var placesClient:GMSPlacesClient?  = GMSPlacesClient()
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt(GMSPlaceField.name.rawValue) |
                                                  UInt(GMSPlaceField.placeID.rawValue))!
        placesClient?.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: fields, callback: {
          (placeLikelihoodList: Array<GMSPlaceLikelihood>?, error: Error?) in
          if let error = error {
            print("An error occurred: \(error.localizedDescription)")
            return
          }

          if let placeLikelihoodList = placeLikelihoodList {
            for likelihood in placeLikelihoodList {
              let place = likelihood.place
              print("Current Place name \(String(describing: place.name)) at likelihood \(likelihood.likelihood)")
              print("Current PlaceID \(String(describing: place.placeID))")
            }
          }
        })

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
    

}

extension ViewController: GMSAutocompleteResultsViewControllerDelegate {
    func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
        
        searchController?.isActive = false

        // 2
        mapView.removeAnnotations(mapView.annotations)

        // 3
        let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        let region = MKCoordinateRegion(center: place.coordinate, span: span)
        
        print(place.coordinate)
        mapView.setRegion(region, animated: true)

        // 4
        let annotation = MKPointAnnotation()
        annotation.coordinate = place.coordinate
        annotation.title = place.name
        annotation.subtitle = place.formattedAddress
        mapView.addAnnotation(annotation)
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
        
