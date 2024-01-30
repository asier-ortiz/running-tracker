import RealmSwift

class TrackPoint: Object {
    
    @objc dynamic var date = Date()
    @objc dynamic var latitude: Double = 0.0
    @objc dynamic var longitude: Double = 0.0
    @objc dynamic var track: Track?
}

