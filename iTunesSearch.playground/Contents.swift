//: Playground - noun: a place where people can play

import UIKit
import PlaygroundSupport


PlaygroundPage.current.needsIndefiniteExecution = true

// -----------------------

//extension URL {
//    func withQueries(_ queries: [String: String]) -> URL? {
//        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
//        components?.queryItems = queries.flatMap{ URLQueryItem(name: $0.0, value: $0.1) }
//        return components?.url
//    }
//}
//
//let baseURL = URL(string: "https://itunes.apple.com/search?")
//
//let query: [String: String] = [
//    "term": "one+republic",
//    "country": "US",
//    "media": "music",
//    "attribute": "artistTerm",
//    "limit": "5"
//]
//
//let url = baseURL?.withQueries(query)!
//
//
//
//let apiTask = URLSession.shared.dataTask(with: url!) { (data, response, error) in
//    if let data = data, let string = String(data: data, encoding: .utf8) {
//        print(string)
//    }
//}

//apiTask.resume()
//PlaygroundPage.current.finishExecution()


// ---------------------- LAB : Decoding JSON data into custom model objects : pg. 783 ----------------------//


struct StoreItem: Codable {
    var kind: String
    var artist: String
    var trackName: String
    var album: String
    var genre: String
    var artwork: URL
    var trackTimeMillis: Int
    var trackPrice: Double

    enum CodingKeys: String, CodingKey {
        case kind
        case artist = "artistName"
        case trackName
        case album = "collectionName"
        case genre = "primaryGenreName"
        case artwork = "artworkUrl100"
        case trackPrice
        case trackTimeMillis
    }

    enum additionalKeys: String, CodingKey {
        case trackCensoredName
    }

    init(from decoder: Decoder) throws {
        let keyedCodingContainer = try decoder.container(keyedBy: CodingKeys.self)
        kind = try keyedCodingContainer.decode(String.self, forKey: CodingKeys.kind)
        artist = try keyedCodingContainer.decode(String.self, forKey: CodingKeys.artist)
        album = try keyedCodingContainer.decode(String.self, forKey: CodingKeys.album)
        genre = try keyedCodingContainer.decode(String.self, forKey: CodingKeys.genre)
        artwork = try keyedCodingContainer.decode(URL.self, forKey: CodingKeys.artwork)
        trackTimeMillis = try keyedCodingContainer.decode(Int.self, forKey: CodingKeys.trackTimeMillis)
        trackPrice = try keyedCodingContainer.decode(Double.self, forKey: CodingKeys.trackPrice)


        // This is in to add data in case the 'specific' data is not found and another could be used.
        if let trackName = try? keyedCodingContainer.decode(String.self, forKey: CodingKeys.trackName) {
            self.trackName = trackName
        } else {
            let additionalKeyedCodingCont = try decoder.container(keyedBy: additionalKeys.self)
            trackName = (try? additionalKeyedCodingCont.decode(String.self, forKey: additionalKeys.trackCensoredName)) ?? ""
        }
    }
}

struct StoreItems: Codable {
    let results: [StoreItem]
}

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        components?.queryItems = queries.flatMap { URLQueryItem(name: $0.0, value: $0.1) }
        return components?.url
    }
}

let query: [String: String] = [
    "term": "one+republic",
    "country": "US",
    "media": "music",
    "attribute": "artistTerm",
    "limit": "2"
]

func fetchItems(matching query: [String: String], completion: @escaping ([StoreItem]?) -> Void) {

    let baseUrl = URL(string: "https://itunes.apple.com/search?")!

    guard let url = baseUrl.withQueries(query) else {
        completion(nil)
        print("Unable to build URL with supplied queries.")
        return
    }

    let apiTask = URLSession.shared.dataTask(with: url) { (data, response, error) in
        let jsonDecoder = JSONDecoder()
        if let data = data, let storeItems = try? jsonDecoder.decode(StoreItems.self, from: data) {
            completion(storeItems.results)
        } else {
            print("No data was returned or was not properly decoded.")
            completion(nil)
        }
    }
    
    apiTask.resume()
}

//fetchItems(matching: query, completion: {(fetchedInfo) in
//    if let fetchedInfo = fetchedInfo {
//        print(fetchedInfo)
//    }
//})

fetchItems(matching: query, completion: {(fetchedInfo) in
    guard let infoFromFetch = fetchedInfo else { return }
    for info in infoFromFetch {
        print("\\\\ \(info.trackName) ////")
        print("artist: \(info.artist)")
        print("album: \(info.album)")
        print("price: $\(info.trackPrice)")
        
        let millisecs = info.trackTimeMillis
        let mins = (Double(millisecs)*0.0000166667).rounded(.towardZero)
        let secModule = (Double(millisecs)*0.0000166667).truncatingRemainder(dividingBy: 1.0)
        let secs = secModule * 60
        
        print("length: \(Int(mins)) minutes, \(Int(secs)) seconds")
        
        // store item (the result we are looking for)
        print(info)
    }
})
