//
//  STPCard.h
//  Stripe
//
//  Created by Saikat Chakrabarti on 11/2/12.
//
//

#import <Foundation/Foundation.h>
#import "STPFormEncodeProtocol.h"

typedef NS_ENUM(NSInteger, STPCardFundingType) {
    STPCardFundingTypeDebit,
    STPCardFundingTypeCredit,
    STPCardFundingTypePrepaid,
    STPCardFundingTypeOther,
};

typedef NS_ENUM(NSInteger, STPCardBrand) {
    STPCardBrandVisa,
    STPCardBrandAmex,
    STPCardBrandMasterCard,
    STPCardBrandDiscover,
    STPCardBrandJCB,
    STPCardBrandDinersClub,
    STPCardBrandUnknown,
};

/*
 This object represents a credit card.  You should create these and populate
 its properties with information that your customer enters on your credit card
 form.  Then you create tokens from these.
 */
@interface STPCard : NSObject<STPFormEncodeProtocol>

@property (nonatomic, copy) NSString *number;
@property (nonatomic) NSUInteger expMonth;
@property (nonatomic) NSUInteger expYear;
@property (nonatomic, copy) NSString *cvc;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *addressLine1;
@property (nonatomic, copy) NSString *addressLine2;
@property (nonatomic, copy) NSString *addressCity;
@property (nonatomic, copy) NSString *addressState;
@property (nonatomic, copy) NSString *addressZip;
@property (nonatomic, copy) NSString *addressCountry;

@property (nonatomic, readonly) NSString *cardId;
@property (nonatomic, readonly) NSString *object;
@property (nonatomic, readonly) NSString *last4;
/**
 *  The issuer of the card.
 */
@property (nonatomic, readonly) STPCardBrand brand;
/**
 *  The issuer of the card.
 *  Can be one of "Visa", "American Express", "MasterCard", "Discover", "JCB", "Diners Club", or "Unknown"
 *  @deprecated use "brand" instead.
 */
@property (nonatomic, readonly) NSString *type __attribute__((deprecated));
;
/**
 *  The funding source for the card (credit, debit, prepaid, or other)
 */
@property (nonatomic, readonly) STPCardFundingType funding;
@property (nonatomic, readonly) NSString *fingerprint;
@property (nonatomic, readonly) NSString *country;

- (BOOL)isEqualToCard:(STPCard *)other;

/* These validation methods work as described in
    http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/KeyValueCoding/Articles/Validation.html#//apple_ref/doc/uid/20002173-CJBDBHCB
*/
- (BOOL)validateNumber:(id *)ioValue error:(NSError **)outError;
- (BOOL)validateCvc:(id *)ioValue error:(NSError **)outError;
- (BOOL)validateExpMonth:(id *)ioValue error:(NSError **)outError;
- (BOOL)validateExpYear:(id *)ioValue error:(NSError **)outError;

/*
 This validates a fully populated card to check for all errors, including ones
 that come about from the interaction of more than one property. It will also do
 all the validations on individual properties, so if you only want to call one
 method on your card to validate it after setting all the properties, call this
 one.
 */
- (BOOL)validateCardReturningError:(NSError **)outError;

@end

@interface STPCard (StripePrivateMethods)
/*
 You should not use this constructor.  This constructor is used by Stripe to
 generate cards from the response of creating ar getting a token.
 */
- (instancetype)initWithAttributeDictionary:(NSDictionary *)attributeDictionary;
@end
