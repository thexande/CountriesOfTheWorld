import Foundation

enum MockGraphQLQuery {
    
    typealias JSONObject = [String: Any]
    
    case country
    case countries
    
    var responseString: String {
        switch self {
        case .country:
            return MockGraphQLQuery.countryResponseString
        case .countries:
            return MockGraphQLQuery.countriesResponseString
        }
    }
    
    var responseObject: JSONObject? {
        
        guard
            let data = responseString.data(using: .utf8),
            let object = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONObject
            else {
                return nil
        }
        
        return object
    }
    
    private static let countriesResponseString =
    """
     {
         "data": {
             "countries": [{
                 "__typename": "Country",
                 "code": "USA",
                 "name": "America",
                 "emoji": "🇺🇸"
             }]
         }
     }
     """
    
    private static let countryResponseString =
    """
    {
        "data": {
            "country": {
                "code":"AE",
                "name": "United Arab Emirates",
                "currency": "AED",
                "phone": "971",
                "emoji": "🇦🇪",
                "native": "دولة الإمارات العربية المتحدة",
                "__typename": "Country",
                "languages": [{
                    "name": "Arabic",
                    "__typename": "Language"
                }],
                "continent": {
                    "name": "Asia",
                    "__typename": "Continent"
                }
            }
        }
    }
    """
}
