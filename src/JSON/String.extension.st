Extension { #name : #String }

{ #category : #'*JSON-writing' }
String >> jsonWriteOn: aStream [
	| replacement |
	aStream nextPut: $".
	self do: [:ch |
		replacement _ Json escapeForCharacter: ch.
		replacement
			ifNil: [ aStream nextPut: ch ]
			ifNotNil: [ aStream nextPut: $\; nextPut: replacement ].
	].
	aStream nextPut: $".

]
