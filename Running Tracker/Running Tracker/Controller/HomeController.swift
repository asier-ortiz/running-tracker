import UIKit
import MapKit
import RealmSwift

class HomeController: UIViewController, MKMapViewDelegate, LocationDelegate {
    
    @IBOutlet private weak var editUserBarButton: UIBarButtonItem!
    @IBOutlet private weak var trackListBarButton: UIBarButtonItem!
    @IBOutlet private weak var startStopButton: UIButton!
    @IBOutlet private weak var chronoLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var calorieLabel: UILabel!
    @IBOutlet private weak var routeMapView: MKMapView!
    @IBOutlet private weak var addressContainer: UIView!
    @IBOutlet private weak var addressLabel: UILabel!
    private var dataManager: DataManager?
    private var locationManager: LocationManager?
    private var chrono: Timer?
    private var startDate: Date?
    private var isRunning = false
    private var currentTrack: Track?
    private var trackPolyLines: [MKPolyline]?
    private var mapRect: MKMapRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        startStopButton.layer.cornerRadius = 30.0
        distanceLabel.layer.borderWidth = 1.0
        distanceLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        calorieLabel.layer.borderWidth = 1.0
        calorieLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        routeMapView.delegate = self
        routeMapView.isScrollEnabled = false
        routeMapView.isZoomEnabled = false
        routeMapView.isPitchEnabled = false
        routeMapView.isRotateEnabled = false
        routeMapView.showsUserLocation = true
        routeMapView.showsTraffic = true
        routeMapView.showsBuildings = true
        routeMapView.showsScale = false
        routeMapView.pointOfInterestFilter = .includingAll
        routeMapView.showsCompass = false
        routeMapView.mapType = .standard
        dataManager = DataManager.sharedInstance
        locationManager = LocationManager.sharedInstance
        locationManager!.delegate = self
        isRunning = false
        trackPolyLines = [MKPolyline]()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setMapInitialPosition()
    }
    
    // MARK: - UI
    private func updateUI() {
        if !isRunning {
            editUserBarButton.isEnabled = true
            trackListBarButton.isEnabled = true
            chronoLabel.text = "00:00:00.00"
            distanceLabel.text = "0.0 Km"
            calorieLabel.text = "0.0 Kcal"
            if trackPolyLines!.count > 0 {
                routeMapView.removeOverlays(trackPolyLines!)
            }
            setMapInitialPosition()
            startStopButton.setImage(UIImage(named: "ic_play_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            editUserBarButton.isEnabled = false
            trackListBarButton.isEnabled = false
            distanceLabel.text = (String(format: "%.03f Km", Float(currentTrack!.distance) / 1000.0)).replacingOccurrences(of: ".", with: ",")
            calorieLabel.text = (String(format: "%.03f Kcal", Float(currentTrack!.calories) / 1000.0)).replacingOccurrences(of: ".", with: ",")
            startStopButton.setImage(UIImage(named: "ic_stop_white")?.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }
    
    @objc private func updateTimer() {
        let currentDate = Date()
        let timeInterval = currentDate.timeIntervalSince(startDate!)
        let timerDate = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm:ss.SS"
        dateFormatter.timeZone = NSTimeZone(forSecondsFromGMT: Int(0.0)) as TimeZone
        let timeString = dateFormatter.string(from: timerDate)
        chronoLabel.text = timeString
    }
    
    private func updateRoute() {
        if currentTrack!.trackPoints.count >= 2 {
            var trackings = [CLLocationCoordinate2D]()
            let point1 = currentTrack!.trackPoints[currentTrack!.trackPoints.count - 2]
            if fabs(point1.latitude) <= 90 && fabs(point1.longitude) <= 180 {
                trackings.append(CLLocationCoordinate2DMake(point1.latitude, point1.longitude))
            }
            let point2 = currentTrack!.trackPoints.last
            if fabs(point2!.latitude) <= 90 && fabs(point2!.longitude) <= 180 {
                trackings.append(CLLocationCoordinate2DMake(point2!.latitude, point2!.longitude))
            }
            let polyLine = MKPolyline(coordinates: &trackings, count: 2)
            trackPolyLines?.append(polyLine)
            routeMapView.addOverlay(polyLine)
            routeMapView.camera.altitude = 500
            routeMapView.setCenter(trackings[1], animated: true)
        }
    }
    
    private func setMapInitialPosition() {
        var center: CLLocationCoordinate2D
        if routeMapView.userLocation.location != nil {
            center = routeMapView.userLocation.coordinate
        } else {
            center = CLLocationCoordinate2DMake(CLLocationDegrees(42.848798), CLLocationDegrees(-2.672451))
        }
        let camera = MKMapCamera(lookingAtCenter: center, fromDistance: CLLocationDistance(5000), pitch: 75, heading: CLLocationDirection(0))
        
        UIView.animate(withDuration: 3, delay: 0, options: .curveEaseInOut, animations: {
            self.routeMapView.camera = camera
        })
    }
    
    private func setMapRunningAltitude() {
        let camera = MKMapCamera(lookingAtCenter: routeMapView.camera.centerCoordinate, fromDistance: CLLocationDistance(300), pitch: 75, heading: routeMapView.camera.heading)
        UIView.animate(withDuration: 1.5, delay: 0, options: .curveEaseInOut, animations: {
            self.routeMapView.camera = camera
        })
    }
    
    // MARK: - Actions
    @IBAction func editUser(_ sender: UIBarButtonItem) {
        if #available(iOS 13, *) {
            performSegue(withIdentifier: "fromHomeToUserModal", sender: self)
        } else {
            performSegue(withIdentifier: "fromHomeToUserPush", sender: self)
        }
    }
    
    @IBAction func showList(_ sender: Any) {
        if dataManager!.getAllTracks()!.count == 0 {
            DialogManager.showAlert(withTitle: "Error", message: "¡Aun no hay rutas guardadas!", withCancelButton: false, noDefaultCancelText: nil, cancelHandler: nil, withOkButton: true, noDefaultOkText: "Aceptar", okHandler: nil, viewController: self, tintColor: UIColor(named: "primary")!)
        } else {
            performSegue(withIdentifier: "fromHomeToTrackList", sender: self)
        }
    }
    
    @IBAction func playStopAction(_ sender: UIButton) {
        isRunning = !isRunning
        if isRunning {
            startDate = Date()
            currentTrack = dataManager!.createNewTrack()
            if chrono == nil {
                chrono = Timer.scheduledTimer(timeInterval: 1.0 / 100.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
            }
            setMapRunningAltitude()
            locationManager!.startUpdatingLocation()
            updateUI()
        } else {
            chrono!.invalidate()
            chrono = nil
            locationManager!.stopUpdatingLocation()
            DialogManager.showAlert(withTitle: "Fin de carrera", message: "¿Quieres guardar esta ruta?", withCancelButton: true, noDefaultCancelText: nil, cancelHandler: { action in
                self.dataManager!.deleteTrack(self.currentTrack!)
                self.currentTrack = nil
                self.updateUI()
            }, withOkButton: true, noDefaultOkText: "Guardar", okHandler: { action in
                self.currentTrack = self.dataManager!.finishTrack(self.currentTrack!)
                self.performSegue(withIdentifier: "fromHomeToMap", sender: self)
                self.currentTrack = nil
                self.updateUI()
            }, viewController: self, tintColor: UIColor(named: "primary")!)
        }
        
    }
    
    // MARK: - LocationDelegate
    func locationUpdated(_ location: CLLocation?) {
        currentTrack = dataManager!.updateTrack(currentTrack!, with: location)
        updateRoute()
        updateUI()
        self.setAddresFrom(location)
    }
    
    func setAddresFrom(_ location: CLLocation?) {
        let geocoder = CLGeocoder()
        if let location = location {
            geocoder.reverseGeocodeLocation(location, completionHandler: { placemarks, error in
                if error != nil || placemarks?.count == 0 {
                    if self.addressContainer.frame.size.height > 0.0 {
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                            let frame = CGRect(x: self.addressContainer.frame.origin.x, y: self.addressContainer.frame.origin.y, width: self.addressContainer.frame.size.width, height: 0.0)
                            self.addressContainer.frame = frame
                        })
                    }
                } else {
                    let placemark = placemarks?[0]
                    self.addressLabel.text = "\(placemark?.thoroughfare ?? "")"
                    if self.addressContainer.frame.size.height == 0.0 {
                        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                            let frame = CGRect(x: self.addressContainer.frame.origin.x, y: self.addressContainer.frame.origin.y, width: self.addressContainer.frame.size.width, height: 30.0)
                            self.addressContainer.frame = frame
                        })
                    }
                }
            })
        }
    }
    
    func headingUpdated(_ heading: CLLocationDirection) {
        routeMapView.camera.heading = heading
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let track = MKPolylineRenderer(overlay: overlay)
        track.fillColor = UIColor(named: "primary")
        track.strokeColor = UIColor(named: "primary")
        track.lineWidth = 3
        return track
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fromHomeToMap") {
            let vc = segue.destination as? MapViewController
            vc?.track = currentTrack!
        }
    }
}
