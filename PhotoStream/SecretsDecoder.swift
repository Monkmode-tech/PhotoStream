//
//  SecretsDecoder.swift
//  PhotoStream
//
//  Created by Caleb Tetteh on 11/20/25.
//

import Foundation

enum Secrets {
    static var pexelsAPIKey: String {
        guard let apiKey = Bundle.main.infoDictionary?["PEXELS_API_KEY"] as? String else {
            fatalError("PEXELS_API_KEY not found in Info.plist")
        }
        return apiKey
    }
}
