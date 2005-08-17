"
This class reads and writes JSON format data - strings, numbers, boolean, nil, arrays and dictionaries. See http://www.crockford.com/JSON/index.html.
"
Class {
	#name : #Json,
	#superclass : #Object,
	#instVars : [
		'stream'
	],
	#classVars : [
		'CharacterEscapeMap'
	],
	#category : 'JSON'
}

{ #category : #'as yet unclassified' }
Json class >> escapeForCharacter: c [
	^ CharacterEscapeMap at: c ifAbsent: [nil]
]

{ #category : #'as yet unclassified' }
Json class >> initialize [
	"Json initialize."
	CharacterEscapeMap := Dictionary newFrom: {
		$" -> $".
		$\ -> $\.
		Character backspace -> $b.
		Character lf -> $n.
		Character newPage -> $f.
		Character cr -> $r.
		Character tab -> $t.
	}.
]

{ #category : #'as yet unclassified' }
Json class >> numbersMayContain: aChar [
	^ aChar isDigit or: [#($- $+ $. $e $E) includes: aChar]
]

{ #category : #'as yet unclassified' }
Json class >> readFrom: aStream [
	^ self new stream: aStream; readAny.
]

{ #category : #'as yet unclassified' }
Json class >> render: anObject [
	| s |
	s := WriteStream on: String new.
	anObject jsonWriteOn: s.
	^ s contents.
]

{ #category : #private }
Json >> consume: aString returning: anObject [
	aString do: [:c | self next == c ifFalse: [JsonSyntaxError signal: 'Expected ''', aString, ''''] ].
	^ anObject
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

	stream _ anObject
]
