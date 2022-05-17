//
//  GisConverter.swift
//
//  Created by Tomasz Kucharski on 26/01/2022.
//

import Foundation

struct GisConverter {
    private static let radius: Double = 6378137.0

    static func convert4326To3857(longitude: Double, latitude: Double) -> (x: Double, y: Double) {
        let x = longitude.degreesToRadians * self.radius
        let y = log(tan(Double.pi / 4 + (latitude.degreesToRadians / 2))) * self.radius

        return (x, y)
    }

    static func convert3857To4326(x: Double, y: Double) -> (longitude: Double, latitude: Double) {
        let long4326 = (x / GisConverter.radius).radiansToDegrees
        let lat4326 = (atan(exp(y / self.radius)) * 2 - Double.pi / 2).radiansToDegrees

        return (long4326, lat4326)
    }
}

extension Double {
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension FloatingPoint {
    var degreesToRadians: Self { self * .pi / 180 }
    var radiansToDegrees: Self { self * 180 / .pi }
}
