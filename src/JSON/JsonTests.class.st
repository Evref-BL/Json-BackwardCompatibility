"
I provide a number of test cases for class Json.
"
Class {
	#name : #JsonTests,
	#superclass : #TestCase,
	#category : 'JSON'
}

{ #category : #'as yet unclassified' }
JsonTests >> json: aString equals: aValue [
	self assert: (Json readFrom: aString readStream) = aValue.
]

{ #category : #'as yet unclassified' }
JsonTests >> testArray [
	self json: '[]' equals: #().
	self json: '[[]]' equals: #(#()).
	self json: '[[], []]' equals: #(#() #()).
	self json: '["hi", "there"]' equals: #('hi' 'there').
	self json: '[["a", "b", null]]' equals: #(('a' 'b' nil)).
]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomFalse [
	self json: 'false' equals: false.
	self json: '  false' equals: false.
	self json: 'false  ' equals: false.
	self json: '  false  ' equals: false.

]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomNull [
	self json: 'null' equals: nil.
	self json: '  null' equals: nil.
	self json: 'null  ' equals: nil.
	self json: '  null  ' equals: nil.

]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomNumber [
	self json: '1' equals: 1.
	self json: '0123' equals: 123.
	self json: '1.23e2' equals: 123.
	self json: '-1' equals: -1.
	self json: '-0' equals: 0.
	self json: '[-1.2]' equals: #(-1.2).
]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomString [
	self json: '"hi"' equals: 'hi'.
	self json: '"\""' equals: '"'.
	self json: '"\\"' equals: '\'.
	self json: '""' equals: ''.
]

{ #category : #'as yet unclassified' }
JsonTests >> testAtomTrue [
	self json: 'true' equals: true.
	self json: '  true' equals: true.
	self json: 'true  ' equals: true.
	self json: '  true  ' equals: true.

]

{ #category : #'as yet unclassified' }
JsonTests >> testDictionary [
	self json: '{}' equals: (Dictionary new).
	self json: '{"a": "a"}' equals: (Dictionary new at: 'a' put: 'a'; yourself).
	self json: '{"a": [[]]}' equals: (Dictionary new at: 'a' put: #(#()); yourself).
	self json: '{"a":"b", "b":"a"}' equals: ({'a'->'b'. 'b'->'a'} as: Dictionary).
]
