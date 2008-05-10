Class {
	#name : #JsonObject,
	#superclass : #Object,
	#instVars : [
		'properties'
	],
	#category : #JSON
}

{ #category : #'as yet unclassified' }
JsonObject >> at: key ifAbsent: aBlock [
	^ (properties detect: [:ea | ea key = key] ifNone: [^ aBlock value]) value
]

{ #category : #'as yet unclassified' }
JsonObject >> at: key put: value [
	properties add: key -> value
]

{ #category : #'as yet unclassified' }
JsonObject >> doesNotUnderstand: aMessage [
	| key |
	key := aMessage selector.
	key isUnary ifTrue: [^ self at: key ifAbsent: [super doesNotUnderstand: aMessage]].
	^ (key isKeyword and: [(key occurrencesOf: $:) = 1])
		ifTrue: [key := key allButLast asSymbol.
				self at: key put: aMessage arguments first]
		ifFalse: [super doesNotUnderstand: aMessage]
				
	
]

{ #category : #'as yet unclassified' }
JsonObject >> initialize [
	properties := OrderedCollection new
]

{ #category : #'as yet unclassified' }
JsonObject >> jsonWriteOn: aStream [
	aStream nextPut: ${.
	properties
		do: 
			[:ea | 
			ea key asString jsonWriteOn: aStream.
			aStream nextPutAll: ': '.
			ea value jsonWriteOn: aStream]
		separatedBy: [aStream nextPutAll: ', '].
	aStream nextPut: $}.
]

{ #category : #'as yet unclassified' }
JsonObject >> properties [
	^ properties
]
