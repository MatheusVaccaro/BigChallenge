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
    var viewModel: LocationInputViewModel!
    
    // MARK: - Internal
    fileprivate var tableViewData: [MKMapItem] = []
    fileprivate let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.backgroundColor
        
        configureNavigationBar()
        setupSegmentedControl()
        setupLocationManager()
        setupSearchBar()
        setupMapView()
        setupTableView()
        
        if let location = viewModel.location {
            addCircle(on: location)
            mapView.arriving = viewModel.isArriving
            segmentedControl.selectedSegmentIndex = viewModel.isArriving ? 0 : 1
        }
        
        print("+++ INIT LocationInputViewController")
    }
    
    deinit {
        print("--- DEINIT LocationInputViewController")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.backgroundColor
    }
    
    @IBAction func segmentedControlSelected(_ sender: Any) {
        viewModel.isArriving = segmentedControl.selectedSegmentIndex == 0
        mapView.arriving = viewModel.isArriving
    }
    
    private func configureNavigationBar() {
        title = viewModel.title
        navigationController?.navigationBar.barTintColor = UIColor.backgroundColor
    }
    
    fileprivate func setupSegmentedControl() {
        let arrivingString = viewModel.arrivingString
        let leavingString = viewModel.leavingString
        
        segmentedControl.tintColor = UIColor.largeTitleColor
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(stopSearching))
        mapView.addGestureRecognizer(tapGesture)
    }
    
    fileprivate func setupTableView() {
        searchResultsTableView.dataSource = self
        searchResultsTableView.delegate = self
        searchResultsTableView.isHidden = true
        searchResultsTableView.layer.cornerRadius = 6.3
        searchResultsTableView.register(UINib(nibName: "IconCell",
                                              bundle: nil),
                                        forCellReuseIdentifier: IconTableViewCell.reuseIdentifier!)
        
        searchResultsTableView.estimatedRowHeight = 50
        searchResultsTableView.rowHeight = UITableView.automaticDimension
    }
    
    fileprivate func addCircle(on location: CLCircularRegion) {
        locationManager.stopUpdatingLocation()
        mapView.showsUserLocation = false
        let circle = MKCircle(center: location.center, radius: location.radius)
        mapView.addOverlay(circle)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        stopSearching()
    }
    
    @objc private func stopSearching() {
        searchBar.resignFirstResponder()
    }
}

extension LocationInputView: UISearchBarDelegate {
    // This method updates filteredData based on the text in the Search Box
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let request = MKLocalSearch.Request()
        
        request.naturalLanguageQuery = searchText
        request.region = mapView.region
        
        let search = MKLocalSearch(request: request)
        
        search.start { response, _ in
            guard let response = response else { return }
            
            self.searchResultsTableView.isHidden = false
            self.tableViewData = response.mapItems
            self.searchResultsTableView.reloadData()
        }
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchResultsTableView.isHidden = true
    }
}

extension LocationInputView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView
            .dequeueReusableCell(withIdentifier: IconTableViewCell.reuseIdentifier!,
                                 for: indexPath) as? IconTableViewCell else { return UITableViewCell() }
        
        cell.titleFontSize = 17
        cell.subtitleFontSize = 12
        cell.rightButton.isHidden = true
        cell.viewModel = tableViewData[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableViewData.count
    }
}

extension MKMapItem: IconCellPresentable {
    var title: String {
        return name!
    }
    
    var subtitle: String {
        return placemark.fullAddress
    }
    
    var imageName: String {
        return "locationIcon"
    }
    
    var voiceOverHint: String {
        return Strings.LocationInputView.locationCellHint
    }
    
    var voiceOverValue: String? {
        return subtitle
    }
}

extension LocationInputView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let place = tableViewData[indexPath.row]
        guard let location = place.placemark.location else { return }
        if let name = place.placemark.name {
            mapView.placeName = name
            viewModel.placeName = name
        }
        
        mapView.removeOverlays(mapView.overlays)
        mapView.removeAnnotations(mapView.annotations)
        tableView.isHidden = true
        searchBar.resignFirstResponder() // dismiss keyboard
        
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude,
                                            longitude: location.coordinate.longitude)
        
        viewModel.location = CLCircularRegion(center: center,
                                          radius: 100,
                                          identifier: String(describing: center))
        addCircle(on: viewModel.location!)
    }
}

extension LocationInputView: RadiusMapViewDelegate {
    func radiusMapView(_ radiusMapView: RadiusMapView, didFind region: CLCircularRegion) {
        viewModel.location = region
    }
}

extension LocationInputView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            
            let span = MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
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
