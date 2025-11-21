import Foundation
import SwiftUI

actor PersistentImageCache {
    private let cacheDirectory: URL
    private let cacheLifetime: TimeInterval = 60 * 60 * 3 // 3 hours
    private var memoryCache: [String: UIImage] = [:]
    private var cacheTimestamps: [String: Date] = [:]
    
    init() {
        let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
        self.cacheDirectory = paths[0].appendingPathComponent("ImageCache")
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
        self.cacheTimestamps = PersistentImageCache.loadTimestamps(from: self.cacheDirectory)
    }
    
    func image(forKey key: String) -> UIImage? {
        if let image = memoryCache[key], let timestamp = cacheTimestamps[key], Date().timeIntervalSince(timestamp) < cacheLifetime {
            return image
        }
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = try? Data(contentsOf: fileURL), let image = UIImage(data: data) {
            memoryCache[key] = image
            cacheTimestamps[key] = Date()
            saveTimestamps()
            return image
        }
        return nil
    }
    
    func setImage(_ image: UIImage, forKey key: String) {
        memoryCache[key] = image
        cacheTimestamps[key] = Date()
        let fileURL = cacheDirectory.appendingPathComponent(key)
        if let data = image.pngData() {
            try? data.write(to: fileURL)
        }
        saveTimestamps()
    }
    
    func clearExpiredCache() {
        let now = Date()
        for (key, timestamp) in cacheTimestamps {
            if now.timeIntervalSince(timestamp) >= cacheLifetime {
                memoryCache.removeValue(forKey: key)
                let fileURL = cacheDirectory.appendingPathComponent(key)
                try? FileManager.default.removeItem(at: fileURL)
                cacheTimestamps.removeValue(forKey: key)
            }
        }
        saveTimestamps()
    }
    
    private func timestampsFileURL() -> URL {
        cacheDirectory.appendingPathComponent("timestamps.json")
    }
    
    private func saveTimestamps() {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(cacheTimestamps) {
            try? data.write(to: timestampsFileURL())
        }
    }
    
    private static func loadTimestamps(from cacheDirectory: URL) -> [String: Date] {
        let url = cacheDirectory.appendingPathComponent("timestamps.json")
        guard let data = try? Data(contentsOf: url) else { return [:] }
        let decoder = JSONDecoder()
        if let loaded = try? decoder.decode([String: Date].self, from: data) {
            return loaded
        }
        return [:]
    }
}
