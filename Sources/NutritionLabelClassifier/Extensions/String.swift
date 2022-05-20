import Foundation

extension String {
    var trimmingPercentageValues: String {
        let regex = #"([0-9]*[ ]*%)"#
        
        var trimmedString = self
        while true {
            let groups = trimmedString.capturedGroups(using: regex)
            guard let percentageSubstring = groups.first else {
                break
            }
            
            trimmedString = trimmedString.replacingOccurrences(of: percentageSubstring, with: "")
        }
        return trimmedString
    }
    
    var hasBothKjAndKcal: Bool {
        let regex = #"^.*[0-9]+[ ]*kj.*[0-9]+[ ]*kcal.*$|^.*[0-9]+[ ]*kcal.*[0-9]+[ ]*kj.*$"#
        return self.matchesRegex(regex)
    }
}
