//
//  MapviewAnnotation.swift
//  ARModelWithGPS
//
//  Created by dev shanghai on 15/03/2019.
//  Copyright © 2019 dev_shanghai. All rights reserved.
//

import Foundation
import MapKit

class MapviewAnnotation: NSObject, MKAnnotation {
	let title: String?
	let locationName: String
	let discipline: String
	let coordinate: CLLocationCoordinate2D

	init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
		self.title = title
		self.locationName = locationName
		self.discipline = discipline
		self.coordinate = coordinate

		super.init()
	}

	var subtitle: String? {
		return locationName
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

}
