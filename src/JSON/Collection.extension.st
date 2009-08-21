Extension { #name : #Collection }

{ #category : #'*json' }
Collection >> jsonWriteOn: aStream [
	| needComma |
	needComma := false.
	aStream nextPut: $[.
	self do: [:v |
		needComma
			ifTrue: [ aStream nextPut: $, ]
			ifFalse: [ needComma := true ].
		v jsonWriteOn: aStream.
	].
	aStream nextPut: $].
]
