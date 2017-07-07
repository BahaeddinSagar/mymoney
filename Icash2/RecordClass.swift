//
//  RecordClass.swift
//
//  Created by Bahaeddin Sagar on 6/2/17
//  Copyright (c) . All rights reserved.
//

import Foundation
import SwiftyJSON

public final class RecordClass: NSCoding {

  // MARK: Declaration for string constants to be used to decode and also serialize.
  private struct SerializationKeys {
    static let opType = "OpType"
    static let closing = "Closing"
    static let desc = "Desc"
    static let id = "id"
    static let opning = "Opning"
    static let crdit = "Crdit"
    static let debt = "Debt"
    static let transDate = "TransDate"
  }

  // MARK: Properties
  public var opType: Int?
  public var closing: Int?
  public var desc: String?
  public var id: Int?
  public var opning: Int?
  public var crdit: Int?
  public var debt: Int?
  public var transDate: String?

  // MARK: SwiftyJSON Initializers
  /// Initiates the instance based on the object.
  ///
  /// - parameter object: The object of either Dictionary or Array kind that was passed.
  /// - returns: An initialized instance of the class.
  public convenience init(object: Any) {
    self.init(json: JSON(object))
  }

  /// Initiates the instance based on the JSON that was passed.
  ///
  /// - parameter json: JSON object from SwiftyJSON.
  public required init(json: JSON) {
    opType = json[SerializationKeys.opType].int
    closing = json[SerializationKeys.closing].int
    desc = json[SerializationKeys.desc].string
    id = json[SerializationKeys.id].int
    opning = json[SerializationKeys.opning].int
    crdit = json[SerializationKeys.crdit].int
    debt = json[SerializationKeys.debt].int
    transDate = json[SerializationKeys.transDate].string
  }

  /// Generates description of the object in the form of a NSDictionary.
  ///
  /// - returns: A Key value pair containing all valid values in the object.
  public func dictionaryRepresentation() -> [String: Any] {
    var dictionary: [String: Any] = [:]
    if let value = opType { dictionary[SerializationKeys.opType] = value }
    if let value = closing { dictionary[SerializationKeys.closing] = value }
    if let value = desc { dictionary[SerializationKeys.desc] = value }
    if let value = id { dictionary[SerializationKeys.id] = value }
    if let value = opning { dictionary[SerializationKeys.opning] = value }
    if let value = crdit { dictionary[SerializationKeys.crdit] = value }
    if let value = debt { dictionary[SerializationKeys.debt] = value }
    if let value = transDate { dictionary[SerializationKeys.transDate] = value }
    return dictionary
  }

  // MARK: NSCoding Protocol
  required public init(coder aDecoder: NSCoder) {
    self.opType = aDecoder.decodeObject(forKey: SerializationKeys.opType) as? Int
    self.closing = aDecoder.decodeObject(forKey: SerializationKeys.closing) as? Int
    self.desc = aDecoder.decodeObject(forKey: SerializationKeys.desc) as? String
    self.id = aDecoder.decodeObject(forKey: SerializationKeys.id) as? Int
    self.opning = aDecoder.decodeObject(forKey: SerializationKeys.opning) as? Int
    self.crdit = aDecoder.decodeObject(forKey: SerializationKeys.crdit) as? Int
    self.debt = aDecoder.decodeObject(forKey: SerializationKeys.debt) as? Int
    self.transDate = aDecoder.decodeObject(forKey: SerializationKeys.transDate) as? String
  }

  public func encode(with aCoder: NSCoder) {
    aCoder.encode(opType, forKey: SerializationKeys.opType)
    aCoder.encode(closing, forKey: SerializationKeys.closing)
    aCoder.encode(desc, forKey: SerializationKeys.desc)
    aCoder.encode(id, forKey: SerializationKeys.id)
    aCoder.encode(opning, forKey: SerializationKeys.opning)
    aCoder.encode(crdit, forKey: SerializationKeys.crdit)
    aCoder.encode(debt, forKey: SerializationKeys.debt)
    aCoder.encode(transDate, forKey: SerializationKeys.transDate)
  }

}
