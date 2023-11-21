//
//  MPDataParser.swift
//  RockReady
//
//  Created by Jeremy Jacob on 6/21/23.
//

import Foundation

struct MPPhotoData: Codable {
    let id: Int
    let text: String?
    let userId: Int
    let scoreAvg: Float
    let scoreCount: Int
    let sizes: MPPhotoSizes
}

enum MPPhoto: Codable {
    case one(MPPhotoData)
    case many([MPPhotoData])

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            let array = try container.decode([MPPhotoData].self)
            self = .many(array)
        } catch {
            let dict = try container.decode(MPPhotoData.self)
            self = .one(dict)
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .many(let array):
            try container.encode(array)
        case .one(let photo):
            try container.encode(photo)
        }
    }
}

struct MPPhotoSize: Codable {
    let w: Int
    let h: Int
    let url: String
}

struct MPPhotoSizes: Codable {
    let thumb: MPPhotoSize?
    let small: MPPhotoSize?
    let medium: MPPhotoSize?
    let large: MPPhotoSize?
}


struct MPHeaderData: Codable {
    let id: Int
    let buildDate: Int
    let numLines: Int
}

struct MPAreaData: Codable {
    let id: Int
    let title: String
    let titleSearch: String
    let userId: Int
    let parentId: Int?
    let x: Int
    let y: Int
    let numRoutes: Int
    let numTrad: Int
    let numSport: Int
    let numTR: Int
    let numRock: Int
    let numIce: Int
    let numBoulder: Int
    let numAid: Int
    let numMixed: Int
    let numAlpine: Int
    let pageViewsMonthly: Int
    let accessNotes: [Int]
    let photoCount: Int
    let climate: String
}

struct MPRouteData: Codable {
    let title: String
    let titleSearch: String
    let userId: Int
    let parentId: Int
    let positionInArea: Int
    let numPitches: Int
    let accessNotes: [Int]
    let stars: Float
    let numVotes: Int
    let type: String
    let fa: String
    let ratingRock: Int
    let ratingBoulder: Int
    let ratingIce: Int
    let ratingMixed: Int
    let ratingAid: Int
    let ratingSnow: Int
    let ratingSafety: String
    let grade: String
    let height: Int
    let popularity: Int
    let firstPhoto: MPPhoto
}

struct MPApproachData: Codable {
    let id: Int
    let title: String
    let description: String
    let descent: Float
    let points: String
}

struct MPPackageData: Codable {
    let header: MPHeaderData
    let areas: [MPAreaData]
    let routes: [MPRouteData]
    let approaches: [MPApproachData]
}

struct RawBlock {
    let identifier: UInt8
    let content: String
}

func parseMPPackage(_ package: Data) -> MPPackageData? {
    let separator = Data(repeating: 0, count: 6)
    var blocks = split(package, by: separator)[1...]
    
    if blocks.count % 2 != 0 {
        blocks = blocks.dropLast()
    }
    
    let grouped = stride(from: 1, to: blocks.count, by: 2).map {
        let identifier = [UInt8](trimNulls((blocks[$0])))[0]
//        let bytesToDrop = blocks[$0+1].last! < 32 ? 2 : 1
        let bytesToDrop = 2;
        let contentData = trimNulls((blocks[$0+1]).dropLast(bytesToDrop))
        let content = repairJson(json: String(decoding: contentData, as: UTF8.self))
        
//        let dataAsHexStr = blocks[$0+1].map { String(format: "%02hhx", $0) }.joined()
//        if content.last != "}" && content.last != "]" {
//            print(bytesToDrop, String(format: "%02hhx", identifier), dataAsHexStr, "\n\n")
//        }
        return RawBlock(identifier: identifier, content: content)
    }
    
    
    let decoded = decodeMPData(from: grouped);
    return decoded
}

private func decodeMPData(from: [RawBlock]) -> MPPackageData? {
    var header: MPHeaderData?
    var areas = [MPAreaData]()
    var routes = [MPRouteData]()
    var approaches = [MPApproachData]()
    
    for block in from {
        let decoder = JSONDecoder()
        let data = Data(block.content.utf8)
        switch block.identifier {
            case 0x01:
                header = try? decoder.decode(MPHeaderData.self, from: data)
            case 0x02:
                areas.append(try! decoder.decode(MPAreaData.self, from: data))
            case 0x03:
                routes.append(try! decoder.decode(MPRouteData.self, from: data))
//            case 0x0A:
//                approaches.append(try! decoder.decode(MPApproachData.self, from: data))
            default:
                break
        }
    }
    
    if let header = header {
        return MPPackageData(header: header, areas: areas, routes: routes, approaches: approaches)
    }
    return nil
}

private func split(_ data: Data, by divider: Data) -> [Data] {
    var splitData = [Data]()
    var searchRange = 0..<data.count
    
    while let foundRange = data.range(of: divider, options: [], in: searchRange) {
        let subdata = data.subdata(in: searchRange.lowerBound..<foundRange.lowerBound)
        splitData.append(subdata)
        searchRange = foundRange.upperBound..<data.count
    }
    
    let lastSubdata = data.subdata(in: searchRange.lowerBound..<data.count)
    splitData.append(lastSubdata)
    
    return splitData
}

private func trimNulls(_ data: Data) -> Data {
    var trimmedData = data
    while trimmedData.first == 0x00 {
        trimmedData = trimmedData.dropFirst()
    }
    while trimmedData.last == 0x00 {
        trimmedData = trimmedData.dropLast()
    }
    return trimmedData
}

func repairJson(json: String) -> String {
    var repairedJson = json
    var openCurlyBrackets = 0
    var closeCurlyBrackets = 0
    var openSquareBrackets = 0
    var closeSquareBrackets = 0
    var insideQuotes = false
    var previousCharacter: Character? = nil

    for character in json {
        if character == "\"" && previousCharacter != "\\" {
            insideQuotes = !insideQuotes
        }

        if !insideQuotes {
            if character == "{" {
                openCurlyBrackets += 1
            } else if character == "}" {
                closeCurlyBrackets += 1
            } else if character == "[" {
                openSquareBrackets += 1
            } else if character == "]" {
                closeSquareBrackets += 1
            }
        }
        
        previousCharacter = character
    }

    if closeCurlyBrackets < openCurlyBrackets {
        let missingCurlyBrackets = openCurlyBrackets - closeCurlyBrackets
        repairedJson.append(contentsOf: String(repeating: "}", count: missingCurlyBrackets))
    }

    if closeSquareBrackets < openSquareBrackets {
        let missingSquareBrackets = openSquareBrackets - closeSquareBrackets
        repairedJson.append(contentsOf: String(repeating: "]", count: missingSquareBrackets))
    }

    return repairedJson
}
