Extension { #name : #ArrayedCollection }

{ #category : #'*JSON-writing' }
ArrayedCollection >> jsonWriteOn: aStream [

	aStream nextPut: $[.
	self size > 0 ifTrue: [
		(self at: 1) jsonWriteOn: aStream.
		2 to: self size do: [ :index |
			aStream nextPut: $,.
			(self at: index) jsonWriteOn: aStream ] ].
	aStream nextPut: $]
]
