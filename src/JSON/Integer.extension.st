Extension { #name : #Integer }

{ #category : #'*JSON-writing' }
Integer >> jsonWriteOn: aWriteStream [
	
	aWriteStream nextPutAll: (self printStringBase: 10)
]
