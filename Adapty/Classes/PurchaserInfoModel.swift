//
//  PurchaserInfoModel.swift
//  Adapty
//
//  Created by Andrey Kyashkin on 04/02/2020.
//

import Foundation

public class PurchaserInfoModel: NSObject, JSONCodable, Codable {
    @objc public var profileId: String
    @objc public var customerUserId: String?
    @objc public var customAttributes: Parameters
    @objc public var accessLevels: [String: AccessLevelInfoModel]
    @objc public var subscriptions: [String: SubscriptionInfoModel]
    @objc public var nonSubscriptions: [String: [NonSubscriptionInfoModel]]

    required init?(json: Parameters) throws {
        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }

        guard
            let profileId = attributes?["id"] as? String
        else {
            throw AdaptyError.missingParam("PurchaserInfoModel - id")
        }

        self.profileId = profileId
        customerUserId = attributes?["customer_user_id"] as? String

        var customAttributes = Parameters()
        if let custom = attributes?["custom_attributes"] as? Parameters, !custom.isEmpty {
            custom.forEach { key, value in
                switch value {
                case let value as Bool:
                    customAttributes[key] = value
                case let value as Int:
                    customAttributes[key] = value
                case let value as String:
                    customAttributes[key] = value
                case let value as Double:
                    customAttributes[key] = value
                case let value as CGFloat:
                    customAttributes[key] = value
                default:
                    break
                }
            }
        }

        var accessLevels = [String: AccessLevelInfoModel]()
        var subscriptions = [String: SubscriptionInfoModel]()
        var nonSubscriptions = [String: [NonSubscriptionInfoModel]]()
        do {
            if let data = attributes?["paid_access_levels"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? Parameters else {
                        continue
                    }

                    accessLevels[key] = try AccessLevelInfoModel(json: value)
                }
            }

            if let data = attributes?["subscriptions"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? Parameters else {
                        continue
                    }

                    subscriptions[key] = try SubscriptionInfoModel(json: value)
                }
            }

            if let data = attributes?["non_subscriptions"] as? Parameters {
                for (key, value) in data {
                    guard let value = value as? [Parameters] else {
                        continue
                    }

                    var valuesArray = [NonSubscriptionInfoModel]()
                    try value.forEach { params in
                        if let nonSubscriptionInfoModel = try NonSubscriptionInfoModel(json: params) { valuesArray.append(nonSubscriptionInfoModel) }
                    }
                    nonSubscriptions[key] = valuesArray
                }
            }
        } catch {
            throw error
        }

        self.customAttributes = customAttributes
        self.accessLevels = accessLevels
        self.subscriptions = subscriptions
        self.nonSubscriptions = nonSubscriptions
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? PurchaserInfoModel else {
            return false
        }

        return
            profileId == object.profileId &&
            customerUserId == object.customerUserId &&
            accessLevels == object.accessLevels &&
            subscriptions == object.subscriptions &&
            nonSubscriptions == object.nonSubscriptions
    }

    enum CodingKeys: String, CodingKey {
        case profileId
        case customerUserId
        case customAttributes
        case accessLevels
        case subscriptions
        case nonSubscriptions
    }

    struct JSONCodingKeys: CodingKey {
        var stringValue: String

        init(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.init(stringValue: "\(intValue)")
            self.intValue = intValue
        }
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        profileId = try container.decode(String.self, forKey: .profileId)
        customerUserId = try container.decodeIfPresent(String.self, forKey: .customerUserId)
        if container.contains(.customAttributes) {
            let nestedContainer = try container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .customAttributes)
            var dictionary = [String: Any]()
            for key in nestedContainer.allKeys {
                if let boolValue = try? nestedContainer.decode(Bool.self, forKey: key) {
                    dictionary[key.stringValue] = boolValue
                } else if let stringValue = try? nestedContainer.decode(String.self, forKey: key) {
                    dictionary[key.stringValue] = stringValue
                } else if let intValue = try? nestedContainer.decode(Int.self, forKey: key) {
                    dictionary[key.stringValue] = intValue
                } else if let doubleValue = try? nestedContainer.decode(Double.self, forKey: key) {
                    dictionary[key.stringValue] = doubleValue
                }
            }
            customAttributes = dictionary
        } else {
            customAttributes = [:]
        }
        accessLevels = try container.decode([String: AccessLevelInfoModel].self, forKey: .accessLevels)
        subscriptions = try container.decode([String: SubscriptionInfoModel].self, forKey: .subscriptions)
        nonSubscriptions = try container.decode([String: [NonSubscriptionInfoModel]].self, forKey: .nonSubscriptions)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(profileId, forKey: .profileId)
        try container.encodeIfPresent(customerUserId, forKey: .customerUserId)
        if !customAttributes.isEmpty {
            var nestedContainer = container.nestedContainer(keyedBy: JSONCodingKeys.self, forKey: .customAttributes)
            try customAttributes.forEach { key, value in
                let key = JSONCodingKeys(stringValue: key)
                switch value {
                case let value as Bool:
                    try nestedContainer.encode(value, forKey: key)
                case let value as Int:
                    try nestedContainer.encode(value, forKey: key)
                case let value as String:
                    try nestedContainer.encode(value, forKey: key)
                case let value as Double:
                    try nestedContainer.encode(value, forKey: key)
                case let value as CGFloat:
                    try nestedContainer.encode(value, forKey: key)
                default:
                    break
                }
            }
        }
        try container.encodeIfPresent(accessLevels, forKey: .accessLevels)
        try container.encodeIfPresent(subscriptions, forKey: .subscriptions)
        try container.encodeIfPresent(nonSubscriptions, forKey: .nonSubscriptions)
    }
}

public class AccessLevelInfoModel: NSObject, JSONCodable, Codable {
    @objc public var id: String
    @objc public var isActive: Bool
    @objc public var vendorProductId: String
    @objc public var store: String
    @objc public var activatedAt: Date?
    @objc public var renewedAt: Date?
    @objc public var expiresAt: Date?
    @objc public var isLifetime: Bool
    @objc public var activeIntroductoryOfferType: String?
    @objc public var activePromotionalOfferType: String?
    @objc public var willRenew: Bool
    @objc public var isInGracePeriod: Bool
    @objc public var unsubscribedAt: Date?
    @objc public var billingIssueDetectedAt: Date?
    @objc public var vendorTransactionId: String?
    @objc public var vendorOriginalTransactionId: String?
    @objc public var startsAt: Date?
    @objc public var cancellationReason: String?
    @objc public var isRefund: Bool

    required init?(json: Parameters) throws {
        guard
            let id = json["id"] as? String,
            let isActive = json["is_active"] as? Bool
        else {
            throw AdaptyError.missingParam("AccessLevelInfoModel - id, is_active")
        }

        self.id = id
        self.isActive = isActive
        vendorProductId = json["vendor_product_id"] as? String ?? ""
        store = json["store"] as? String ?? ""
        activatedAt = (json["activated_at"] as? String)?.dateValue
        renewedAt = (json["renewed_at"] as? String)?.dateValue
        expiresAt = (json["expires_at"] as? String)?.dateValue
        isLifetime = json["is_lifetime"] as? Bool ?? false
        activeIntroductoryOfferType = json["active_introductory_offer_type"] as? String
        activePromotionalOfferType = json["active_promotional_offer_type"] as? String
        willRenew = json["will_renew"] as? Bool ?? false
        isInGracePeriod = json["is_in_grace_period"] as? Bool ?? false
        unsubscribedAt = (json["unsubscribed_at"] as? String)?.dateValue
        billingIssueDetectedAt = (json["billing_issue_detected_at"] as? String)?.dateValue
        vendorTransactionId = json["vendor_transaction_id"] as? String
        vendorOriginalTransactionId = json["vendor_original_transaction_id"] as? String
        startsAt = (json["starts_at"] as? String)?.dateValue
        cancellationReason = json["cancellation_reason"] as? String
        isRefund = json["is_refund"] as? Bool ?? false
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? AccessLevelInfoModel else {
            return false
        }

        return
            id == object.id &&
            isActive == object.isActive &&
            vendorProductId == object.vendorProductId &&
            store == object.store &&
            activatedAt == object.activatedAt &&
            renewedAt == object.renewedAt &&
            expiresAt == object.expiresAt &&
            isLifetime == object.isLifetime &&
            activeIntroductoryOfferType == object.activeIntroductoryOfferType &&
            activePromotionalOfferType == object.activePromotionalOfferType &&
            willRenew == object.willRenew &&
            isInGracePeriod == object.isInGracePeriod &&
            unsubscribedAt == object.unsubscribedAt &&
            billingIssueDetectedAt == object.billingIssueDetectedAt &&
            vendorTransactionId == object.vendorTransactionId &&
            vendorOriginalTransactionId == object.vendorOriginalTransactionId &&
            startsAt == object.startsAt &&
            cancellationReason == object.cancellationReason &&
            isRefund == object.isRefund
    }
}

public class SubscriptionInfoModel: NSObject, JSONCodable, Codable {
    @objc public var isActive: Bool
    @objc public var vendorProductId: String
    @objc public var store: String
    @objc public var activatedAt: Date?
    @objc public var renewedAt: Date?
    @objc public var expiresAt: Date?
    @objc public var startsAt: Date?
    @objc public var isLifetime: Bool
    @objc public var activeIntroductoryOfferType: String?
    @objc public var activePromotionalOfferType: String?
    @objc public var willRenew: Bool
    @objc public var isInGracePeriod: Bool
    @objc public var unsubscribedAt: Date?
    @objc public var billingIssueDetectedAt: Date?
    @objc public var isSandbox: Bool
    @objc public var vendorTransactionId: String?
    @objc public var vendorOriginalTransactionId: String?
    @objc public var cancellationReason: String?
    @objc public var isRefund: Bool

    required init?(json: Parameters) throws {
        guard
            let isActive = json["is_active"] as? Bool,
            let vendorProductId = json["vendor_product_id"] as? String
        else {
            throw AdaptyError.missingParam("SubscriptionInfoModel - is_active, vendor_product_id")
        }

        self.isActive = isActive
        self.vendorProductId = vendorProductId
        store = json["store"] as? String ?? ""
        activatedAt = (json["activated_at"] as? String)?.dateValue
        renewedAt = (json["renewed_at"] as? String)?.dateValue
        expiresAt = (json["expires_at"] as? String)?.dateValue
        startsAt = (json["starts_at"] as? String)?.dateValue
        isLifetime = json["is_lifetime"] as? Bool ?? false
        activeIntroductoryOfferType = json["active_introductory_offer_type"] as? String
        activePromotionalOfferType = json["active_promotional_offer_type"] as? String
        willRenew = json["will_renew"] as? Bool ?? false
        isInGracePeriod = json["is_in_grace_period"] as? Bool ?? false
        unsubscribedAt = (json["unsubscribed_at"] as? String)?.dateValue
        billingIssueDetectedAt = (json["billing_issue_detected_at"] as? String)?.dateValue
        isSandbox = json["is_sandbox"] as? Bool ?? false
        vendorTransactionId = json["vendor_transaction_id"] as? String
        vendorOriginalTransactionId = json["vendor_original_transaction_id"] as? String
        cancellationReason = json["cancellation_reason"] as? String
        isRefund = json["is_refund"] as? Bool ?? false
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? SubscriptionInfoModel else {
            return false
        }

        return
            isActive == object.isActive &&
            vendorProductId == object.vendorProductId &&
            store == object.store &&
            activatedAt == object.activatedAt &&
            renewedAt == object.renewedAt &&
            expiresAt == object.expiresAt &&
            startsAt == object.startsAt &&
            isLifetime == object.isLifetime &&
            activeIntroductoryOfferType == object.activeIntroductoryOfferType &&
            activePromotionalOfferType == object.activePromotionalOfferType &&
            willRenew == object.willRenew &&
            isInGracePeriod == object.isInGracePeriod &&
            unsubscribedAt == object.unsubscribedAt &&
            billingIssueDetectedAt == object.billingIssueDetectedAt &&
            isSandbox == object.isSandbox &&
            vendorTransactionId == object.vendorTransactionId &&
            vendorOriginalTransactionId == object.vendorOriginalTransactionId &&
            cancellationReason == object.cancellationReason &&
            isRefund == object.isRefund
    }
}

public class NonSubscriptionInfoModel: NSObject, JSONCodable, Codable {
    @objc public var purchaseId: String
    @objc public var vendorProductId: String
    @objc public var store: String
    @objc public var purchasedAt: Date?
    @objc public var isOneTime: Bool
    @objc public var isSandbox: Bool
    @objc public var vendorTransactionId: String?
    @objc public var vendorOriginalTransactionId: String?
    @objc public var isRefund: Bool

    required init?(json: Parameters) throws {
        guard
            let purchaseId = json["purchase_id"] as? String,
            let vendorProductId = json["vendor_product_id"] as? String
        else {
            throw AdaptyError.missingParam("NonSubscriptionInfoModel - purchase_id, vendor_product_id")
        }

        self.purchaseId = purchaseId
        self.vendorProductId = vendorProductId
        store = json["store"] as? String ?? ""
        purchasedAt = (json["purchased_at"] as? String)?.dateValue
        isOneTime = json["is_one_time"] as? Bool ?? false
        isSandbox = json["is_sandbox"] as? Bool ?? false
        vendorTransactionId = json["vendor_transaction_id"] as? String
        vendorOriginalTransactionId = json["vendor_original_transaction_id"] as? String
        isRefund = json["is_refund"] as? Bool ?? false
    }

    override public func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? NonSubscriptionInfoModel else {
            return false
        }

        return
            purchaseId == object.purchaseId &&
            vendorProductId == object.vendorProductId &&
            store == object.store &&
            purchasedAt == object.purchasedAt &&
            isOneTime == object.isOneTime &&
            isSandbox == object.isSandbox &&
            vendorTransactionId == object.vendorTransactionId &&
            vendorOriginalTransactionId == object.vendorOriginalTransactionId &&
            isRefund == object.isRefund
    }
}

class PurchaserInfoMeta: JSONCodable {
    var purchaserInfo: PurchaserInfoModel?
    var appleValidationResult: Parameters?

    required init?(json: Parameters) throws {
        do {
            purchaserInfo = try PurchaserInfoModel(json: json)
        } catch {
            throw AdaptyError.invalidProperty("PurchaserInfoMeta - purchaser_info", json)
        }

        let attributes: Parameters?
        do {
            attributes = try json.attributes()
        } catch {
            throw error
        }

        appleValidationResult = attributes?["apple_validation_result"] as? Parameters
    }
}
