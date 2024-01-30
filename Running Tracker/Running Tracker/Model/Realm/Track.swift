import RealmSwift

class Track: Object {
    
    @objc dynamic var startDate: Date? = nil
    @objc dynamic var endDate: Date? = nil
    @objc dynamic var distance: Int = 0
    @objc dynamic var calories: Int = 0
    @objc dynamic var height: Int = 0
    @objc dynamic var weight: Int = 0
    @objc dynamic var age: Int = 0
    @objc dynamic var isMale: Bool = false
    let trackPoints = LinkingObjects(fromType: TrackPoint.self, property: "track")
    
    class func getAllTracksOrderedByDate() -> Results<Track>? {
        let tracks = try! Realm().objects(Track.self).sorted(byKeyPath: "startDate", ascending: false)
        return tracks
    }
}
