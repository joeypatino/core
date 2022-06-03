import CoreLocation

public protocol LocationCoordinate {
    var latitude: Double { get }
    var longitude: Double { get }
}

extension CLLocationCoordinate2D: LocationCoordinate {}

public final class LocationManager: NSObject {
    public typealias NeedsAuthorization = () -> Void
    public typealias AuthorizationUpdated = (CLAuthorizationStatus) -> Bool
    public typealias LocationUpdated = (LocationCoordinate) -> Void
    
    public var currentLocation: LocationCoordinate?
    public var locationUpdated: LocationUpdated? {
        didSet { currentLocation.map { locationUpdated?($0) } }
    }
    public var needsAuthorization: NeedsAuthorization?
    public var authorizationUpdated: AuthorizationUpdated = { _ in return true }
    
    // Used to start getting the users location
    private let locationManager = CLLocationManager()
    
    public func start() {
        locationManager.requestWhenInUseAuthorization()
        guard CLLocationManager.locationServicesEnabled() else {
            DispatchQueue.main.async { self.needsAuthorization?() }
            return
        }
        if CLLocationManager.authorizationStatus() == .denied {
            DispatchQueue.main.async { self.needsAuthorization?() }
        }
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.startUpdatingLocation()
    }
}

extension LocationManager: CLLocationManagerDelegate {
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        currentLocation = location.coordinate
        locationUpdated?(location.coordinate)
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if authorizationUpdated(status) { start() }
        if status == .denied { needsAuthorization?() }
    }
}
