import SwiftUI
import VisionSugar

//TODO: Move this to SwiftSugar
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

extension Array where Element == RecognizedText {

    var description: String {
        map { $0.string }.joined(separator: ", ")
    }
    
    func filterSameColumn(as recognizedText: RecognizedText, preceding: Bool = false) -> [RecognizedText] {
        var column: [RecognizedText] = []
        var discarded: [RecognizedText] = []
        let candidates = filter {
            $0.isInSameColumnAs(recognizedText)
            && (preceding ? $0.rect.maxY < recognizedText.rect.maxY : $0.rect.minY > recognizedText.rect.minY)
        }.sorted {
            $0.rect.minY < $1.rect.minY
        }

        /// Deal with multiple recognizedTexts we may have grabbed from the same row due to them both overlapping with `recognizedText` by choosing the one that intersects with it the most
        for candidate in candidates {

            guard !discarded.contains(candidate) else {
                continue
            }
            let row = candidates.filter {
                $0.isInSameRowAs(candidate)
            }
            guard row.count > 1, let first = row.first else {
                column.append(candidate)
                continue
            }
            
            var closest = first
            for rowElement in row {
                /// first normalize the y values of both rects, `rowElement`, `closest` to `recognizedText` in new temporary variables, by assigning both the same y values (`origin.y` and `size.height`)
                let yNormalizedRect = rowElement.rect.rectWithYValues(of: recognizedText.rect)
                let closestYNormalizedRect = closest.rect.rectWithYValues(of: recognizedText.rect)

                let intersection = yNormalizedRect.intersection(recognizedText.rect)
                let closestIntersection = closestYNormalizedRect.intersection(recognizedText.rect)

                let intersectionRatio = intersection.width / rowElement.rect.width
                let closestIntersectionRatio = closestIntersection.width / closest.rect.width

                if intersectionRatio > closestIntersectionRatio {
                    closest = rowElement
                }
                
                discarded.append(rowElement)
            }
            
            column.append(closest)
            
        }
        
        return column
    }
    
    func filterSameRow(as recognizedText: RecognizedText, preceding: Bool = false) -> [RecognizedText] {
//        log.verbose(" ")
//        log.verbose("******")
//        log.verbose("Finding recognizedTextsOnSameLine as: \(recognizedText.string)")
        var row: [RecognizedText] = []
        var discarded: [RecognizedText] = []
        let candidates = filter {
            $0.isInSameRowAs(recognizedText)
            && (preceding ? $0.rect.maxX < recognizedText.rect.minX : $0.rect.minX > recognizedText.rect.maxX)
        }.sorted {
            $0.rect.minX < $1.rect.minX
        }

//        log.verbose("candidates are:")
//        log.verbose("\(candidates.map { $0.string })")

        /// Deal with multiple recognizedText we may have grabbed from the same column due to them both overlapping with `recognizedText` by choosing the one that intersects with it the most
        for candidate in candidates {

//            log.verbose("  finding recognizedTexts in same column as: \(candidate.string)")

            guard !discarded.contains(candidate) else {
//                log.verbose("  this recognizedText has been discarded, so ignoring it")
                continue
            }
            let column = candidates.filter {
                $0.isInSameColumnAs(candidate)
            }
            guard column.count > 1, let first = column.first else {
//                log.verbose("  no recognizedTexts in same column, so adding this to the final array and continuing")
                row.append(candidate)
                continue
            }
            
//            log.verbose("  found these recognizedTexts in the same column:")
//            log.verbose("  \(column.map { $0.string })")

//            log.verbose("  setting closest as \(first.string)")
            var closest = first
            for columnElement in column {
//                log.verbose("    checking if \(columnElement.string) is a closer candidate")
                /// first normalize the x values of both rects, `columnElement`, `closest` to `recognizedText` in new temporary variables, by assigning both the same x values (`origin.x` and `size.width`)
                let xNormalizedRect = columnElement.rect.rectWithXValues(of: recognizedText.rect)
                let closestXNormalizedRect = closest.rect.rectWithXValues(of: recognizedText.rect)

//                log.verbose("    xNormalizedRect is: \(xNormalizedRect)")
//                log.verbose("    closestXNormalizedRect is: \(closestXNormalizedRect)")

                let intersection = xNormalizedRect.intersection(recognizedText.rect)
                let closestIntersection = closestXNormalizedRect.intersection(recognizedText.rect)
//                log.verbose("    intersection is: \(intersection)")
//                log.verbose("    closestIntersection is: \(closestIntersection)")

//                log.verbose("    Checking if intersection.height(\(intersection.height)) > closestIntersection.height(\(closestIntersection.height))")
                /// now compare these intersection of both the x-normalized rects with `recognizedText` itself, and return whichever intersection rect has a larger height (indicating which one is more 'in line' with `recognizedText`)
                if intersection.height > closestIntersection.height {
//                    log.verbose("    It is greater, so setting closest as: \(sameColumnElement.string)")
                    closest = columnElement
                } else {
//                    log.verbose("    It isn't greater, so leaving closest as it was")
                }
                
//                log.verbose("    Adding \(columnElement.string) to the discarded pile")
                discarded.append(columnElement)
            }
            
            
//            log.verbose("  Now that we've gone through all the \(column.count) columnElements, we're appending the final closest: \(closest.string) to row")
            row.append(closest)
            
        }
        
//        log.verbose("Finally, we have row as:")
//        log.verbose("\(row.map { $0.string })")
        
        return row
    }
    
    func nextRecognizedTextOnSameLine(as recognizedText: RecognizedText) -> RecognizedText? {
        filterSameRow(as: recognizedText).first
    }
    
    func valueOnSameLine(as recognizedText: RecognizedText, inSecondColumn: Bool = false) -> RecognizedText? {
        /// Set this bool to true if we're looking for the second value so that the first value gets ignored
        var ignoreNextValue = inSecondColumn
        var returnNilIfNextRecognizedTextDoesNotContainValue = false
        let recognizedTextsOnSameLine = filterSameRow(as: recognizedText)
        for recognizedText in recognizedTextsOnSameLine {
            if recognizedText.containsValue {
                /// Keep looking if we're after the second column
                guard !ignoreNextValue else {
                    /// Reset this so that we actually grab the next value
                    ignoreNextValue = false
                    continue
                }
                return recognizedText
            } else if returnNilIfNextRecognizedTextDoesNotContainValue {
                return nil
            }
            if recognizedText.containsPercentage {
                returnNilIfNextRecognizedTextDoesNotContainValue = true
            } else {
                return nil
            }
        }
        return nil
    }
}
