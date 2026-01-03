//
//  ViewController.swift
//  adminpanel
//
//  Created by bp-36-213-13 on 30/12/2025.
//

import UIKit
import MapKit

class ViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Satellite view
        mapView.mapType = .satellite

        // ✅ Correct center of Bahrain Polytechnic (Isa Town campus)
        let center = CLLocationCoordinate2D(
            latitude: 26.1663,
            longitude: 50.5462
        )

        // ✅ Tight zoom: campus & buildings only
        let region = MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: 0.0013, longitudeDelta: 0.0013)
        )
        mapView.setRegion(region, animated: true)

        // 📍 Building 19
        addPin(
            latitude: 26.16549,
            longitude: 50.54675,
            title: "Building 19",
            note: "Request 1: HVAC Request"
        )

        // 📍 Building 5
        addPin(
            latitude: 26.16664,
            longitude: 50.54697,
            title: "Building 5",
            note: "Request 2: Leak in roof"
        )

        // 📍 Building 36
        addPin(
            latitude: 26.16700,
            longitude: 50.54500,
            title: "Building 36",
            note: "Request 3: loose cut wires"
        )
    }

    // Helper to add pins with notes
    func addPin(latitude: Double, longitude: Double, title: String, note: String) {
        let pin = MKPointAnnotation()
        pin.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        pin.title = title
        pin.subtitle = note
        mapView.addAnnotation(pin)
    }
}
