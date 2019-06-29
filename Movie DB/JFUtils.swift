//
//  JFUtils.swift
//  Movie DB
//
//  Created by Jonas Frey on 24.06.19.
//  Copyright © 2019 Jonas Frey. All rights reserved.
//

import Foundation

/*enum JFLiterals: String {
    
}*/

struct JFUtils {
    static func dateFromTMDBString(_ string: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: string)
    }
    
    static func yearOfDate(_ date: Date) -> Int {
        let cal = Calendar.current
        return cal.component(.year, from: date)
    }
    
    static func getRequest(_ urlString: String, parameters: [String: Any?], completion: @escaping (Data?) -> Void) {
        let urlStringWithParameters = "\(urlString)?\(parameters.percentEscaped())"
        var request = URLRequest(url: URL(string: urlStringWithParameters)!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                                              // check for fundamental networking error
                    print("error", error ?? "Unknown error")
                    completion(nil)
                    return
            }
            
            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                print("headerFields = \(String(describing: response.allHeaderFields))")
                print("data = \(String(data: data, encoding: .utf8) ?? "nil")")
                completion(nil)
                return
            }
            
            completion(data)
        }.resume()
    }
}

enum JFLiterals: String {
    case apiKey = "e4304a9deeb9ed2d62eb61d7b9a2da71"
}

extension Dictionary where Key == String, Value == Any? {
    func percentEscaped() -> String {
        return map { (key, value) in
            let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value ?? "null")".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
            }
            .joined(separator: "&")
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="
        
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
