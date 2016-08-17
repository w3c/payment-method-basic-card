@startuml
!includeurl https://raw.githubusercontent.com/w3c/webpayments-flows/gh-pages/PaymentFlows/skin.ipml

Participant "Processor [Acquirer]" as MPSP
Participant "Payee (Merchant) [Acceptor] Website" as Payee
participant "Payer's (Shopper's) Browser" as UA
Actor "Payer [Cardholder]" as Payer

participant "Payment Mediator" as UAM
participant "Payment App" as PSPUI

participant "Issuing Bank [Issuer]" as CPSP

note over Payee, PSPUI: HTTPS

title Merchant Hosted Card Payment with Payment Credentials Payment Application

== Negotiation of Payment Terms  & Selection of Payment Instrument ==

Payee->UA: Present Check-out page 
Payer<-[#green]>UA: Select Checkout
Payer<-[#green]>Payee: Establish Payment Obligation (including delivery obligations)
Payee->UA: Payment and delivery details

UA->UAM: PaymentRequest (Items, Amounts, Shipping Options )
note right #aqua: PaymentRequest.Show()
opt
	Payer<-[#green]>UAM: Select Shipping Options	
	UAM->UA: Shipping Info
	note right #aqua: shippingoptionchange or shippingaddresschange events

	UA->UAM: Revised PaymentRequest
end
Payer<-[#green]>UAM: Select <b><color:red>Card</color></b> Payment Apps/Instrument

UAM<-[#green]>PSPUI: Invoke <b><color:red>Card</color></b> Payment App

UAM->PSPUI: PaymentRequest (- Options)

Payer<-[#green]>PSPUI: Authorise

PSPUI->UAM: <b><color:red>Card Details </color></b>

note left
	Card Details from BasicCardResponse
	PAN, [Name], [Expiry], [CSC], [BillingAddress]
endnote

UAM->UA: <b><color:red>Card Details</color></b>

Note Right #aqua: Show() Promise Resolves 


== Payment Processing ==

note over UA: Payment Processing is unchanged from Pre-WebPayment

Alt
	UA->Payee: payload
Else
	UA->Payee: Encrypt(payload)
	Note right: Custom code on merchant webpage can encrypt payload to reduce PCI burden from SAQ D to SAQ A-EP
End

opt
	Payee->Payee: Store Card
	note right: Merchant can store card details (apart from CSC) (even if encrypted) for future use (a.k.a. Card on File)
end

Payee-\MPSP: Authorise (payload)

MPSP-\CPSP: Authorisation Request
CPSP-/MPSP: Authorisation Response

MPSP-/Payee: Authorisation Result

== Notification ==

UA->UAM: Payment Completion Status

note over UAM #aqua: response.complete(status)

UAM->UA: UI Removed

note over UAM #aqua: complete promise resolves

UA->UA: Navigate to Result Page

== Payment Processing Continued: Request for Settlement process (could be immediate, batch (e.g. daily) or after some days) ==

Alt
	Payee -> MPSP : Capture
	note right: Later Capture may be called, for example after good shipped or tickets pickedup
Else
	MPSP -> MPSP : Auto Capture in batch
End	
	
MPSP->CPSP: Capture

== Delivery of Product ==

Payee->Payer: Provide products or services


@enduml
