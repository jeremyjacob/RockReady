//
//  MPDataStore.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/21/23.
//

import Foundation
import Gzip

struct MPDownloadedPackage: Codable {
    var id: Int
    var title: String
    var data: MPPackageData
}

class MPPackageStore: ObservableObject {
    @Published var packages: [Int:MPDownloadedPackage] = [:]

    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("packages.data")
    }
    
    private static func mountainProjectPackageURL(id: Int) -> URL {
        let urlString = "https://cdn2.apstatic.com/mobile/climb/V2-\(id).txt.gz"
        let url = URL(string: urlString)!
        return url
    
    }
    
    func downloadPackage(id: Int) async throws {
        let url = Self.mountainProjectPackageURL(id: id)
        let gzipped = try Data(contentsOf: url)
        let data = try gzipped.gunzipped()
        guard let parsed = parseMPPackage(data) else { return }
        let package = MPDownloadedPackage(id: parsed.header.id, title: "Unknown", data: parsed)
        try await add(package: package)
    }
    
    @MainActor
    func add(package: MPDownloadedPackage) async throws {
        let task = Task<[Int:MPDownloadedPackage], Error> {
            var packages = self.packages
            packages[package.id] = package
            return packages
        }
        self.packages = try await task.value
    }
    
    @MainActor
    func load() async throws {
        let task = Task<[Int:MPDownloadedPackage], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return [:]
            }
            let packages = try JSONDecoder().decode([Int:MPDownloadedPackage].self, from: data)
            return packages
        }
        let packages = try await task.value
        self.packages = packages
    }
    
    func save() async throws {
        let task = Task {
            let data = try JSONEncoder().encode(packages)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
        }
        _ = try await task.value
    }
    
}
