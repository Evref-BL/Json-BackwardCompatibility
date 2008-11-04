"
This class reads and writes JSON format data - strings, numbers, boolean, nil, arrays and dictionaries. See http://www.crockford.com/JSON/index.html. It has been extended with syntax for invoking a prearranged list of constructors on read objects.
"
Class {
	#name : #Json,
	#superclass : #Object,
	#instVars : [
		'stream',
		'ctorMap'
	],
	#classInstVars : [
		'escapeArray'
	],
	#category : #JSON
}

{ #category : #'as yet unclassified' }
Json class >> escapeForCharacter: c [
	
	| index |
	(index := c asciiValue + 1) <= escapeArray size
		ifTrue: [ ^escapeArray at: index ].
	^nil
]

{ #category : #'as yet unclassified' }
Json class >> initialize [
	"Json initialize."
	
	escapeArray := Array new: 128.
	(0 to: 31), #(127) do: [ :each |
		escapeArray at: each + 1 put: '\u', (each printStringHex padded: #left to: 4 with: $0) ].
	{
		$" -> '\"'.
		$\ -> '\\'.
		Character backspace -> '\b'.
		Character lf -> '\n'.
		Character newPage -> '\f'.
		Character cr -> '\r'.
		Character tab -> '\t'.
	} do: [ :each |
		escapeArray at: each key asciiValue + 1 put: each value ].

]

{ #category : #'as yet unclassified' }
Json class >> mimeType [
	^ 'application/x-json'
]

{ #category : #'as yet unclassified' }
Json class >> newWithConstructors: aCollection [
	| m |
	m _ Dictionary new.
	aCollection do: [:each |
		(each isKindOf: Association)
			ifTrue: [m add: each]
			ifFalse: [m at: each name asString put: each]].
	^ self new ctorMap: m; yourself.
]

{ #category : #'as yet unclassified' }
Json class >> numbersMayContain: aChar [
	^ aChar isDigit or: [#($- $+ $. $e $E) includes: aChar]
]

{ #category : #'as yet unclassified' }
Json class >> readFrom: aStream [
	^ self new readFrom: aStream.
]

{ #category : #'as yet unclassified' }
Json class >> render: anObject [
	| s |
	s := WriteStream on: String new.
	anObject jsonWriteOn: s.
	^ s contents.
]

{ #category : #'as yet unclassified' }
Json class >> render: anObject withConstructor: aConstructorName on: aStream [
	aStream nextPutAll: '@', aConstructorName.
	anObject jsonWriteOn: aStream.

]

{ #category : #'as yet unclassified' }
Json class >> renderInstanceVariables: aCollection of: anObject on: aStream [
	| map |
	map _ Dictionary new.
	aCollection do: [:ivarName | map at: ivarName put: (anObject instVarNamed: ivarName)].
	self render: map withConstructor: anObject class name asString on: aStream
]

{ #category : #private }
Json >> consume: aString returning: anObject [
	aString do: [:c | self next == c ifFalse: [JsonSyntaxError signal: 'Expected ''', aString, ''''] ].
	^ anObject
]

{ #category : #accessing }
Json >> ctorMap [
	^ ctorMap
]

{ #category : #accessing }
Json >> ctorMap: m [
	ctorMap _ m
]

{ #category : #private }
Json >> interpretStringEscape [
	| c |
	c := self next.
	c == $b ifTrue: [^ Character backspace].
	c == $n ifTrue: [^ Character lf].
	c == $f ifTrue: [^ Character newPage].
	c == $r ifTrue: [^ Character cr].
	c == $t ifTrue: [^ Character tab].
	c == $u ifTrue: [^ self unescapeUnicode].
	^ c.
]

{ #category : #private }
Json >> next [
	^ self stream next
]

{ #category : #private }
Json >> peek [
	^ self stream peek
]

{ #category : #parsing }
Json >> readAny [
	"This is the main entry point for the JSON parser. See also readFrom: on the class side."
	| c |
	self skipWhitespace.
	c := self peek asLowercase.
	c == ${ ifTrue: [self next. ^ self readDictionary].
	c == $[ ifTrue: [self next. ^ self readArray].
	c == $" ifTrue: [self next. ^ self readString].
	c == $t ifTrue: [^ self consume: 'true' returning: true].
	c == $f ifTrue: [^ self consume: 'false' returning: false].
	c == $n ifTrue: [^ self consume: 'null' returning: nil].
	c == $@ ifTrue: [self next. ^ self readConstructor].
	(Json numbersMayContain: c) ifTrue: [^ self readNumber].
	JsonSyntaxError signal: 'Unknown Json input'
]

{ #category : #private }
Json >> readArray [
	| a needComma |
	a := OrderedCollection new.
	needComma _ false.
	[
		self skipWhitespace.
		self peek == $] ifTrue: [self next. ^ a asArray].
		needComma
			ifTrue: [self peek == $, ifFalse: [JsonSyntaxError signal: 'Missing comma'].
					self next.]
			ifFalse: [needComma _ true]. 
		a add: self readAny.
	] repeat.

]

{ #category : #private }
Json >> readConstructor [
	| s c v ctor |
	s := WriteStream on: ''.
	[
		c := self peek.
		c ifNil: [JsonSyntaxError signal: 'Premature EOF reading constructor name'].
		((c == $.) or: [c isLetter])
			ifTrue: [s nextPut: c. self next]
			ifFalse: [
				v := self readAny.
				s := s contents.
				ctor _ ctorMap ifNotNil: [ctor _ ctorMap at: s ifAbsent: [nil]].
				ctor ifNil: [JsonSyntaxError signal: 'Unknown ctor ', s].
				^ ctor constructFromJson: v]
	] repeat.

]

{ #category : #private }
Json >> readDictionary [
	| m k v needComma |
	m := Dictionary new.
	needComma _ false.
	[
		self skipWhitespace.
		self peek == $} ifTrue: [self next. ^ m].
		needComma
			ifTrue: [self peek == $, ifFalse: [JsonSyntaxError signal: 'Missing comma'].
					self next. self skipWhitespace]
			ifFalse: [needComma _ true.].
		self next == $" ifFalse: [JsonSyntaxError signal: 'Key in dictionary must be string'].
		k := self readString.
		self skipWhitespace.
		self peek == $: ifFalse: [JsonSyntaxError signal: 'Missing colon'].
		self next.
		v := self readAny.
		m at: k put: v.
	] repeat.

]

{ #category : #parsing }
Json >> readFrom: aStream [
	self stream: aStream.
	^ self readAny
]

{ #category : #private }
Json >> readNumber [
	| acc c |
	acc := WriteStream on: ''.
	[
		c := self peek.
		(c isNil not and: [Json numbersMayContain: c]) ifFalse: [
			[^ acc contents asNumber] on: Error do: [JsonSyntaxError signal: 'Invalid number']].
		acc nextPut: c.
		self next.
	] repeat.
]

{ #category : #private }
Json >> readString [
	| s c |
	s := WriteStream on: ''.
	[
		c := self next.
		c == $\
			ifTrue: [s nextPut: self interpretStringEscape.]
			ifFalse: [c == $" ifTrue: [^ s contents.].
					s nextPut: c]
	] repeat.
]

{ #category : #private }
Json >> skipComment [
	self peek == $/ ifTrue: [
		self next.
		self peek == $/
			ifTrue: [self skipToEndOfLine]
			ifFalse: [self peek == $*
						ifTrue: [self next. self skipCommentBody]
						ifFalse: [JsonSyntaxError signal: 'Invalid comment syntax']]]

]

{ #category : #private }
Json >> skipCommentBody [
	[
		[self next == $*] whileFalse.
		self peek == $/
	] whileFalse.
	self next. "skip that last slash"
	self skipWhitespace.
]

{ #category : #private }
Json >> skipToEndOfLine [
	[self peek == Character cr or: [self peek == Character lf]] whileFalse: [self next].
	self skipWhitespace
]

{ #category : #private }
Json >> skipWhitespace [
	[self peek isSeparator] whileTrue: [self next].
	self skipComment.
]

{ #category : #accessing }
Json >> stream [
	"Answer the value of stream"

	^ stream
]

{ #category : #accessing }
Json >> stream: anObject [
	"Set the value of stream"

	stream := anObject.
	(stream respondsTo: #reset) ifTrue: [
		stream reset.
	].

]

{ #category : #private }
Json >> unescapeUnicode [
	|string|
	string := (String with: self next with: self next with: self next with: self next) asUppercase.
	^ Unicode value: (Number readFrom: '16r', string)
]
