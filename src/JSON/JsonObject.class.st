Class {
	#name : #JsonObject,
	#superclass : #Object,
	#instVars : [
		'properties'
	],
	#category : #JSON
}

{ #category : #'as yet unclassified' }
JsonObject class >> newFrom: aDict [
	| result p |
	result := self new.
	p := result properties.
	aDict associationsDo: [:a | p add: a].
	^ result
]

{ #category : #'as yet unclassified' }
JsonObject >> = anObject [
	(anObject isKindOf: JsonObject)
		ifTrue: [^ properties = anObject properties]
		ifFalse: [^ properties = anObject]
]

{ #category : #'as yet unclassified' }
JsonObject >> associationsDo: aBlock [
	^ properties associationsDo: aBlock
]

{ #category : #'as yet unclassified' }
JsonObject >> at: key [
	^ self at: key ifAbsent: [self error: 'key not found']

]

{ #category : #'as yet unclassified' }
JsonObject >> at: key ifAbsent: aBlock [
	^ (properties detect: [:ea | ea key = key] ifNone: [^ aBlock value]) value
]

{ #category : #'as yet unclassified' }
JsonObject >> at: key put: value [
	properties associationsDo: [:a | a key = key ifTrue: [a value: value. ^ value]].
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
			aStream nextPut: $:.
			ea value jsonWriteOn: aStream]
		separatedBy: [aStream nextPut: $,].
	aStream nextPut: $}.
]

{ #category : #'as yet unclassified' }
JsonObject >> properties [
	^ properties
]
