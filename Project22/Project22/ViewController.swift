//
//  ViewController.swift
//  Project22
//
//  Created by Christian Mitteldorf on 21/07/2019.
//  Copyright © 2019 Christian Mitteldorf. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController {

    @IBOutlet weak var distanceReading: UILabel!

    private var locationManager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.requestAlwaysAuthorization()

        view.backgroundColor = .gray
    }

    func startScanning() {
        let uuid = UUID(uuidString: UUID().uuidString)! // run uuidgen to get your uuid
        let beaconRegion = CLBeaconRegion(uuid: uuid, major: 123, minor: 456, identifier: "MyBeacon")

        locationManager?.startMonitoring(for: beaconRegion)
        locationManager?.startRangingBeacons(in: beaconRegion)
    }

    func update(distance: CLProximity) {
        UIView.animate(withDuration: 1) {
            switch distance {
            case .unknown:
                self.view.backgroundColor = .gray
                self.distanceReading.text = "UNKNOWN"

            case .far:
                self.view.backgroundColor = .blue
                self.distanceReading.text = "FAR"

            case .near:
                self.view.backgroundColor = .orange
                self.distanceReading.text = "NEAR"

            case .immediate:
                self.view.backgroundColor = .red
                self.distanceReading.text = "RIGHT HERE"
            @unknown default:
                fatalError()
            }
        }
    }
}

extension ViewController: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways,
           CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self),
           CLLocationManager.isRangingAvailable() {
            startScanning()
        }
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if let beacon = beacons.first {
            update(distance: beacon.proximity)
        } else {
            update(distance: .unknown)
        }
    }
}
