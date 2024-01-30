import CoreLocation
import Foundation
import UIKit
import RealmSwift

func SYSTEM_VERSION_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedSame
}

func SYSTEM_VERSION_GREATER_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedDescending
}

func SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedAscending
}

func SYSTEM_VERSION_LESS_THAN(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) == .orderedAscending
}

func SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(version: String) -> Bool {
    return UIDevice.current.systemVersion.compare(version, options: .numeric) != .orderedDescending
}


let KEY_MALE = "user_gender"
let KEY_HEIGHT = "user_height"
let KEY_WEIGHT = "user_weight"
let KEY_AGE = "user_age"
let DEFAULT_HEIGHT = 175
let DEFAULT_WEIGHT = 75
let DEFAULT_AGE = 30


class DataManager: NSObject {
    
    private var userDefaults: UserDefaults?
    
    static let sharedInstance: DataManager? = {
        var sharedInstance = DataManager()
        return sharedInstance
    }()
    
    private override init() {
        super.init()
        userDefaults = UserDefaults.standard
        setDefaultUserDataIfNeeded()
    }
    
    // MARK: - Life cycle
    func setDefaultUserDataIfNeeded() {
        if userDefaults?.object(forKey: KEY_MALE) == nil {
            userDefaults?.set(true, forKey: KEY_MALE)
            userDefaults?.synchronize()
        }
        if userDefaults?.object(forKey: KEY_HEIGHT) == nil {
            userDefaults?.set(DEFAULT_HEIGHT, forKey: KEY_HEIGHT)
            userDefaults?.synchronize()
        }
        if userDefaults?.object(forKey: KEY_WEIGHT) == nil {
            userDefaults?.set(DEFAULT_WEIGHT, forKey: KEY_WEIGHT)
            userDefaults?.synchronize()
        }
        if userDefaults?.object(forKey: KEY_AGE) == nil {
            userDefaults?.set(DEFAULT_AGE, forKey: KEY_AGE)
            userDefaults?.synchronize()
        }
    }
    
    // MARK: - User data
    func getIsUserMale() -> Bool {
        return Bool(userDefaults!.bool(forKey: KEY_MALE))
    }
    func setIsUserMale(_ male: Bool) {
        userDefaults!.set(male, forKey: KEY_MALE)
    }
    func getUserHeight() -> Int {
        return userDefaults!.integer(forKey: KEY_HEIGHT)
    }
    func setUserHeight(_ height: Int) {
        userDefaults!.set(height, forKey: KEY_HEIGHT)
    }
    func getUserWeight() -> Int {
        return userDefaults!.integer(forKey: KEY_WEIGHT)
    }
    func setUserWeight(_ weight: Int) {
        userDefaults!.set(weight, forKey: KEY_WEIGHT)
    }
    func getUserAge() -> Int {
        return userDefaults!.integer(forKey: KEY_AGE)
    }
    func setUserAge(_ age: Int) {
        userDefaults!.set(age, forKey: KEY_AGE)
    }
    
    // MARK: - Track data
    func getAllTracks() -> Results<Track>? {
        return Track.getAllTracksOrderedByDate()
    }
    func createNewTrack() -> Track {
        let track = Track()
        track.startDate = Date()
        track.height = getUserHeight()
        track.weight = getUserWeight()
        track.age = getUserAge()
        track.isMale = getIsUserMale()
        let realm = try! Realm()
        realm.beginWrite()
        realm.add(track)
        try! realm.commitWrite()
        return track
    }
    
    func updateTrack(_ track: Track, with loc: CLLocation?) -> Track {
        let realm = try! Realm()
        realm.beginWrite()
        let trackPoint = TrackPoint()
        trackPoint.date = loc!.timestamp
        trackPoint.latitude = (loc?.coordinate.latitude)!
        trackPoint.longitude = (loc?.coordinate.longitude)!
        trackPoint.track = track
        realm.add(trackPoint)
        try! realm.commitWrite()
        return updateCaloriesAndDistance(track)
    }
    
    func updateCaloriesAndDistance(_ track: Track) -> Track {
        if (track.trackPoints.count) >= 2 {
            let trackPonit1 = track.trackPoints[(track.trackPoints.count) - 2]
            let location1 = CLLocation(latitude: trackPonit1.latitude, longitude: trackPonit1.longitude)
            let trackPoint2 = track.trackPoints.last
            let location2 = CLLocation(latitude: trackPoint2!.latitude, longitude: trackPoint2!.longitude)
            let distance: CLLocationDistance = Double(track.distance) + location1.distance(from: location2)
            let calories = (distance / 1000.0) * Double(track.weight) * 1.036
            let realm = try! Realm()
            realm.beginWrite()
            track.distance = Int(distance)
            track.calories = Int(calories)
            try! realm.commitWrite()
        }
        return track
    }
    
    func finishTrack(_ track: Track) -> Track {
        let realm = try! Realm()
        realm.beginWrite()
        track.endDate = Date()
        try! realm.commitWrite()
        return track
    }
    
    func deleteTrack(_ track: Track) {
        let realm = try! Realm()
        realm.beginWrite()
        realm.delete(track.trackPoints)
        realm.delete(track)
        try! realm.commitWrite()
    }
    
    func getTrackAverageSpeed(_ track: Track) -> Float {
        var speed: Float = 0.0
        let duration = getTrackDuration(track)
        if duration > 0.0 && track.distance > 0 {
            speed = Float((Double(track.distance) / duration) * 3.6)
        }
        return speed
    }
    
    func getTrackSteps(_ track: Track) -> Int {
        var steps = 0
        if track.distance > 0 {
            let strideLenght = Int(Float(track.height) * (track.isMale ? 0.415 : 0.413))
            steps = Int((track.distance * 100)) / strideLenght
        }
        return steps
    }
    
    func getTrackDuration(_ track: Track) -> TimeInterval {
        var duration: TimeInterval = 0
        if track.startDate != nil && track.endDate != nil {
            duration = track.endDate!.timeIntervalSince(track.startDate!)
        }
        return duration
    }
}
