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
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        manager.requestWhenInUseAuthorization()
        let span = MKCoordinateSpan(latitudeDelta: 0.0275, longitudeDelta: 0.0275)
        if let userLocation = manager.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate, span: span)
            mapView.setRegion(region, animated: true)
        } else { // For Testing Purposes
            let phonyLocation = CLLocationCoordinate2D(latitude:37.8444245,longitude:-122.2423746)
            let region = MKCoordinateRegion(center: phonyLocation, span: span)
            mapView.setRegion(region, animated: true)
            
        }
        setupSearchController()
        resultsViewController?.delegate = self

    }

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

