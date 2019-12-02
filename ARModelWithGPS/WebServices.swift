//
//  WebServices.swift
//  ARModelWithGPS
//
//  Created by dev shanghai on 15/03/2019.
//  Copyright © 2019 dev_shanghai. All rights reserved.
//

import Foundation
import Alamofire
import MapKit

class WebServices
{
	// Singolton Instance
	static let shared = WebServices()

	// Initialisation
	init(){}


	func getGooglePlacesDirection(origin : CLLocationCoordinate2D, destination : CLLocationCoordinate2D ,completion : @escaping (Data) -> ()) {
		
		let travelMode = "Driving"

		let url : URL = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&mode=\(travelMode)&key=\(Constants.Keys.dgoogleDirectionAPIKey)")!

		Alamofire.request(url, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: nil)
			.responseJSON { response in


				completion(response.data!)
		}

	}


}
