Class {
	#name : 'BaselineOfJSON',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfJSON',
	#package : 'BaselineOfJSON'
}

{ #category : 'baselines' }
BaselineOfJSON >> baseline: spec [

	<baseline>
	spec for: #common do: [ spec package: 'JSON' ]
]
