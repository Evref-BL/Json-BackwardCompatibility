Class {
	#name : #ConfigurationOfJSON,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfJSON
}

{ #category : #'development support' }
ConfigurationOfJSON class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfJSON class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #catalog }
ConfigurationOfJSON class >> catalogChangeLog [

^ '
- 2013-08-30 Version 1: moved to SmalltalkHub and first configuration.

[ [ [ 
	(ConfigurationOfJSON project version: ''1.0'') load
] ] ]


'
]

{ #category : #catalog }
ConfigurationOfJSON class >> catalogDescription [
	^ 'JSON is an implementation of the JSON syntax. This package was the first implemented. Now NeoJSON proposes another approach covered by tests. JSON was originally hosted on http://www.squeaksource.com/JSON. If you want to maintain this package just ask in the Pharo mailing-list.'
]

{ #category : #catalog }
ConfigurationOfJSON class >> catalogKeywords [
	^ #(JSON object-format text web)
]

{ #category : #private }
ConfigurationOfJSON class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfJSON class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfJSON class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #catalog }
ConfigurationOfJSON class >> keyClassesAndExample [

^ '
- ==Json== reads and write JSON objects.

- ==JsonObject== represents JSON objects. 
'
]

{ #category : #loading }
ConfigurationOfJSON class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfJSON class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfJSON class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #accessing }
ConfigurationOfJSON class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfJSON class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfJSON >> baseline10: spec [
	<version: '1.0-baseline'>
	spec
		for: #common
		do: [ 
			spec repository: 'http://smalltalkhub.com/mc/PharoExtras/JSON/main'.
			spec blessing: #baseline.
			spec package: 'JSON'.
			spec group: 'default' with: #('JSON') ].
	spec for: #gemstone do: [ spec repository: 'http://www.smalltalkhub.com/mc/pdebruic/JSONg/main' ]
]

{ #category : #'symbolic versions' }
ConfigurationOfJSON >> development: spec [
	<symbolicVersion: #'development'>
	
	spec for: #common version: '1.1'
]

{ #category : #accessing }
ConfigurationOfJSON >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self.
		project := constructor project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #'symbolic versions' }
ConfigurationOfJSON >> stable: spec [
	<symbolicVersion: #'stable'>
	
	spec for: #common version: '1.1'
]

{ #category : #versions }
ConfigurationOfJSON >> version10: spec [
	<version: '1.0' imports: #('1.0-baseline')>
	spec
		for: #common
		do: [ 
			spec blessing: #development.
			spec description: 'life is easier with metacello'.
			spec author: 'PaulDeBruicker'.
			spec timestamp: '9/7/2013 12:45' ].
	spec for: #squeakCommon do: [ spec package: 'JSON' with: 'JSON-ul.35' ].
	spec for: #gemstone do: [ spec package: 'JSON' with: 'JSON-PaulDeBruicker.40' ]
]

{ #category : #versions }
ConfigurationOfJSON >> version11: spec [
	<version: '1.1' imports: #('1.0-baseline')>
	spec
		for: #common
		do: [ 
			spec blessing: #release.
			spec author: 'TommasoDalSasso' ].
	spec for: #squeakCommon do: [ spec package: 'JSON' with: 'JSON-PaulDeBruicker.39' ].
	spec for: #gemstone do: [ spec package: 'JSON' with: 'JSON-PaulDeBruicker.40' ]
]
