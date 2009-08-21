Extension { #name : #String }

{ #category : #'*JSON-writing' }
String >> jsonWriteOn: aStream [

	| replacement |
	aStream nextPut: $".
	self do: [ :ch |
		(replacement := Json escapeForCharacter: ch)
			ifNil: [ aStream nextPut: ch ]
			ifNotNil: [ aStream nextPutAll: replacement ] ].
	aStream nextPut: $".

]
