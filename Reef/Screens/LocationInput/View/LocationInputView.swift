//
//  LocationInputViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 27/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import MapKit

class LocationInputView: UIViewController {

    // MARK: - Storyboard
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: RadiusMapView!
    @IBOutlet weak var searchResultsTableView: UITableView!
    let viewModel = LocationInputViewModel()
    
    var outputlocation: CLCircularRegion? {
        didSet {
            viewModel.delegate?.locationInput(self, didFind: outputlocation!, arriving: arriving)
        }
    }
    
    var arriving: Bool = true {
        didSet {
            if isViewLoaded {
                mapView.arriving = arriving
            }
            guard let location = outputlocation else { return }
            viewModel.delegate?.locationInput(self, didFind: location, arriving: arriving)
        }
    }
    
    // MARK: - Internal
    fileprivate var tableViewData: [MKMapItem] = []
    fileprivate let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSegmentedControl()
        setupLocationManager()
        setupSearchBar()
        setupMapView()
        setupTableView()
        
        if let location = outputlocation {
            addCircle(on: location)
            mapView.arriving = arriving
            segmentedControl.selectedSegmentIndex = arriving ? 0 : 1
        }
    }
    
    @IBAction func segmentedControlSelected(_ sender: Any) {
        arriving = segmentedControl.selectedSegmentIndex == 0
    }
    
    fileprivate func setupSegmentedControl() {
        let arrivingString = viewModel.arrivingString
        let leavingString = viewModel.leavingString
        
        segmentedControl.setTitle(arrivingString, forSegmentAt: 0)
        segmentedControl.setTitle(leavingString, forSegmentAt: 1)
    }
    
    fileprivate func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }
    
    fileprivate func setupSearchBar() {
        searchBar.delegate = self
        searchBar.barStyle = .default
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = viewModel.searchBarPlaceholder
        searchBar.accessibilityHint = viewModel.searchBarHint
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).font =
            UIFont.font(sized: 17, weight: .regular, with: .body)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        searchBar.reloadInputViews()
        searchResultsTableView.reloadInputViews()
    }
    
    fileprivate func setupMapView() {
        mapView.outputDelegate = self
        mapView.layer.cornerRadius = 6.3
        
        mapView.accessibilityLabel = viewModel.mapViewAccessibilityLabel
    }
    
    fileprivate func setupTableView() {
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.isHidden = true
        searchResultsTableView.layer.cornerRadius = 6.3
    }
    
    fileprivate func addCircle(on location: CLCircularRegion) {
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
        let circle = MKCircle(center: location.center, radius: location.radius)
        mapView.add(circle)
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
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: "searchResultCell",
                                 for: indexPath) as? LocationTableViewCell else { return UITableViewCell() }
        
        cell.titleLabel.text = tableViewData[indexPath.row].name
        cell.subtitleLabel.text = tableViewData[indexPath.row].placemark.fullAddress
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(tableViewData.count)
        return tableViewData.count
    }
}

extension LocationInputView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = tableViewData[indexPath.row]
        guard let location = place.placemark.location else { return }
        if let name = place.placemark.name {
            mapView.placeName = name
        }
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        tableView.isHidden = true
        searchBar.resignFirstResponder() // dismiss keyboard
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        outputlocation = CLCircularRegion(center: center,
                                          radius: 100,
                                          identifier: String(describing: center))
        addCircle(on: outputlocation!)
    }
}

extension LocationInputView: RadiusMapViewDelegate {
    func radiusMapView(_ radiusMapView: RadiusMapView, didFind region: CLCircularRegion) {
        outputlocation = region
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