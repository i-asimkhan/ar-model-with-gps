//
//  ViewController.swift
//  ARModelWithGPS
//
//  Created by dev shanghai on 15/03/2019.
//  Copyright © 2019 dev_shanghai. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import MapKit
import CoreLocation
import GoogleMaps

class ViewController: UIViewController {


	// MARK:- IBOutlets
	@IBOutlet var sceneView: ARSCNView!
	@IBOutlet weak var viewMapContainer: UIView!
	@IBOutlet weak var mapView: MKMapView!

	@IBOutlet weak var imageView: UIImageView!
	





	// MARK:- Delegates
	let locationDelegate = LocationDelegate()

	// MARK:- NewVariables
	var latestLocation: CLLocation? = nil
	var yourLocationBearing: CGFloat { return latestLocation?.bearingToLocationRadian(self.yourLocation) ?? 0 }
	var yourLocation: CLLocation {
		get { return UserDefaults.standard.currentLocation }
		set { UserDefaults.standard.currentLocation = newValue }
	}
	let locationManager: CLLocationManager = {
		$0.requestWhenInUseAuthorization()
		$0.desiredAccuracy = kCLLocationAccuracyBest
		$0.startUpdatingLocation()
		$0.startUpdatingHeading()
		return $0
	}(CLLocationManager())

	private func orientationAdjustment() -> CGFloat {
		let isFaceDown: Bool = {
			switch UIDevice.current.orientation {
			case .faceDown: return true
			default: return false
			}
		}()

		let adjAngle: CGFloat = {
			switch UIApplication.shared.statusBarOrientation {
			case .landscapeLeft:  return 90
			case .landscapeRight: return -90
			case .portrait, .unknown: return 0
			case .portraitUpsideDown: return isFaceDown ? 180 : -180
			}
		}()
		return adjAngle
	}









	// MARK:- Variables
	let markerIdentifier = "markerPin"
	//var locationManager : CLLocationManager!
	var geocodedWaypoints: [GeocodedWaypoint]!
	var routes: [Route]!
	var locations : Locations!


	// MARK:- GoogleMapsVariables
	var gmsMapView : GMSMapView!
	var userLocationMarker : GMSMarker!

	override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
				/*
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
				*/



				self.initGoogleMaps()
				self.initLocationManager()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
				configuration.worldAlignment = .gravityAndHeading

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    

}







/*

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/





// MARK: - ARSCNViewDelegate

extension ViewController : ARSCNViewDelegate {


	/*
	// Override to create and configure nodes for anchors added to the view's session.
	func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
	let node = SCNNode()

	return node
	}
	*/

	func session(_ session: ARSession, didFailWithError error: Error) {
		// Present an error message to the user

	}

	func sessionWasInterrupted(_ session: ARSession) {
		// Inform the user that the session has been interrupted, for example, by presenting an overlay

	}

	func sessionInterruptionEnded(_ session: ARSession) {
		// Reset tracking and/or remove existing anchors if consistent tracking is required

	}


}






/*

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/






// MARK:- Functions
extension ViewController {

	func initGoogleMaps() {
		let camera = GMSCameraPosition.camera(withLatitude: -33.86,longitude: 151.20,zoom: 6)
		gmsMapView = GMSMapView.map(withFrame: self.viewMapContainer.bounds, camera: camera)
		gmsMapView.settings.myLocationButton = true
		gmsMapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]


		gmsMapView.isMyLocationEnabled = false
		self.mapView.isHidden = true



		// Add the map to the view, hide it until we've got a location update.
		self.viewMapContainer.addSubview(gmsMapView)
		gmsMapView.isHidden = true

	}

	func initLocationManager() {



		locationManager.delegate = locationDelegate
		locationDelegate.locationCallback = { location in

			if self.latestLocation != nil {

				/*
				self.updateMarker(coordinates: location.coordinate, degrees:self.DegreeBearing(A: (self.latestLocation)!, B: location) , duration: 0.2)
				*/

				/*
				let updateCam = GMSCameraUpdate.setTarget(CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude))
				self.gmsMapView?.animate(with: updateCam)
				*/

				

			}

			self.latestLocation = location
			self.getDirectionsAndUpdateMap()


		}

		locationDelegate.headingCallback = { newHeading in

			func computeNewAngle(with newAngle: CGFloat) -> CGFloat {
				let heading: CGFloat = {
					let originalHeading = self.yourLocationBearing - newAngle.degreesToRadians
					switch UIDevice.current.orientation {
					case .faceDown: return -originalHeading
					default: return originalHeading
					}
				}()

				return CGFloat(self.orientationAdjustment().degreesToRadians + heading)
			}

			UIView.animate(withDuration: 0.5) {
				let angle = computeNewAngle(with: CGFloat(newHeading))
				print("This is the rotation angle : \(angle)")
				if self.userLocationMarker != nil {

					// Let's Rotate Map

					/*
					let updatedCamera = GMSCameraPosition.camera(withLatitude: (self.latestLocation?.coordinate.latitude)!,longitude: (self.latestLocation?.coordinate.longitude)!,zoom: 15,bearing: CLLocationDirection(angle),viewingAngle: 90)
					*/




					/*
					self.userLocationMarker.rotation = CLLocationDegrees(angle)
					*/
					/*
					self.updateMarker(coordinates: (self.latestLocation?.coordinate)!, degrees: CLLocationDegrees(self.yourLocationBearing), duration: 10.0)
					*/
					/*
					self.userLocationMarker.iconView?.transform = CGAffineTransform(rotationAngle: angle)
					*/

					self.userLocationMarker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
					self.userLocationMarker.rotation = newHeading + 180
					self.userLocationMarker.map = self.gmsMapView;
					print(self.userLocationMarker.rotation)
					self.gmsMapView.animate(toBearing: self.userLocationMarker.rotation - 180)
				}
				self.imageView.transform = CGAffineTransform(rotationAngle: angle)
			}
		}


		/*
		self.locationManager = CLLocationManager()
		self.locationManager.delegate = self
		self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
		self.mapView.showsUserLocation = true

		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingHeading()
		*/

	}

	func getDirectionsAndUpdateMap()
	{

		/*
		let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
		*/

		/*
		self.mapView.setRegion(region, animated: true)
		*/


		let camera = GMSCameraPosition.camera(withLatitude: latestLocation!.coordinate.latitude,longitude: latestLocation!.coordinate.longitude,zoom: 15)

		if gmsMapView.isHidden {
			gmsMapView.isHidden = false
			gmsMapView.camera = camera
			gmsMapView.animate(to: camera)

			userLocationMarker = GMSMarker(position: (latestLocation?.coordinate)!)
			userLocationMarker.icon = UIImage(named: "marker_direction")
			userLocationMarker.tracksViewChanges = true



			userLocationMarker.map = self.gmsMapView

		} else {
			userLocationMarker.position = (latestLocation?.coordinate)!
		}

		if self.locations != nil {
			self.locations.origin = (latestLocation?.coordinate)!
		} else {
			self.locations = Locations(orig: (latestLocation?.coordinate)!)
		}

		self.PerformWSToGetDirections()
	}

	func updateMarker(coordinates: CLLocationCoordinate2D, degrees: CLLocationDegrees, duration: Double){
		// Keep Rotation Short
		CATransaction.begin()
		CATransaction.setAnimationDuration(10.0)
		userLocationMarker.rotation = degrees
		CATransaction.commit()

		// Movement
		CATransaction.begin()
		CATransaction.setAnimationDuration(duration)
		userLocationMarker.position = coordinates

		// Center Map View
		let camera = GMSCameraUpdate.setTarget(coordinates)
		gmsMapView.animate(with: camera)

		CATransaction.commit()
	}

	func mapviewInit() {
		self.mapView.delegate = self

		/*
		self.mapView.register(MapviewAnnotation.self, forAnnotationViewWithReuseIdentifier: self.markerIdentifier)
		*/


	}


	func loadMapView() {
		let cam = MKMapCamera(lookingAtCenter: self.locations.destination, fromDistance: 20, pitch: 5, heading: 10)
		self.mapView.setCamera(cam, animated: true)
	}

	func createAnnotation() {
		let origin = MapviewAnnotation(title: "Origin",
													locationName: "",
													discipline: "",
													coordinate: (self.locationManager.location?.coordinate)!)
		self.mapView.addAnnotation(origin)

		let destination = MapviewAnnotation(title: "Destination",
																		locationName: "",
																		discipline: "",
																		coordinate: self.locations.destination)
		self.mapView.addAnnotation(destination)
	}

	func showPath() {

		let sourcePlacemark = MKPlacemark(coordinate: (self.locationManager.location?.coordinate)!, addressDictionary: nil)
		let destinationPlacemark = MKPlacemark(coordinate: self.locations.destination, addressDictionary: nil)


		let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
		let destinationMapItem = MKMapItem(placemark: destinationPlacemark)

		let directionRequest = MKDirections.Request()
		directionRequest.source = sourceMapItem
		directionRequest.destination = destinationMapItem
		directionRequest.transportType = .automobile

		// Calculate the direction
		let directions = MKDirections(request: directionRequest)

		directions.calculate {
			(response, error) -> Void in

			guard let response = response else {
				if let error = error {
					print("Error: \(error)")
				}

				return
			}

			let route = response.routes[0]
			self.mapView.addOverlay((route.polyline), level: MKOverlayLevel.aboveRoads)

			let rect = route.polyline.boundingMapRect
			self.mapView.setRegion(MKCoordinateRegion(rect), animated: true)
		}
	}

	func drawPolyline() {
		for route in self.routes {

			let start = CLLocationCoordinate2D(latitude: route.bounds.northeast.lat, longitude: route.bounds.northeast.lng)
			let end = CLLocationCoordinate2D(latitude: route.bounds.southwest.lat, longitude: route.bounds.southwest.lng)

			let locations :[CLLocationCoordinate2D] = [start,end]

			let aPolyline = MKPolyline(coordinates: locations, count: locations.count)

			self.mapView.addOverlay(aPolyline)


		}
	}

	func createPolyline() {

		let locations :[CLLocationCoordinate2D] = [(locationManager.location?.coordinate)!,self.locations.destination]

		let aPolyline = MKPolyline(coordinates: locations, count: locations.count)

		self.mapView.addOverlay(aPolyline)
	}

	func drawPath(from polyStr: String){
		let path = GMSPath(fromEncodedPath: polyStr)
		let polyline = GMSPolyline(path: path)
		polyline.strokeWidth = 3.0
		polyline.map = self.gmsMapView // Google MapView
	}


}




/*

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/





// MARK:- WebServices
extension ViewController {

	func PerformWSToGetDirections() {
		WebServices.shared.getGooglePlacesDirection(origin: self.locations.origin, destination: self.locations.destination) { (data) in

			let decoder = JSONDecoder()

			do {
				let FullResponse = try decoder.decode(GooglePlacesDirectionDC.self, from: data)

				if FullResponse.status == "OK" {

					print(FullResponse.routes)
					self.routes = FullResponse.routes
					self.geocodedWaypoints = FullResponse.geocodedWaypoints

					/*
					self.drawPolyline()
					*/

					for route in self.routes {
						let path = GMSPath.init(fromEncodedPath: route.overviewPolyline.points)
						let polyline = GMSPolyline.init(path: path)
						polyline.strokeWidth = 3

						_ = GMSCoordinateBounds(path: path!)
						/*
						self.gmsMapView!.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
						*/

						polyline.map = self.gmsMapView
					}

				} else {
				}



			} catch {
				print(error.localizedDescription)
			}

		}
	}
}





/*

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/






// MARK:- MKMapViewDelegate
extension ViewController : MKMapViewDelegate {

	func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {

	}

	func mapViewWillStartLoadingMap(_ mapView: MKMapView) {

	}

	func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {


	}


	func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {

		if let polyline = overlay as? MKPolyline {
			let testlineRenderer = MKPolylineRenderer(polyline: polyline)
			testlineRenderer.strokeColor = .blue
			testlineRenderer.lineWidth = 2.0
			return testlineRenderer
		} else {
			return MKOverlayRenderer()
		}
	}

	func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {


	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

		// 1
		guard let annotation = annotation as? MapviewAnnotation else { return nil }



		// 2
		var view: MKMarkerAnnotationView

		// 3
		if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: self.markerIdentifier)
			as? MKMarkerAnnotationView {
			dequeuedView.annotation = annotation
			view = dequeuedView
		} else {
			// 4
			view = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: self.markerIdentifier)
			view.canShowCallout = true
			view.calloutOffset = CGPoint(x: -5, y: 5)
			view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		}

		// 5
		return view


	}


}


/*

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/

extension ViewController {

	func DegreeBearing(A:CLLocation,B:CLLocation)-> Double{


		var dlon = self.ToRad(degrees: B.coordinate.longitude - A.coordinate.longitude)

		let dPhi = log(tan(self.ToRad(degrees: B.coordinate.latitude) / 2 + M_PI / 4) / tan(self.ToRad(degrees: A.coordinate.latitude) / 2 + M_PI / 4))

		if  abs(dlon) > M_PI{
			dlon = (dlon > 0) ? (dlon - 2*M_PI) : (2*M_PI + dlon)
		}
		return self.ToBearing(radians: atan2(dlon, dPhi))
	}

	func ToRad(degrees:Double) -> Double{
		return degrees*(M_PI/180)
	}

	func ToBearing(radians:Double)-> Double{
		return (ToDegrees(radians: radians) + 360) / 360
	}

	func ToDegrees(radians:Double)->Double{
		return radians * 180 / M_PI
	}

}

/*

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

*/





/*

// MARK:- CLLocationManagerDelegate
extension ViewController : CLLocationManagerDelegate {

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		let location = locations.last

		/*
		let center = CLLocationCoordinate2D(latitude: location!.coordinate.latitude, longitude: location!.coordinate.longitude)
		let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
		*/

		/*
		self.mapView.setRegion(region, animated: true)
		*/


		let camera = GMSCameraPosition.camera(withLatitude: location!.coordinate.latitude,longitude: location!.coordinate.longitude,zoom: 15)

		if gmsMapView.isHidden {
			gmsMapView.isHidden = false
			gmsMapView.camera = camera
			gmsMapView.animate(to: camera)

			userLocationMarker = GMSMarker(position: (location?.coordinate)!)
			userLocationMarker.icon = UIImage(named: "marker_direction")
			userLocationMarker.map = self.gmsMapView

		} else {
			userLocationMarker.position = (location?.coordinate)!
		}

		if self.locations != nil {
			self.locations.origin = (location?.coordinate)!
		} else {
			self.locations = Locations(orig: (location?.coordinate)!)
		}

		self.PerformWSToGetDirections()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {

		print("HEADING")
		print(newHeading.magneticHeading)
		if let lm = self.locationManager {
			let head = lm.location?.course ?? 0
			if self.gmsMapView != nil && self.userLocationMarker != nil{
				userLocationMarker.map = self.gmsMapView
				userLocationMarker.rotation = head
			}

		}


	}

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		if status == .authorizedWhenInUse {
			if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
				if CLLocationManager.isRangingAvailable() {
					// do stuff

				}
			}
		}
	}
}
*/
