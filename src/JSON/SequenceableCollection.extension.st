Extension { #name : #SequenceableCollection }

{ #category : #'*JSON-writing' }
SequenceableCollection >> jsonWriteOn: aStream [
	| needComma |
	needComma := false.
	aStream nextPut: $[.
	self do: [:v |
		needComma
			ifTrue: [ aStream nextPutAll: ', ' ]
			ifFalse: [ needComma := true ].
		v jsonWriteOn: aStream.
	].
	aStream nextPut: $].
]
