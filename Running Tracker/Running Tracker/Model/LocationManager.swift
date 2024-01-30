import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    private var dataManager: DataManager?
    private var locationManager: CLLocationManager?
    var delegate: LocationDelegate?
    
    static let sharedInstance: LocationManager? = {
        let instance = LocationManager()
        return instance
    }()
    
    private override init() {
        super.init()
        dataManager = DataManager.sharedInstance
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyBest
        locationManager!.requestWhenInUseAuthorization()
    }
    
    func requestLocation() {
        locationManager!.requestLocation()
    }
    
    func startUpdatingLocation() {
        locationManager!.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager!.headingFilter = CLLocationDegrees(1)
            locationManager!.startUpdatingHeading()
        }
    }
    
    func stopUpdatingLocation() {
        locationManager!.stopUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            locationManager!.stopUpdatingHeading()
        }
    }
    
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            delegate?.locationUpdated(locations[0])
        }
    }
    func locationManagerShouldDisplayHeadingCalibration(_ manager: CLLocationManager) -> Bool {
        return true
    }
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        let heading = (newHeading.trueHeading > 0) ? newHeading.trueHeading : newHeading.magneticHeading
        delegate?.headingUpdated(heading)
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("LocationManager didFailWithError: \(error)")
        NotificationCenter.default.post(name: NSNotification.Name("locationManagerFailed"), object: self, userInfo: nil)
    }
}

protocol LocationDelegate {
    func locationUpdated(_ location: CLLocation?)
    func headingUpdated(_ heading: CLLocationDirection)
}
