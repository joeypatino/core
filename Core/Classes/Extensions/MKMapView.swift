import MapKit

public extension MKMapView {
    private static var MERCATOR_OFFSET: Double = 268435456
    private static var MERCATOR_RADIUS: Double = 85445659.44705395
    private static func longitudeToPixelSpaceX(_ longitude: Double) -> Double {
        round(MKMapView.MERCATOR_OFFSET + MKMapView.MERCATOR_RADIUS * longitude * Double.pi / 180.0)
    }
    private static func latitudeToPixelSpaceY(_ latitude: Double) -> Double {
        if latitude == 90.0 {
            return 0
        } else if latitude == -90.0 {
            return MKMapView.MERCATOR_OFFSET * 2
        } else {
            let loged = logf((1 + sinf(Float(latitude * Double.pi / 180.0))) / (1 - sinf(Float(latitude * Double.pi / 180.0)))) / 2.0
            return round(MKMapView.MERCATOR_OFFSET - MKMapView.MERCATOR_RADIUS * Double(loged))
        }
    }
    private static func pixelSpaceXToLongitude(_ pixelX: Double) -> Double {
        ((round(pixelX) - MKMapView.MERCATOR_OFFSET) / MKMapView.MERCATOR_RADIUS) * 180.0 / Double.pi
    }
    private static func pixelSpaceYToLatitude(_ pixelY: Double) -> Double {
        (Double.pi / 2.0 - 2.0 * atan(exp((round(pixelY) - MKMapView.MERCATOR_OFFSET) / MKMapView.MERCATOR_RADIUS))) * 180.0 / Double.pi
    }
    
    func setCenterCoordinate(_ coordinate: CLLocationCoordinate2D, zoomLevel: Float, animated: Bool) {
        let zoom = min(zoomLevel, 28)
        let span = coordinateSpan(with: coordinate, with: zoom)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        setRegion(region, animated: animated)
    }
    
    var zoom: Float {
        let region = self.region
        let centerX = MKMapView.longitudeToPixelSpaceX(region.center.longitude)
        let topLeftX = MKMapView.longitudeToPixelSpaceX(region.center.longitude - region.span.longitudeDelta / 2)
        
        let scaledWidth = (centerX - topLeftX) * 2
        let mapSize = self.bounds.size
        let zoomScale = scaledWidth / Double(mapSize.width)
        let zoomExponent = log(zoomScale) / log(2)
        let zoomLevel = 20 - zoomExponent
        return Float(zoomLevel)
    }
    
    private func coordinateSpan(with centerCoordinate: CLLocationCoordinate2D, with zoomLevel: Float) -> MKCoordinateSpan {
        // convert center coordiate to pixel space
        let centerX = MKMapView.longitudeToPixelSpaceX(centerCoordinate.longitude)
        let centerY = MKMapView.latitudeToPixelSpaceY(centerCoordinate.latitude)
        
        // determine the scale value from the zoom level
        let zoomExponent = 20 - zoomLevel
        let zoomScale = powf(2, zoomExponent)
        
        // scale the map’s size in pixel space
        let mapSize = bounds.size
        let scaledWidth = mapSize.width * CGFloat(zoomScale)
        let scaledHeight = mapSize.height * CGFloat(zoomScale)
        
        // figure out the position of the top-left pixel
        let topLeftX = centerX - Double((scaledWidth / 2))
        let topleftY = centerY - Double((scaledHeight / 2))
        
        // find delta between left and right longitudes
        let minLng = MKMapView.pixelSpaceXToLongitude(topLeftX)
        let maxLng = MKMapView.pixelSpaceXToLongitude(topLeftX + Double(scaledWidth))
        let longitudeDelta = maxLng - minLng
        
        // find delta between top and bottom latitudes
        let minLat = MKMapView.pixelSpaceYToLatitude(topleftY)
        let maxLat = MKMapView.pixelSpaceYToLatitude(topleftY + Double(scaledHeight))
        let latitudeDelta = -1 * (maxLat - minLat)
        
        // create and return the lat/lng span
        return MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
    }
}
