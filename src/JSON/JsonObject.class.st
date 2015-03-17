Class {
	#name : #JsonObject,
	#superclass : #Dictionary,
	#category : #JSON
}

{ #category : #'as yet unclassified' }
JsonObject class >> fromAssociations: collectionOfAssociations [

	| result |
	result := self new.
	
	collectionOfAssociations do: [:each |
		result at: each key put: each value ].
	^ result
]

{ #category : #accessing }
JsonObject >> at: aKey [

	"make it work more like javascript objects"
	^ self at: aKey ifAbsent: [nil]
]

{ #category : #'as yet unclassified' }
JsonObject >> doesNotUnderstand: aMessage [
	| key |
	key := aMessage selector.
	key isUnary ifTrue: [^ self at: key ifAbsent: [nil]].
	^ (key isKeyword and: [(key occurrencesOf: $:) = 1])
		ifTrue: [key := key allButLast asSymbol.
				self at: key put: aMessage arguments first]
		ifFalse: [super doesNotUnderstand: aMessage]
				
	
]

{ #category : #accessing }
JsonObject >> name [
"override 'cause Object defines this"
	^self at: 'name'
]

{ #category : #accessing }
JsonObject >> value [
"override 'cause Object defines this"
	^self at: 'value'
]
