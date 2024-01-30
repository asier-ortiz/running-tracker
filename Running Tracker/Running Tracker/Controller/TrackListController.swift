import UIKit
import RealmSwift

class TrackListController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var dataManager: DataManager?
    private var tracks: Results<Track>?
    private var selectedTrack: Track?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataManager = DataManager.sharedInstance
        tracks = dataManager!.getAllTracks()
    }
    
    // MARK: - UITableViewDataSource
    static let tableViewCellIdentifier = "trackCell"
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks!.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: TrackListController.tableViewCellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: TrackListController.tableViewCellIdentifier)
        }
        cell?.backgroundColor = UIColor.clear
        
        let track = tracks![indexPath.row]
        let dateFormat = DateFormatter()
        dateFormat.dateFormat = "dd-MM-yyyy HH:mm"
        if let startDate = track.startDate {
            cell?.textLabel?.text = dateFormat.string(from: startDate)
        }
        let formattedDistance = (String(format: "%.03f Km", Float(track.distance) / 1000.0)).replacingOccurrences(of: ".", with: ",")
        let duration = dataManager!.getTrackDuration(track)
        let seconds = Int(duration) % 60
        let minutes = (Int(duration) / 60) % 60
        let hours = Int(duration) / 3600
        let formattedDuration = String(format: "%02ldh %02ldm %02lds", hours, minutes, seconds)
        cell?.detailTextLabel?.text = "\(formattedDistance) - \(formattedDuration)"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTrack = tracks![indexPath.row]
        performSegue(withIdentifier: "fromTrackListToMap", sender: self)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "Borrar ruta", handler: { action, indexPath in
            let track = self.tracks![indexPath.row]
            self.dataManager!.deleteTrack(track)
            self.tracks = self.dataManager!.getAllTracks()
            tableView.reloadData()
        })
        deleteButton.backgroundColor = UIColor(named: "primary_light")
        
        return [deleteButton]
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "fromTrackListToMap") {
            let vc = segue.destination as? MapViewController
            vc?.track = selectedTrack
        }
    }
}
