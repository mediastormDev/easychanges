public typealias EasyChangeElement = Equatable & Identifiable & Hashable

public enum EasyChange<Element: EasyChangeElement>: Equatable, Hashable {
    case insert(offset: Int, element: Element)
    case remove(offset: Int, element: Element)
    case move(from: Int, to: Int, element: Element)
    case change(offset: Int, oldElement: Element, newElement: Element)
}

extension CollectionDifference where ChangeElement: EasyChangeElement {
    public func easyChanges() -> [EasyChange<ChangeElement>] {
        var changes: [EasyChange<ChangeElement>] = []
        var removeOffsetsById: [ChangeElement.ID: Int] = [:]
        var oldElementsById: [ChangeElement.ID: ChangeElement] = [:]
        var removeIds: [ChangeElement.ID] = []
        
        for change in self.removals.reversed() {
            guard case let .remove(offset, element, associatedWith) = change else { fatalError() }
            if let newPosition = associatedWith {
                changes.append(.move(from: offset, to: newPosition, element: element))
            } else {
                removeOffsetsById[element.id] = offset
                oldElementsById[element.id] = element
                removeIds.append(element.id)
            }
        }
        
        for change in self.insertions {
            guard case let .insert(offset, element, associatedWith) = change else { fatalError() }
            if associatedWith != nil { continue }
            if
                let prevOffset = removeOffsetsById[element.id],
                let oldElement = oldElementsById[element.id]
            {
                if prevOffset != offset {
                    changes += [
                        .change(offset: prevOffset, oldElement: oldElement, newElement: element),
                        .move(from: prevOffset, to: offset, element: element)
                    ]
                } else {
                    changes.append(
                        .change(offset: offset, oldElement: oldElement, newElement: element)
                    )
                }
                
                removeOffsetsById[element.id] = nil
                oldElementsById[element.id] = nil
                removeIds.remove(at: removeIds.firstIndex(of: element.id)!)
            } else {
                changes.append(.insert(offset: offset, element: element))
            }
        }
        
        let removeChanges = removeIds.map { id in
            EasyChange.remove(offset: removeOffsetsById[id]!, element: oldElementsById[id]!)
        }
        
        return removeChanges + changes
    }
}
