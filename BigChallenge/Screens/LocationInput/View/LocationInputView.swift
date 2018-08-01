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
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    @IBOutlet weak var accessibilityMapView: UIView!
    
    // MARK: - Public
    public weak var delegate: LocationInputDelegate?
    
    private(set) var outputlocation: CLCircularRegion? {
        didSet {
            delegate?.locationInput(self, didFind: outputlocation!, arriving: arriving)
        }
    }
    private(set) var arriving: Bool = true
    
    // MARK: - Internal
    var tableViewData: [MKMapItem] = []
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControl()
        setupLocationManager()
        setupSearchBar()
        setupMapView()
        setupTableView()
    }
    
    @IBAction func segmentedControlSelected(_ sender: Any) {
        guard let location = outputlocation else { return }
        delegate?.locationInput(self, didFind: location, arriving: arriving)
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
        mapView.layer.cornerRadius = 6.3
        mapView.delegate = self
        
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

extension LocationInputView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? MKCircle {
            let circleRenderer = MKCircleRenderer(circle: overlay)
            
            circleRenderer.fillColor = UIColor.blue.withAlphaComponent(0.2)
            circleRenderer.strokeColor = UIColor.blue.withAlphaComponent(0.8)
            circleRenderer.lineWidth = 3
            
            return circleRenderer
        } else {
            return MKOverlayRenderer()
        }
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
        
        locationManager.stopUpdatingLocation()
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        tableView.isHidden = true
        searchBar.resignFirstResponder() // dismiss keyboard
        
        let circularRegion = CLCircularRegion(center: center,
                                      radius: 100,
                                      identifier: "searchResultLocation")
        
        let span = MKCoordinateSpanMake(0.01, 0.01)
        let region = MKCoordinateRegion(center: location.coordinate,
                                        span: span)
        
        let circle = MKCircle(center: circularRegion.center,
                              radius: circularRegion.radius)
        
        let point = MKPointAnnotation()
        point.coordinate = center
        
        //"\(Int(circularRegion.radius).description) meters from \(place.placemark.name ?? "desired location")"
        let localizedString = Strings.LocationInputView.accessibilityValueMap
        accessibilityMapView.accessibilityValue = String.localizedStringWithFormat(localizedString,
                                                                                   Int(circularRegion.radius),
                                                                                   (place.placemark.name ?? "desired location"))
        mapView.addAnnotation(point)
        mapView.showsUserLocation = false
        mapView.add(circle)
        mapView.setRegion(region, animated: true)
        outputlocation = circularRegion
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

extension LocationInputView: StoryboardInstantiable {
    static var viewControllerID: String {
        return "LocationInputView"
    }
    
    static var storyboardIdentifier: String {
        return "LocationInputView"
    }
}
