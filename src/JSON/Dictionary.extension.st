Extension { #name : #Dictionary }

{ #category : #'*JSON-writing' }
Dictionary >> jsonWriteOn: aStream [
	| needComma |
	needComma _ false.
	aStream nextPut: ${.
	self keysAndValuesDo: [:k :v |
		needComma
			ifTrue: [ aStream nextPutAll: ', ' ]
			ifFalse: [ needComma _ true ].
		k asString jsonWriteOn: aStream.
		aStream nextPutAll: ': '.
		v jsonWriteOn: aStream.
	].
	aStream nextPut: $}.
]
