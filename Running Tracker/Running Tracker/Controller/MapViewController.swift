import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var durationLabel: UILabel!
    @IBOutlet private weak var distanceLabel: UILabel!
    @IBOutlet private weak var calorieLabel: UILabel!
    @IBOutlet private weak var stepsLabel: UILabel!
    @IBOutlet private weak var speedLabel: UILabel!
    @IBOutlet private weak var routeMapView: MKMapView!
    private var dataManager: DataManager?
    private var trackingPolyline: MKPolyline?
    private var mapRect: MKMapRect!
    private var startPointAnnotation: MKPointAnnotation?
    private var endPointAnnotation: MKPointAnnotation?
    var track: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = DataManager.sharedInstance
        dateLabel.layer.borderWidth = 1.0
        dateLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        durationLabel.layer.borderWidth = 1.0
        durationLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        distanceLabel.layer.borderWidth = 1.0
        distanceLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        calorieLabel.layer.borderWidth = 1.0
        calorieLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        stepsLabel.layer.borderWidth = 1.0
        stepsLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        speedLabel.layer.borderWidth = 1.0
        speedLabel.layer.borderColor = UIColor(named: "primary_light")?.cgColor
        routeMapView.delegate = self
        routeMapView.isScrollEnabled = true
        routeMapView.isZoomEnabled = true
        routeMapView.isRotateEnabled = true
        routeMapView.showsUserLocation = false
        routeMapView.showsTraffic = false
        routeMapView.showsBuildings = true
        routeMapView.showsScale = false
        routeMapView.pointOfInterestFilter = .includingAll
        routeMapView.showsCompass = false
        routeMapView.mapType = .standard
        let compassView = MKCompassButton(mapView: routeMapView)
        compassView.compassVisibility = .adaptive
        compassView.translatesAutoresizingMaskIntoConstraints = false
        routeMapView.addSubview(compassView)
        compassView.leftAnchor.constraint(equalTo: routeMapView.safeAreaLayoutGuide.rightAnchor, constant: -60).isActive = true
        compassView.bottomAnchor.constraint(equalTo: routeMapView.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        let scaleView = MKScaleView(mapView: routeMapView)
        scaleView.scaleVisibility = .visible
        scaleView.translatesAutoresizingMaskIntoConstraints = false
        routeMapView.addSubview(scaleView)
        scaleView.leftAnchor.constraint(equalTo: routeMapView.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        scaleView.bottomAnchor.constraint(equalTo: routeMapView.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    
    // MARK: - UI
    private func updateUI() {
        if (track != nil) {
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
            dateLabel.text = dateFormat.string(from: track!.startDate!)
            let duration = dataManager!.getTrackDuration(track!)
            let seconds = Int(duration) % 60
            let minutes = (Int(duration) / 60) % 60
            let hours = Int(duration) / 3600
            let formattedDuration = String(format: "%02ldh %02ldm %02lds", hours, minutes, seconds)
            durationLabel.text = formattedDuration
            let formattedDistance = (String(format: "%.03f Km", Float(track!.distance) / 1000.0)).replacingOccurrences(of: ".", with: ",")
            distanceLabel.text = formattedDistance
            calorieLabel.text = (String(format: "%.03f Kcal", Float(track!.calories) / 1000.0)).replacingOccurrences(of: ".", with: ",")
            speedLabel.text = String(format: "%.03f Km/h", dataManager!.getTrackAverageSpeed(track!)).replacingOccurrences(of: ".", with: ",")
            stepsLabel.text = String(format: "%lu pasos", UInt(dataManager!.getTrackSteps(track!)))
            updateRoute()
        }
    }
    
    private func updateRoute() {
        if (trackingPolyline != nil) {
            routeMapView.removeOverlay(trackingPolyline!)
        }
        if (startPointAnnotation != nil) {
            routeMapView.removeAnnotation(startPointAnnotation!)
        }
        if (endPointAnnotation != nil) {
            routeMapView.removeAnnotation(endPointAnnotation!)
        }
        if track!.trackPoints.count != 0 {
            var trackings = [CLLocationCoordinate2D]()
            var i = 0
            for trackingPoint in track!.trackPoints {
                if abs(trackingPoint.latitude) <= 90 && abs(trackingPoint.longitude) <= 180 {
                    trackings.append(CLLocationCoordinate2DMake(trackingPoint.latitude, trackingPoint.longitude))
                    i += 1
                }
            }
            trackingPolyline = MKPolyline(coordinates: &trackings, count: i)
            routeMapView.addOverlay(trackingPolyline!)
            mapRect = routeMapView.mapRectThatFits(trackingPolyline!.boundingMapRect)
            startPointAnnotation = MKPointAnnotation()
            startPointAnnotation!.coordinate = CLLocationCoordinate2DMake((track!.trackPoints.first)!.latitude, (track!.trackPoints.first)!.longitude)
            endPointAnnotation = MKPointAnnotation()
            endPointAnnotation!.coordinate = CLLocationCoordinate2DMake((track!.trackPoints.last)!.latitude, (track!.trackPoints.last)!.longitude)
            let annotations = [startPointAnnotation, endPointAnnotation]
            routeMapView.addAnnotations(annotations as! [MKAnnotation])
            routeMapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
        }
    }
    
    // MARK: - MKMapViewDelegate
    @IBAction func mapType(_ sender: UIBarButtonItem) {
        var buttons: [AnyHashable] = []
        buttons.append(UIAlertAction(title: "Carretera", style: .default, handler: { action in
            self.routeMapView.mapType = .standard
            
        }))
        buttons.append(UIAlertAction(title: "Satélite", style: .default, handler: { action in
            self.routeMapView.mapType = .satellite
            
        }))
        buttons.append(UIAlertAction(title: "Híbrido", style: .default, handler: { action in
            self.routeMapView.mapType = .hybrid
            
        }))
        let view = sender.value(forKey: "view") as? UIView
        DialogManager.showActionSheet(withTitle: "Mapa", withButtonsActions: buttons as! [UIAlertAction], cancelButton: true, viewController: self, tintColor: UIColor(named: "primary")!, sourceView: view!)
    }
    
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let track = MKPolylineRenderer(overlay: overlay)
        track.fillColor = UIColor(named: "primary")
        track.strokeColor = UIColor(named: "primary")
        track.lineWidth = 3
        
        return track
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isEqual(startPointAnnotation) {
            var aView = mapView.dequeueReusableAnnotationView(withIdentifier: "startAnotation")
            if aView == nil {
                aView = MKAnnotationView(annotation: annotation, reuseIdentifier: "StartAnotation")
                aView?.annotation = annotation
                aView?.isEnabled = true
                aView?.isDraggable = false
                aView?.canShowCallout = false
                aView?.image = UIImage(named: "ic_start")
                var frame = aView?.frame
                frame?.size.width = 32.0
                frame?.size.height = 50
                aView?.frame = frame ?? CGRect.zero
                aView?.centerOffset = CGPoint(x: 0, y: -15)
            }
            return aView
        } else if annotation.isEqual(endPointAnnotation) {
            var aView = mapView.dequeueReusableAnnotationView(withIdentifier: "endAnotation")
            if aView == nil {
                aView = MKAnnotationView(annotation: annotation, reuseIdentifier: "StartAnotation")
                aView?.annotation = annotation
                aView?.isEnabled = true
                aView?.isDraggable = false
                aView?.canShowCallout = false
                aView?.image = UIImage(named: "ic_end")
                var frame = aView?.frame
                frame?.size.width = 34.2
                frame?.size.height = 50
                aView?.frame = frame ?? CGRect.zero
                aView?.centerOffset = CGPoint(x: 0, y: -15)
            }
            return aView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        routeMapView.deselectAnnotation(view.annotation, animated: true)
        routeMapView.setVisibleMapRect(mapRect, edgePadding: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20), animated: true)
    }
}
