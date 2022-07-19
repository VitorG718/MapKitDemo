//
//  ViewController.swift
//  MapDemo
//
//  Created by Vitor Gledison Oliveira de Souza on 15/11/21.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    private lazy var mapView: MKMapView = {
        let map = MKMapView()
        return map
    }()
    
    private var viewModel = MapViewModel.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        view.addSubview(mapView)
        mapView.region = viewModel.region
        mapView.showsUserLocation = true
        viewModel.updateRegion = {
            self.mapView.region = self.viewModel.region
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.checkIfLocationServiceEnabled()
    }
}

final class MapViewModel: NSObject, CLLocationManagerDelegate {
    
    public static var shared = MapViewModel()
    private var manager: CLLocationManager?
    public var locationManager: CLLocationManager? { manager }
    public var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -15.795890, longitude: -47.876058), span: .init(latitudeDelta: 0.05, longitudeDelta: 0.05))
    public var updateRegion: (() -> Void)?
    
    private override init() {
        super.init()
    }
    
    func checkIfLocationServiceEnabled() {
        if CLLocationManager.locationServicesEnabled() {
            manager = CLLocationManager()
            manager?.delegate = self
        } else {
            print("Location Service is disabled")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("Denied or restricted")
        case .authorizedAlways, .authorizedWhenInUse:
            print("Authorized")
            if let locationCenter = manager.location?.coordinate {
                region = MKCoordinateRegion(center: locationCenter, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
                updateRegion?()
            }
            
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            region = MKCoordinateRegion(center: location.coordinate, span: .init(latitudeDelta: 0.01, longitudeDelta: 0.01))
            updateRegion?()
        }
    }
}

