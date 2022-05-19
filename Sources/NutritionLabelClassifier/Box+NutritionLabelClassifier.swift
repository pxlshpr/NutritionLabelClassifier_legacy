import SwiftUI
import VisionSugar

extension Box {
    var isValueBasedClass: Bool {
        attribute?.isValueBased ?? false
    }

    var attribute: NutritionLabelAttribute? {
        for classifierClass in NutritionLabelAttribute.allCases {
            guard let regex = classifierClass.regex else { continue }
            if string.matchesRegex(regex) {
                return classifierClass
            }
        }
        return nil
    }
    
    var containsValue: Bool {
        string.matchesRegex(#"[0-9]+[.,]*[0-9]*[ ]*(mg|ug|g|kj|kcal)"#)
    }
    
    var containsPercentage: Bool {
        string.matchesRegex(#"[0-9]+[.,]*[0-9]*[ ]*%"#)
    }
}

extension CGRect {
    func rectWithXValues(of rect: CGRect) -> CGRect {
        CGRect(x: rect.origin.x, y: origin.y,
               width: rect.size.width, height: size.height)
    }
    
    func rectWithYValues(of rect: CGRect) -> CGRect {
        CGRect(x: origin.x, y: rect.origin.y,
               width: size.width, height: rect.size.height)
    }

}

extension Array where Element == Box {

    var description: String {
        map { $0.string }.joined(separator: ", ")
    }
    
    func boxesOnSameColumn(as box: Box, preceding: Bool = false) -> [Box] {
        var sameColumnBoxes: [Box] = []
        var discardedBoxes: [Box] = []
        let candidates = filter {
            $0.isInSameColumnAs(box)
            && (preceding ? $0.rect.maxY < box.rect.maxY : $0.rect.minY > box.rect.minY)
        }.sorted {
            $0.rect.minY < $1.rect.minY
        }

        /// Deal with multiple boxes we may have grabbed from the same row due to them both overlapping with `box` by choosing the one that intersects with it the most
        for candidate in candidates {

            guard !discardedBoxes.contains(candidate) else {
                continue
            }
            let sameRowBoxes = candidates.filter {
                $0.isInSameRowAs(candidate)
            }
            guard sameRowBoxes.count > 1, let first = sameRowBoxes.first else {
                sameColumnBoxes.append(candidate)
                continue
            }
            
            var closestBox = first
            for sameRowBox in sameRowBoxes {
                /// first normalize the y values of both rects, `sameRowBox`, `closestBox` to `box` in new temporary variables, by assigning both the same y values (`origin.y` and `size.height`)
                let sameRowBoxYNormalizedRect = sameRowBox.rect.rectWithYValues(of: box.rect)
                let closestBoxYNormalizedRect = closestBox.rect.rectWithYValues(of: box.rect)

                let sameRowBoxIntersection = sameRowBoxYNormalizedRect.intersection(box.rect)
                let closestBoxIntersection = closestBoxYNormalizedRect.intersection(box.rect)

                let sameRowBoxIntersectionRatio = sameRowBoxIntersection.width / sameRowBox.rect.width
                let closestBoxIntersectionRatio = closestBoxIntersection.width / closestBox.rect.width

                if sameRowBoxIntersectionRatio > closestBoxIntersectionRatio {
                    closestBox = sameRowBox
                }
                
                discardedBoxes.append(sameRowBox)
            }
            
            sameColumnBoxes.append(closestBox)
            
        }
        
        return sameColumnBoxes
    }
    
    func boxesOnSameLine(as box: Box, preceding: Bool = false) -> [Box] {
//        log.verbose(" ")
//        log.verbose("******")
//        log.verbose("Finding boxesOnSameLine as: \(box.string)")
        var sameLineBoxes: [Box] = []
        var discardedBoxes: [Box] = []
        let candidates = filter {
            $0.isInSameRowAs(box)
            && (preceding ? $0.rect.maxX < box.rect.minX : $0.rect.minX > box.rect.maxX)
        }.sorted {
            $0.rect.minX < $1.rect.minX
        }

//        log.verbose("candidates are:")
//        log.verbose("\(candidates.map { $0.string })")

        /// Deal with multiple boxes we may have grabbed from the same column due to them both overlapping with `box` by choosing the one that intersects with it the most
        for candidate in candidates {

//            log.verbose("  finding boxes in same column as: \(candidate.string)")

            guard !discardedBoxes.contains(candidate) else {
//                log.verbose("  this box has been discarded, so ignoring it")
                continue
            }
            let sameColumnBoxes = candidates.filter {
                $0.isInSameColumnAs(candidate)
            }
            guard sameColumnBoxes.count > 1, let first = sameColumnBoxes.first else {
//                log.verbose("  no boxes in same column, so adding this to the final array and continuing")
                sameLineBoxes.append(candidate)
                continue
            }
            
//            log.verbose("  found these boxes in the same column:")
//            log.verbose("  \(sameColumnBoxes.map { $0.string })")

//            log.verbose("  setting closestBox as \(first.string)")
            var closestBox = first
//            var sameColumnBoxesToDiscard: [Box] = []
            for sameColumnBox in sameColumnBoxes {
//                log.verbose("    checking if \(sameColumnBox.string) is a closer candidate")
                /// first normalize the x values of both rects, `sameColumnBox`, `closestBox` to `box` in new temporary variables, by assigning both the same x values (`origin.x` and `size.width`)
                let sameColumnBoxXNormalizedRect = sameColumnBox.rect.rectWithXValues(of: box.rect)
                let closestBoxXNormalizedRect = closestBox.rect.rectWithXValues(of: box.rect)

//                log.verbose("    sameColumnBoxXNormalizedRect is: \(sameColumnBoxXNormalizedRect)")
//                log.verbose("    closestBoxXNormalizedRect is: \(closestBoxXNormalizedRect)")

                let sameColumnBoxIntersection = sameColumnBoxXNormalizedRect.intersection(box.rect)
                let closestBoxIntersection = closestBoxXNormalizedRect.intersection(box.rect)
//                log.verbose("    sameColumnBoxIntersection is: \(sameColumnBoxIntersection)")
//                log.verbose("    closestBoxIntersection is: \(closestBoxIntersection)")

//                log.verbose("    Checking if sameColumnBoxIntersection.height(\(sameColumnBoxXNormalizedRect.intersection(box.rect).height)) > closestBoxIntersection.height(\(closestBoxXNormalizedRect.intersection(box.rect).height))")
                /// now compare these intersection of both the x-normalized rects with `box` itself, and return whichever intersection rect has a larger height (indicating which one is more 'in line' with `box`)
                if sameColumnBoxIntersection.height > closestBoxIntersection.height {
//                    log.verbose("    It is greater, so setting closest box as: \(sameColumnBox.string)")
                    closestBox = sameColumnBox
                } else {
//                    log.verbose("    It isn't greater, so leaving closest box as it was")
                }
                
//                log.verbose("    Adding \(sameColumnBox.string) to the discarded boxes pile")
//                sameColumnBoxesToDiscard.append(sameColumnBox)
                discardedBoxes.append(sameColumnBox)
            }
            
            /// Check the potential boxes to discard
//            for sameColumnBoxToDiscard in sameColumnBoxesToDiscard {
//                /// If lining it up with the `closestBox` would intersect it, then do in fact discard it—otherwise leave it
//                if sameColumnBoxToDiscard.rect.rectWithYValues(of: closestBox.rect).intersects(closestBox.rect) {
//                    discardedBoxes.append(sameColumnBoxToDiscard)
//                }
//            }
            
//            log.verbose("  Now that we've gone through all the \(sameColumnBoxes.count) sameColumnBoxes, we're appending the final closestBox: \(closestBox.string) to sameLineBoxes")
            sameLineBoxes.append(closestBox)
            
        }
        
//        log.verbose("Finally, we have sameLineBoxes as:")
//        log.verbose("\(sameLineBoxes.map { $0.string })")
        
        return sameLineBoxes
    }
    
    func nextBoxOnSameLine(as box: Box) -> Box? {
        boxesOnSameLine(as: box).first
    }
    
    func valueBoxOnSameLine(as box: Box, inSecondColumn: Bool = false) -> Box? {
        /// Set this bool to true if we're looking for the second value so that the first value gets ignored
        var ignoreNextValue = inSecondColumn
        var returnNilIfNextBoxDoesNotContainValue = false
        let boxesOnSameLine = boxesOnSameLine(as: box)
        for box in boxesOnSameLine {
            if box.containsValue {
                /// Keep looking if we're after the second column
                guard !ignoreNextValue else {
                    /// Reset this so that we actually grab the next value
                    ignoreNextValue = false
                    continue
                }
                return box
            } else if returnNilIfNextBoxDoesNotContainValue {
                return nil
            }
            if box.containsPercentage {
                returnNilIfNextBoxDoesNotContainValue = true
            } else {
                return nil
            }
        }
        return nil
    }
}
