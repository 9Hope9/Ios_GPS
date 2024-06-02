//
//  ViewController.swift
//  GPS_map_lab7
//
//  Created by user240436 on 3/20/24.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var maxSpeedLabel: UILabel!
    @IBOutlet weak var averageSpeedLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var accelerationLabel: UILabel!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var bottomBarView: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    var locationManager = CLLocationManager()
    var startLocation: CLLocation?
    var lastLocation: CLLocation?
    var tripDistance: CLLocationDistance = 0
    var maxSpeed: CLLocationSpeed = 0
    var totalSpeed: CLLocationSpeed = 0
    var acceleration: CLLocationSpeed = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocationManager()
    }
    
    // Function to customize UI elements
    func setupUI() {
        topBarView.backgroundColor = .gray
        bottomBarView.backgroundColor = .gray
    }
    
    // Function to set up location manager
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    // Function to clear trip data
    func clear() {
        startLocation = nil
        lastLocation = nil
        tripDistance = 0
        maxSpeed = 0
        totalSpeed = 0
        acceleration = 0
        speedLabel.text = String(format: "%.2f km/h", 0)
        maxSpeedLabel.text = String(format: "%.2f km/h", 0)
        averageSpeedLabel.text = String(format: "%.2f km/h", 0)
        distanceLabel.text = String(format: "%.2f km", 0)
        accelerationLabel.text = String(format: "%.2f m/s^2", 0)
    }
    
    // Action for start trip button
    @IBAction func startTrip(_ sender: Any) {
        clear()
        locationManager.startUpdatingLocation()
        startButton.isEnabled = false
        stopButton.isEnabled = true
        bottomBarView.backgroundColor = .green
    }
    
    // Action for stop trip button
    @IBAction func stopTrip(_ sender: Any) {
        locationManager.stopUpdatingLocation()
        startButton.isEnabled = true
        stopButton.isEnabled = false
        topBarView.backgroundColor = .gray
        bottomBarView.backgroundColor = .gray
    }
    
    // Delegate method called when new locations are received
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        // If it's the first location received, set it as start location
        if startLocation == nil {
            startLocation = newLocation
        } else {
            if let lastLocation = lastLocation {
                // Calculate distance between current and last location
                let distance = newLocation.distance(from: lastLocation)
                // If distance is valid, add it to trip distance
                if distance >= 0 {
                    tripDistance += distance
                }
                // Update distance label
                distanceLabel.text = String(format: "%.2f km", tripDistance / 1000)
                
                // Get current speed
                let speed = newLocation.speed
                // If speed is valid, add it to total speed
                if speed >= 0 {
                    totalSpeed += speed
                }
                
                // Update max speed if current speed exceeds max speed
                if speed > maxSpeed {
                    maxSpeed = speed
                    maxSpeedLabel.text = String(format: "%.2f km/h", maxSpeed * 3.6)
                }
                
                // Change top bar color to red if speed exceeds 115 km/h
                if speed > 31.94 { // 115 km/h in m/s
                    topBarView.backgroundColor = .red
                }
                
                // Calculate acceleration
                let currentAcceleration = abs(speed - lastLocation.speed) / Double(newLocation.timestamp.timeIntervalSince(lastLocation.timestamp))
                acceleration = max(acceleration, currentAcceleration)
                // Update acceleration label
                accelerationLabel.text = String(format: "%.2f m/s^2", acceleration)
                
                // Calculate average speed
                let averageSpeed = totalSpeed / tripDistance
                // Update average speed label if it's not NaN
                if !averageSpeed.isNaN {
                    averageSpeedLabel.text = String(format: "%.2f km/h", averageSpeed * 3.6)
                }
                // Update current speed label
                speedLabel.text = String(format: "%.2f km/h", speed * 3.6)
            }
            // Update last location
            lastLocation = newLocation
        }
        
        // Update map view
        let region = MKCoordinateRegion(center: newLocation.coordinate, latitudinalMeters: 500, longitudinalMeters: 500)
        mapView.setRegion(region, animated: true)
        
        // Add current location annotation
        mapView.removeAnnotations(mapView.annotations)
        let annotation = MKPointAnnotation()
        annotation.coordinate = newLocation.coordinate
        mapView.addAnnotation(annotation)
    }
}
