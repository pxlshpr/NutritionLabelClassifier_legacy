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

extension String {

    var valueSubstringAtStart: String? {
        //TODO: Modularize this and substringUpToFirstNumeral handling not capturing the entire strings with a workaround
        let regex = Value.Regex.atStartOfString
        let groups = trimmingWhitespaces.capturedGroups(using: regex, allowCapturingEntireString: true)
        let substring: String?
        if groups.count > 1 {
            substring = groups[1]
        } else if groups.count == 1 {
            substring = groups[0]
        } else {
            substring = nil
        }
        return substring?.trimmingWhitespaces
    }
    
    var substringUpToFirstNumeral: String? {
        let regex = #"^([0-9]*[^0-9\n]+)[0-9]?.*$"#
        let groups = trimmingWhitespaces.capturedGroups(using: regex, allowCapturingEntireString: true)
        let substring: String?
        if groups.count > 1 {
            substring = groups[1]
        } else if groups.count == 1 {
            substring = groups[0]
        } else {
            substring = nil
        }
        return substring?.trimmingWhitespaces
    }
    
    var trimmingWhitespaces: String {
        trimmingCharacters(in: .whitespaces)
    }
}
