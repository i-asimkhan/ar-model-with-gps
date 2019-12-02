//
//  Constants.swift
//  ARModelWithGPS
//
//  Created by dev shanghai on 15/03/2019.
//  Copyright © 2019 dev_shanghai. All rights reserved.
//

import Foundation
import MapKit

struct Constants {

	struct Keys {
		static let dgoogleDirectionAPIKey = "AIzaSyDkrOzRnpqKqZyILyyBAyYci4mar44fRQc"

		static let googleMapsKey = "AIzaSyBCD6WzOvL26ukTeJDAvgAdnmiFCVEl6R4"

		static let googlePlacesKey = "AIzaSyBCD6WzOvL26ukTeJDAvgAdnmiFCVEl6R4"



	}

	struct NotificationKey {
		static let Welcome = "kWelcomeNotif"
	}

	struct Path {
		static let Documents = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
		static let Tmp = NSTemporaryDirectory()
	}
}



class Locations {

	/*
	static let shared = Locations()
	*/

	var origin : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

	var destination : CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)

	

	init() {

		// Mall of Emirates
		self.origin = CLLocationCoordinate2D(latitude: 25.1181, longitude: 55.2006)

		// Burj Khalifa
		self.destination = CLLocationCoordinate2D(latitude: 25.1972, longitude: 55.2744)
	}

	init(orig : CLLocationCoordinate2D) {
		self.origin = orig
		// Burj Khalifa
		self.destination = CLLocationCoordinate2D(latitude: 25.1972, longitude: 55.2744)
	}

	init(orig : CLLocationCoordinate2D, dest: CLLocationCoordinate2D) {
		self.origin = orig
		self.destination = dest
	}

	func setOrigin(orig : CLLocationCoordinate2D) {
		self.origin = orig
	}

	func setDest(dest : CLLocationCoordinate2D) {
		self.destination = dest
	}

	func getOrigin() -> CLLocationCoordinate2D {
		return self.origin
	}

	func getDestination() -> CLLocationCoordinate2D {
		return self.destination
	}

}
