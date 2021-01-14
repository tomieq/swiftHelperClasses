//
//  CoreDataDump.swift
//
//  Created by Tomasz Kucharski on 12/01/2021.
//  Helper class to see what's stored in CoreData
//  Data can be converted to json in order to transfer to 3rd party app to visualize
//
// Sample usage:
/*

 let dump = CoreDataDump(persistentContainer: DatabaseController.persistentContainer)
 Logger.v("DBG", "Entities: \(dump.getAllEntityNames())")
 Logger.v("DBG", "json: \(dump.dumpObjectsToJson(forEntityName: "ComplexGroup"))")
 Logger.v("DBG", "json: \(dump.dumpObjectsToJson(forEntityName: "ComplexCellData"))")
 */

import Foundation
import CoreData


class CoreDataDump {
    let persistentContainer: NSPersistentContainer
    
    init(persistentContainer: NSPersistentContainer) {
        self.persistentContainer = persistentContainer
    }
    
    func getAllEntityNames() -> [String] {
        return self.persistentContainer.managedObjectModel.entitiesByName.map{$0.key}.sorted()
    }
    
    func getPropertyNames(forEntityName entityName: String) -> [String] {
        return self.persistentContainer.managedObjectModel.entitiesByName[entityName]?.attributesByName.map{ $0.key }.sorted() ?? []
    }
    
    func getRelationshipNames(forEntityName entityName: String) -> [String] {
        return self.persistentContainer.managedObjectModel.entitiesByName[entityName]?.relationshipsByName.map{ $0.key }.sorted() ?? []
    }
    
    func convertToDict(object: NSManagedObject) -> [String: Any] {
        
        var dict: [String: Any] = [:]
        if let entityName = object.entity.name {

            let propertyNames = self.getPropertyNames(forEntityName: entityName)
            let relationshipNames = self.getRelationshipNames(forEntityName: entityName)
            dict["_objectID"] = self.formatObjectID(object)
            
            propertyNames.forEach { propertyName in
                let value = self.unwrap(object.primitiveValue(forKey: propertyName))
                dict[propertyName] = value
            }
            
            relationshipNames.forEach { relationshipName in
                var relationIDs: [String] = []
                let uwrappedObject = self.unwrap(object.value(forKey: relationshipName))
                if let relatedObjects = uwrappedObject as? NSSet {
                
                    for case let relatedObject as NSManagedObject in relatedObjects {
                        relationIDs.append(self.formatObjectID(relatedObject))
                    }
                } else if let relatedObject = uwrappedObject as? NSManagedObject {
                    relationIDs.append(self.formatObjectID(relatedObject))
                }
                relationIDs.sort()
                dict[relationshipName] = relationIDs
            }
        }
        return dict
    }
    
    func convertToJson(dict: [String: Any]) -> String {
        var options = JSONSerialization.WritingOptions.prettyPrinted
        if #available(iOS 11.0, *) {
            options = [JSONSerialization.WritingOptions.prettyPrinted, JSONSerialization.WritingOptions.sortedKeys]
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: options) {
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        }
        return "{}"
    }
    
    func convertToJson(object: NSManagedObject) -> String {
        let dict = self.convertToDict(object: object)
        return self.convertToJson(dict: dict)
    }
    
    func convertToDictList(forEntityName entityName: String) -> [[String: Any]] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let objects = (try? self.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject]) ?? []
        return objects.map{ self.convertToDict(object: $0) }
    }
    
    func convertToDictList<T>(forFetchRequest fetchRequest: NSFetchRequest<T>) -> [[String: Any]] {
        let objects = (try? self.persistentContainer.viewContext.fetch(fetchRequest) as? [NSManagedObject]) ?? []
        return objects.map{ self.convertToDict(object: $0) }
    }
    
    func convertToJson(entityName: String) -> String {
        let list = self.convertToDictList(forEntityName: entityName)
        var options = JSONSerialization.WritingOptions.prettyPrinted
        if #available(iOS 11.0, *) {
            options = [JSONSerialization.WritingOptions.prettyPrinted, JSONSerialization.WritingOptions.sortedKeys]
        }
        if let jsonData = try? JSONSerialization.data(withJSONObject: list, options: options) {
            return String(data: jsonData, encoding: .utf8) ?? "{}"
        }
        return "{}"
    }
    
    private func formatObjectID(_ object: NSManagedObject) -> String {
        return "\(object.entity.name ?? "").\(object.objectID.uriRepresentation().lastPathComponent)"
    }
    
    private func unwrap<T>(_ any: T) -> Any {
        let mirror = Mirror(reflecting: any)
        guard mirror.displayStyle == .optional, let first = mirror.children.first else {
            return any
        }
        return first.value
    }
}

fileprivate extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}
