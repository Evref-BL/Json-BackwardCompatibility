Extension { #name : #Number }

{ #category : #'*JSON-writing' }
Number >> jsonWriteOn: aWriteStream [ 
	aWriteStream nextPutAll: self asString.
]
