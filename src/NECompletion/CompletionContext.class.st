"
I am a context class that hooks the new completion functionality into the system. To do that, i reimplement some of the methods but use most of the old ones from NECompletion package, such as the functionality to call the menu, etc.
"
Class {
	#name : #CompletionContext,
	#superclass : #Object,
	#instVars : [
		'source',
		'position',
		'completionToken',
		'model',
		'ast',
		'node',
		'isWorkspace',
		'class'
	],
	#category : #'NECompletion-New'
}

{ #category : #'instance creation' }
CompletionContext class >> controller: aNECController class: aClass source: aString position: anInteger [ 
	^ self new
		setController: aNECController
		class: aClass
		source: aString
		position: anInteger
]

{ #category : #accessing }
CompletionContext >> completionToken [

	"here we need to return the name of the var or selector"

	node ifNil: [ ^ '' ].
	^ completionToken ifNil: [ node completionToken ]
]

{ #category : #accessing }
CompletionContext >> createModel [
	self parseSource.
	node := ast nodeForOffset: position.
	^ CompletionModel new node: node
]

{ #category : #accessing }
CompletionContext >> model [
    ^model ifNil: [ model := self createModel ]
]

{ #category : #action }
CompletionContext >> narrowWith: aString [
	completionToken := aString.
	model := self createModel.
	model narrowWith: aString
]

{ #category : #parsing }
CompletionContext >> parseSource [

	ast := isWorkspace
		ifTrue: [RBParser parseFaultyExpression: source]
		ifFalse: [RBParser parseFaultyMethod: source].
	ast methodNode 
		compilationContext: 
			(Smalltalk compiler compilationContextClass new
             class: class;forSyntaxHighlighting: true).
		
	ast doSemanticAnalysisIn: class.
	TypingVisitor new visitNode: ast
]

{ #category : #'initialize-release' }
CompletionContext >> setController: aECController class: aClass source: aString position: anInteger [ 
	
	isWorkspace:= aECController 
		ifNotNil: [ aECController isScripting ]
		ifNil: [ false ].

	class := aClass. 
	source := aString.
	position := anInteger
]
