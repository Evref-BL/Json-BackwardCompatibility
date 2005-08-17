Extension { #name : #String }

{ #category : #'*JSON-writing' }
String >> jsonWriteOn: aStream [
	aStream nextPut: $".
	self do: [:ch |
		(ch == $" or: [ch == $\])
			ifTrue: [ aStream nextPut: $\; nextPut: ch ]
			ifFalse: [
				aStream nextPut: ch.
				"TODO: escape special chars (lf, cr, tab etc) properly"
				#tonyg.
			]
	].
	aStream nextPut: $".

]
