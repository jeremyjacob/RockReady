//
//  MPDataStore.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/21/23.
//

import Foundation

struct MPDownloadedPackage: Codable {
    var id: Int
    var title: String
    var data: MPPackageData
}

class MPDataStore: ObservableObject {
    @Published var packages: [MPDownloadedPackage] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
        .appendingPathComponent("packages.data")
    }
    
    func load() async throws {
        let task = Task<[MPDownloadedPackage], Error> {
            let fileURL = try Self.fileURL()
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            let packages = try JSONDecoder().decode([MPDownloadedPackage].self, from: data)
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
