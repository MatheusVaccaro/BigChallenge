//
//  LocationInputViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 27/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import MapKit

protocol LocationInputDelegate: class {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool)
}

class LocationInputView: UIViewController {

    // MARK: - Storyboard
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: RadiusMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var accessibilityMapView: UIView!
    
    // MARK: - Public
    public weak var delegate: LocationInputDelegate?
    
    private(set) var outputlocation: CLCircularRegion? {
        didSet {
            delegate?.locationInput(self, didFind: outputlocation!, arriving: arriving)
        }
    }
    
    private(set) var arriving: Bool = true {
        didSet {
            guard let location = outputlocation else { return }
            mapView.arriving = arriving
            delegate?.locationInput(self, didFind: location, arriving: arriving)
        }
    }
    
    // MARK: - Internal
    fileprivate var tableViewData: [MKMapItem] = []
    fileprivate let locationManager = CLLocationManager()
    fileprivate var placeName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControl()
        setupLocationManager()
        setupSearchBar()
        setupMapView()
        setupTableView()
    }
    
    @IBAction func segmentedControlSelected(_ sender: Any) {
        arriving = segmentedControl.selectedSegmentIndex == 0
    }
    
    fileprivate func setupSegmentedControl() {
        let arrivingString = Strings.LocationInputView.arrivingString
        let leavingString = Strings.LocationInputView.leavingString
        
        segmentedControl.setTitle(arrivingString, forSegmentAt: 0)
        segmentedControl.setTitle(leavingString, forSegmentAt: 1)
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        locationManager.requestLocation()
    }
    
    fileprivate func setupSearchBar() {
        searchBar.delegate = self
        
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        
        searchBar.accessibilityHint = Strings.LocationInputView.accessibilityHintSearchBar
    }
    
    fileprivate func setupMapView() {
        mapView.outputDelegate = self
        mapView.layer.cornerRadius = 6.3
        mapView.accessibilityElementsHidden = true

        accessibilityMapView.isAccessibilityElement = true
        accessibilityMapView.accessibilityLabel =
            Strings.LocationInputView.accessibilitylabelMap
        accessibilityMapView.accessibilityValue =
            Strings.LocationInputView.accessibilityValueEmptyMap
    }
    
    fileprivate func setupTableView() {
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        
        searchResultsTableView.isHidden = true
        searchResultsTableView.layer.cornerRadius = 6.3
    }
}

extension LocationInputView: UISearchBarDelegate {
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else { return }
            
            self.tableViewData = response.mapItems
            self.searchResultsTableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = true
    }
}

extension LocationInputView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell",
                                                 for: indexPath)
        
        cell.textLabel?.text = tableViewData[indexPath.row].name
        cell.detailTextLabel?.text = tableViewData[indexPath.row].placemark.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
}

extension LocationInputView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = tableViewData[indexPath.row]
        guard let location = place.placemark.location else { return }
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        locationManager.stopUpdatingLocation()
        tableView.isHidden = true
        searchBar.resignFirstResponder() // dismiss keyboard
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        let circle = MKCircle(center: center, radius: 100)
        
        mapView.showsUserLocation = false
        placeName = (place.placemark.name ?? "desired location")
        mapView.add(circle)
    }
}

extension LocationInputView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let span = MKCoordinateSpanMake(0.05, 0.05)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func locationManager(manager: CLLocationManager,
                                 didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        print("error: \(error)")
    }
}

extension LocationInputView: RadiusMapViewDelegate {
    func radiusMapView(_ radiusMapView: RadiusMapView, didFind region: CLCircularRegion) {
        let localizedString = Strings.LocationInputView.accessibilityValueMap
        accessibilityMapView.accessibilityValue = String.localizedStringWithFormat(localizedString,
                                                                                   Int(region.radius),
                                                                                   placeName) //TODO
        outputlocation = region
        print(region.radius)
    }
    
}

extension LocationInputView: StoryboardInstantiable {
    static var viewControllerID: String {
        return "LocationInputView"
    }
    
    static var storyboardIdentifier: String {
        return "LocationInputView"
    }
}
