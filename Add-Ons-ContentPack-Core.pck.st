'From Cuis 4.1 of 12 December 2012 [latest update: #1583] on 2 February 2013 at 3:18:42 pm'!
'Description '!
!classDefinition: #ContentPack2 category: #'Add-Ons-ContentPack-Core'!
Dictionary subclass: #ContentPack2
	instanceVariableNames: 'name'
	classVariableNames: 'ObjIndex'
	poolDictionaries: ''
	category: 'Add-Ons-ContentPack-Core'!
!classDefinition: 'ContentPack2 class' category: #'Add-Ons-ContentPack-Core'!
ContentPack2 class
	instanceVariableNames: ''!

!classDefinition: #ContentPack2Test category: #'Add-Ons-ContentPack-Core'!
TestCase subclass: #ContentPack2Test
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Add-Ons-ContentPack-Core'!
!classDefinition: 'ContentPack2Test class' category: #'Add-Ons-ContentPack-Core'!
ContentPack2Test class
	instanceVariableNames: ''!


!ContentPack2 commentStamp: 'hjh 2/2/2013 12:36' prior: 0!
General aim:http://www.jvuletich.org/pipermail/cuis_jvuletich.org/2012-May/000025.htmlThe idea is to let collaborators of art resources (graphics and sound designers) use whatever tool they prefer. For them, the resources are PNG or WAV. But we need to get them in source code, to load them as updates. ContentPack takes those external files and turns them into code (that creates live instances). Then the change set is included in the update stream. As we have the live objects, a later updates removes all that code. And we are done. Later, if we want to do another run of edition with external tools, ContentPack lets us export the resources as files, so our artist updates them. Then the process is repeated.The following is copied from the release notes of Cuis 3.3:ContentPack - A clean solution for a problem Squeak had for over a decade!! (by Casey Ransberger)    - Manages internal/external resources    - Allows import / export to enable use of use existing stuff and external tools    - Does not depend on external files for image update    - Updates done with code (enabling change sets of Monticello packages)    - Avoids cruft accumulation, code for resources is removed after updateAll these properties are important, and ContentPack solves the issue really well.This implementation in particular-------------------------------------------------I am a special dictionary to hold content as instances of Form, ColorForm, sounds or other instances of me. So the content is organized as dictionaries of dictionaries.I include utility methods to convert my content into methods of me containing the data. Thus with a fileOut of me content my be transferred to another Smalltalk image.An individual resource like a ColorForm is converted to a method. A mapping (#classFileExtensionMapping) serves to define which file types are included.Currently the mapping for recreating the objects is hard coded into the storing and retrieving methods.A test class to test ContentPackV2 has been added.Requirements---------------------No requirements in CuisIn Squeak a compatibility package   CuisCompatibilityForSqueakis needed.See class side 'creation' protocol how to construct instance.There is as well another package 'Add-Ons-ContentPack-Examples' which demonstrates how this class is used.	The content is expected to be in a subdirectory 'Content/myPack'.See protocol 'configuration' on the class side.Useful expression---------------------------    ContentPack2 new removeStorageMethodsto remove the content which is stored in methods.     		Limitations-------------Only Forms and ColorForms are managed.Loading larger instances of forms may take a long time (10 minutes and more). Further work-------------------------------Add StrikeFont and Midi files file as supported file typeInstead of storing all the content in the class as integer values of the *.BMP equivalent store it in compressed form (i.e. in PNG or JPG format).See     Form fromBinaryStream: aBinaryStreamThe binary stream may be created in memory from a stored ByteArray.Ackknowledgment------------------------------This code is a a major rewrite of the class ContentPack contained in  [1] done by Casey Ramsberger.Reference------------------------------[1] Source: https://github.com/jvuletich/Cuis!

!ContentPack2Test commentStamp: 'hjh 2/2/2013 14:15' prior: 0!
A ContentPack2Test is a collection of tests for the class ContentPackUse the TestRunner to execute them or execute the tests individually.    	testExportToDisk1      testExportToDisk2          needs some attention, it only runs the first time; the next time the directories 'test1' and 'test2' (subdirectories of 'Content' still exist.       If you delete them manually the tests will run fine again.!

!ContentPack2 methodsFor: 'recreate from code - private' stamp: 'hjh 2/2/2013 11:04'!
addContentFromMappingDictionary: aDictOfSelectorMappings"aDictOfSelectorMappings contains labels and selectors of methods which recreate objects."		aDictOfSelectorMappings keys do: [ :key | | obj aSelector | 									"reconstruct the object from the storage method"							aSelector := aDictOfSelectorMappings at: key.									obj := self perform: aSelector.									(obj class = Dictionary)								ifTrue: [ | newPack | 										newPack := ContentPack2 new addContentFromMappingDictionary: obj.										self at: key put: newPack									     ]								ifFalse:										[self at: key put: obj]					].					! !

!ContentPack2 methodsFor: 'recreate from code' stamp: 'hjh 2/2/2013 15:14'!
addContentFromStorageMethods	"self class firstStorageSelector		gives the initial storage selector where the dictionary with the mapping of labels to storage method selectors may be restored. 		for each key in that dictionary the value (= a storage selector) is sent to me thus recreating the original object"			"self removeAll."   "does not work in Cuis"		self addContentFromMappingDictionary: (self perform: self class firstStorageSelector).			^self! !

!ContentPack2 methodsFor: 'initialization' stamp: 'hjh 2/2/2013 11:04'!
asContentPack: aDictionary	"Convert aDictionary into a ContentPack. The parameter aDictionary contains values which are resources (Form, ColorForm instances) or other dictionaries of resources. So this instance of ContentPack might include other instances of ContentPack. To do so  the conversion is done recursively.	"     aDictionary keys do:  [ :key | 				((aDictionary at: key) class includesBehavior: Dictionary)					ifTrue: [ self at: key put: (ContentPack2 fromDictionary: (aDictionary at: key)) ]					ifFalse: [ self at: key put: (aDictionary at: key) ]		].	^ self ! !

!ContentPack2 methodsFor: 'converting' stamp: 'hjh 1/19/2013 23:33'!
asDictionary	"Convert this instance of ContentPack to an instance of Dictionary. This instance of ContentPack might include other instances of ContentPack. So the conversion is done recursively. The result is a dictionary of dictionaries"	| associations |	associations _ self keys collect: [ :key | 		((self at: key) class includesBehavior: self class "ContentPack")			ifTrue: [ key -> (self at: key) asDictionary ]			ifFalse: [ key -> (self at: key) ]		].	^ associations as: Dictionary! !

!ContentPack2 methodsFor: 'storing-meth-forms-private' stamp: 'hjh 2/1/2013 20:40'!
calculateWidthForLeftPart: aForm.	"calculate width for left part of aForm depending on the size of the form and the default size which can be managed"	    ^self class sizeLimit // aForm height! !

!ContentPack2 methodsFor: 'storing-methods-private' stamp: 'hjh 2/1/2013 17:47'!
compileContentToStorageMethod: aStorageSelector  |  obj labelsToSelectorMapping storageSelector |  "initialize a dictionary of label to storageSelector mappings to replace the contentPack instance."  labelsToSelectorMapping := Dictionary new.  "for all keys of this ContentPackV2 instance do"  self keys do: [:key |				 obj := self at: key.								storageSelector := self class nextStorageSelector.  "#objectN"						(obj class = self class) "is it a Dictionary or subclass, i.e. ContentPack" 							ifTrue: ["dictionary"						       obj compileContentToStorageMethod: storageSelector						      "recursion on this method: convert a subdictionary".												     "collect data for the mapping dictionary"					             labelsToSelectorMapping at: key put: storageSelector.						]							ifFalse: [ "compile a single resource, e.g. obj is a picture"							"do not create storage methods for sound as they are too large"							(obj class = SampledSound ) ifFalse: [											      		self compileResourceToMethod: obj						       label: key							 selector: storageSelector.						      "collect data for the mapping dictionary"					             labelsToSelectorMapping at: key put: storageSelector.								].							].														].  "create a helper method for the mappings, i.e. the labels and the corresponding selector which recreates the object when executed."		 self compileLabelToSelectorMapping: aStorageSelector 		for: labelsToSelectorMapping.! !

!ContentPack2 methodsFor: 'storing-methods' stamp: 'hjh 1/31/2013 22:01'!
compileContentToStorageMethods	| storageSelector |			self  class resetStorageSelectorCounter.	storageSelector := self class nextStorageSelector. "#object1"		self  compileContentToStorageMethod: storageSelector.	! !

!ContentPack2 methodsFor: 'storing-meth-forms-private' stamp: 'hjh 2/1/2013 20:31'!
compileForm: aForm label: aLabel selector: aSelector	"the label is only needed to put into the comment, it is saved at another place in the mapping dictionary."		| aStoreString methodSource |	aForm bits size > self class sizeLimit		ifTrue: [self compileLargeForm: aForm label: aLabel selector: aSelector]		ifFalse: [ "compose method source for aForm and compile it" 						aStoreString := aForm storeString.			methodSource :=		 	aSelector asString						, String newLineString 						, 34 asCharacter asString, aLabel			, '    ', aForm class className			, 34 asCharacter asString			, String newLineString					,'	^ ' ,				aStoreString.   						self class compile: methodSource.	]! !

!ContentPack2 methodsFor: 'storing-methods-private' stamp: 'hjh 2/1/2013 17:36'!
compileLabelToSelectorMapping: aSelector for: labelsToStorageSelectorDictionary"create a storage method  for the dictionary which maps then dictionary keys to the corresponding storage method.This can then be used to recreate the hierarchyi.e.    icon1label   -> #object1    icon2label   -> #object2    numbers   -> #object3   (a storage method which recreates a ContentPack)"	| methodSource |	self flag: #hjh.			  methodSource :=		 	aSelector asString						, String newLineString 						", 34 asCharacter asString, aLabel						, '    ', anObject class className						, 34 asCharacter asString						, String newLineString"						,'	^ ' ,						labelsToStorageSelectorDictionary storeString.   self class compile: methodSource.! !

!ContentPack2 methodsFor: 'storing-meth-forms-private' stamp: 'hjh 2/2/2013 05:13'!
compileLargeForm: aForm label: aLabel selector: aSelector	| leftPart rightPart width leftFormSelector rightFormSelector |		width := self calculateWidthForLeftPart: aForm.	leftPart := self leftPartOf: aForm width: width.	rightPart := self rightPartOf: aForm width: width.	self compileForm: leftPart label: aLabel selector: (leftFormSelector := self class nextStorageSelector).	self compileForm: rightPart label: aLabel selector: (rightFormSelector := self class nextStorageSelector).		self writeOutCombinationMethod: aSelector for: leftFormSelector and: rightFormSelector.	! !

!ContentPack2 methodsFor: 'storing-methods-private' stamp: 'hjh 2/2/2013 05:08'!
compileResourceToMethod: anObject label: aLabel selector: aSelector   "anObject is an instance of Form, ColorForm, a sound or something else. Not a collection"   | methodSource  aStoreString |     "handle forms separately"     (anObject  isKindOf: Form) ifTrue: [ ^self compileForm: anObject label: aLabel selector: aSelector].     "other objects than forms"     aStoreString := anObject storeString.	(aStoreString size > 60000)		ifTrue: [aStoreString := ''' object too large'''].     methodSource :=		 	aSelector asString						, String newLineString 						, 34 asCharacter asString, aLabel						, '    ', anObject class className						, 34 asCharacter asString						, String newLineString						,'	^ ' ,						aStoreString.   self class compile: methodSource.			! !

!ContentPack2 methodsFor: 'exporting' stamp: 'hjh 2/2/2013 13:02'!
export      self flag: #hjh.  "rewrite"	"(self exportDirectory containingDirectory directoryExists: self exportDirectory localName)		ifTrue: [ Utilities inform: 			'Before you can export, you must move, rename or delete this directory: ' ,			self exportDirectory fullName.			^ false.		].	"	self exportIntoDirectory:  self exportDirectory.		^ true.		! !

!ContentPack2 methodsFor: 'accessing' stamp: 'hjh 1/21/2013 19:26'!
exportDirectory		^ (FileDirectory default directoryNamed: self class defaultContentDirectory)		directoryNamed: self name! !

!ContentPack2 methodsFor: 'exporting' stamp: 'hjh 2/2/2013 11:59'!
exportIntoDirectory: aDirectory		aDirectory assureExistence.	self associations do: [ :assoc |		| klass subDirectory fullPath | 			klass _ assoc value class.			subDirectory _ aDirectory directoryNamed: assoc key.			fullPath _  aDirectory fullName , 						  aDirectory pathNameDelimiter asString ,						  assoc key.		self flag: #note. "Add support for new file export type mappings here. --cbr"		klass = self class "ContentPack"			ifTrue: [ assoc value exportIntoDirectory: subDirectory ].				klass = ColorForm			ifTrue: [ assoc value writeBMPfileNamed: (fullPath, '.bmp') ].					klass = Form			ifTrue: [ assoc value writeBMPfileNamed: (fullPath, '.bmp') ]	]! !

!ContentPack2 methodsFor: 'importing-private' stamp: 'hjh 1/21/2013 23:04'!
importFile: anEntry 		|  |				self flag: #todo. "Hard coded if statement; should use the mapping on the class side"			(anEntry  extension asLowercase endsWith: 'png')		 ifTrue:  [self at: anEntry baseName put: (Form fromFileNamed: anEntry fullName)].					(anEntry  extension asLowercase endsWith: 'bmp')		 ifTrue:  [self at: anEntry baseName put: (ColorForm fromFileNamed: anEntry fullName)].		(anEntry  extension asLowercase endsWith: 'jpg')		 ifTrue:  [self at: anEntry baseName put: (ColorForm fromFileNamed: anEntry fullName)].				(anEntry  extension asLowercase endsWith: 'wav')		 ifTrue:  [self at: anEntry baseName put: (SampledSound fromWaveFileNamed: anEntry fullName)].		! !

!ContentPack2 methodsFor: 'importing' stamp: 'hjh 2/2/2013 11:05'!
importFromDirectory: aDirectoryPathString 		| aDirectory contentPacks |	self flag: #todo. "rework this method, more tests needed. 	"	aDirectory _ FileDirectory on: 					(FileDirectory default 						fullNameFor: aDirectoryPathString					).								(self supportedFilesInDirectory: aDirectory) do: [:entry | 		self importFile: entry].	contentPacks _ aDirectory directoryNames collect:		 [ :i | i ->  (self class new importFromDirectory:  (aDirectory fullNameFor: i))	].			^ self union: contentPacks		! !

!ContentPack2 methodsFor: 'private' stamp: 'hjh 1/19/2013 23:41'!
instantiateResourceFromMethod: anIndexNumber    | aSelector aCodeString |    aSelector :=  'object' , anIndexNumber asString asSymbol.    aCodeString := self perform: aSelector. ^ Compiler evaluate: aCodeString     "was earlier    	base64Decoded     "! !

!ContentPack2 methodsFor: 'recreate from code - private' stamp: 'hjh 2/2/2013 05:51'!
join: formleft with:  formright	"formleft and formright are joined together and the resulting form is returned"	| combined r |		combined := Form extent: (formleft width + formright width) @ formleft height depth: formleft depth.		r := Rectangle origin: 0@0 extent: formleft extent.	combined copy: r from: formleft to: 0@0 rule: Form over.                        "left"		r := Rectangle origin: 0@0 extent: formright extent.	combined copy: r from: formright to: formleft width@0 rule: Form over.   "right"		^combined! !

!ContentPack2 methodsFor: 'storing-meth-forms-private' stamp: 'hjh 2/1/2013 17:56'!
leftPartOf: aForm width: width.	^aForm copy: (Rectangle origin: 0@0 extent: width @ aForm height)! !

!ContentPack2 methodsFor: 'accessing' stamp: 'hjh 1/21/2013 09:08'!
name		name isNil ifTrue: [ name := 'default'].		^name! !

!ContentPack2 methodsFor: 'accessing' stamp: 'hjh 1/21/2013 09:07'!
name: aString	name := aString! !

!ContentPack2 methodsFor: 'storing-methods' stamp: 'hjh 1/19/2013 23:32'!
removeStorageMethods	" remove all old storage methods and storage subclasses          later use:                  Smalltalk removeFromSystem: aSubclass"| selColl |selColl := self class selectors select: [ :sel | (sel asString beginsWith: 'object') ].selColl do: [ :sel | self class removeSelector: sel].! !

!ContentPack2 methodsFor: 'storing-meth-forms-private' stamp: 'hjh 2/2/2013 07:11'!
rightPartOf: aForm width: anInteger	^aForm contentsOfArea: (Rectangle origin: anInteger @0 corner: aForm width  @ aForm height).	! !

!ContentPack2 methodsFor: 'storing-methods' stamp: 'hjh 1/19/2013 23:39'!
storageSelectors  ^self class selectors select: [ :sel | (sel asString beginsWith: 'object') ].! !

!ContentPack2 methodsFor: 'importing-private' stamp: 'hjh 1/22/2013 09:59'!
supportedFilesInDirectory: aDirectory     "gives back the list of file names which have import methods in ContentPack"			^aDirectory entries select: 				[ :entry | entry extension asLowercase endsWithAnyOf: self class supportedFileTypes].! !

!ContentPack2 methodsFor: 'storing-meth-forms-private' stamp: 'hjh 2/1/2013 20:36'!
writeOutCombinationMethod: aSelector for: leftFormSelector and: rightFormSelector| methodSource |.	methodSource :=		aSelector asString  , String newLineString 						,'	^ self join: self ', leftFormSelector			              , ' with: self ',  rightFormSelector.					 					self class compile: methodSource.! !

!ContentPack2 class methodsFor: 'configuration' stamp: 'hjh 1/21/2013 23:06'!
classFileExtensionMapping	"gives back an instance of Array of mappings associations		ClassName -> file extension 		"		^ {		ColorForm -> #bmp .		ColorForm -> #jpg .		Form -> #png.		Form -> #gif.		"SampledSound -> #wav."      "deactivated because even very small sounds of 100ms cannot be compiled to a method"	}! !

!ContentPack2 class methodsFor: 'instance creation' stamp: 'hjh 2/2/2013 11:43'!
createFromDictionaryAndAddStorageMethods: aDictionary	 "this will create a ContentPack instance with both			the content stored as regular dictionary entries AND				the content stored in methods labeled		      #object1	    		#object1			...			#objectN				"		^(self new fromDictionary: aDictionary) compileContentToStorageMethods! !

!ContentPack2 class methodsFor: 'instance creation' stamp: 'hjh 2/2/2013 11:46'!
createFromDisk: aName	| pack slash |	slash := FileDirectory pathNameDelimiter asString.	pack := self named: aName.	^ pack importFromDirectory: (self defaultContentDirectory , slash, aName)! !

!ContentPack2 class methodsFor: 'configuration' stamp: 'hjh 1/19/2013 23:44'!
defaultContentDirectory	^ 'Content'! !

!ContentPack2 class methodsFor: 'configuration' stamp: 'hjh 1/19/2013 23:44'!
firstStorageSelector	^ #object1	! !

!ContentPack2 class methodsFor: 'instance creation' stamp: 'hjh 1/19/2013 23:43'!
fromDictionary: aDictionary"create a ContentPack from a dictionary of content (instances of Form, ColorForm)"^self new asContentPack: aDictionary! !

!ContentPack2 class methodsFor: 'instance creation' stamp: 'hjh 2/2/2013 11:44'!
named: aName	^self new name: aName.! !

!ContentPack2 class methodsFor: 'configuration' stamp: 'hjh 1/19/2013 23:44'!
nextStorageSelector	ObjIndex := ObjIndex + 1.	^('object' ,    ObjIndex asString) asSymbol      "the method selector"	! !

!ContentPack2 class methodsFor: 'configuration' stamp: 'hjh 1/19/2013 23:44'!
resetStorageSelectorCounter	ObjIndex := 0.	! !

!ContentPack2 class methodsFor: 'configuration' stamp: 'hjh 2/2/2013 05:33'!
sizeLimit	^25000! !

!ContentPack2 class methodsFor: 'accessing' stamp: 'hjh 1/19/2013 23:45'!
supportedFileTypes	" self supportedFileTypes"		^  self classFileExtensionMapping collect: [:assoc | assoc value]  	! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 2/2/2013 04:38'!
exampleDictWithOneLargeForm"self new exampleDictWithOneLargeForm"| dict |	dict := Dictionary new.	dict at: 'square' put: self makeLargeSquare.		^dict! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 1/19/2013 23:48'!
makeExampleDictionary"self new makeExampleDictionary"| dict |	dict := Dictionary new.	dict at: 'star' put: Form makeStar.	dict at: 'square' put: self makeSquare.		^dict! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 1/19/2013 23:48'!
makeExampleDictionaryWithOneEntry"self new makeExampleDictionary"| dict |	dict := Dictionary new.	dict at: 'square' put: self makeSquare.		^dict! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 1/19/2013 23:48'!
makeExampleDictionaryWithSubdictionary"self new makeExampleDictionaryWithSubdictionary"| dict dict2 |	dict := Dictionary new.	dict at: 'star' put: Form makeStar.	dict at: 'square' put: self makeSquare.		dict2 := Dictionary new.	dict2 at: 'hexagon' put: self makeHexagon.		dict at: 'moreShapes' put: dict2.		^dict! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 1/20/2013 00:29'!
makeHexagon| sampleForm pen |	sampleForm _ Form extent: 51@50.  "Make a form; extent is different from makeSquare"	pen _ Pen newOnForm: sampleForm.	pen place: 10@10; turn: 90.		"Draw a square  on it."	1 to: 6 do: [:i | pen go: 20; turn: 60].	^ sampleForm! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 2/2/2013 04:48'!
makeLargeSquare"(ImageMorph new image: self  new makeLargeSquare) openInWorld."| sampleForm pen |	sampleForm _ Form extent: 200@200 depth: 32.  "Make a form"	sampleForm fillWhite.	pen _ Pen newOnForm: sampleForm.	pen place: 10@10; turn: 90.		"Draw a square on it."	1 to: 4 do: [:i | pen go: 180; turn: 90].	^ sampleForm! !

!ContentPack2Test methodsFor: 'Accessing' stamp: 'hjh 1/20/2013 00:26'!
makeSquare| sampleForm pen |	sampleForm _ Form extent: 48@48.  "Make a form"	pen _ Pen newOnForm: sampleForm.	pen place: 10@10; turn: 90.		"Draw a square  on it."	1 to: 4 do: [:i | pen go: 30; turn: 90].	^ sampleForm! !

!ContentPack2Test methodsFor: 'private' stamp: 'hjh 2/2/2013 11:06'!
tearDown	ContentPack2 new removeStorageMethods .! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 11:06'!
testCompToStorageMethod1"	self new testCompToStorageMethod1	"		| pack |		pack := ContentPack2 fromDictionary: self makeExampleDictionaryWithOneEntry.		pack compileContentToStorageMethods.	"#object1 is the mapping dictionary, #object2 the only entry"		self assert: (pack perform: #object2)  extent = self makeSquare extent! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 11:06'!
testCompToStorageMethod2"	self new testCompToStorageMethod2	"		| pack mappingDict |		pack := ContentPack2 fromDictionary: self makeExampleDictionary.		pack compileContentToStorageMethods.			"check it the first storage method indeed is about a mapping dictionary 	    label ->  #objectN   (storage selector)	"	mappingDict := pack perform: #object1.		self assert: mappingDict class  = Dictionary.		self assert: mappingDict size  = 2.		self assert: (pack perform: (mappingDict at: 'square'))  extent = self makeSquare extent			! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 11:06'!
testCompToStorageMethod3"	self new testCompToStorageMethod3	"		| pack mappingDict aStorageSelector |		pack := ContentPack2 fromDictionary: self makeExampleDictionary.		pack compileContentToStorageMethods.			"check it the first storage method indeed is about a mapping dictionary 	    label ->  #objectN   (storage selector)	"	mappingDict := pack perform: #object1.		"The mapping dictionary contains a selector at: 'square' which recreates the original object there"		aStorageSelector := mappingDict at: 'square'.		self assert: (pack perform: aStorageSelector) extent = self makeSquare extent			! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 15:04'!
testCompToStorageMethod4"	self new testCompToStorageMethod4	"		| pack |		pack := ContentPack2 fromDictionary: self makeExampleDictionary.		pack compileContentToStorageMethods.	 "now we have in the pack in addition to the content (key/value) storage methods"		pack := ContentPack2 new.		pack addContentFromStorageMethods.	 "we have use the storage methods to add the content again"			 "we do some simple checks if we have got back the content."		self assert: pack size  = 2.		self assert: (pack  at: 'square') extent = self makeSquare extent	! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 11:06'!
testCompToStorageMethod5"	self new testCompToStorageMethod5	"		| pack |		pack := ContentPack2 new removeStorageMethods.		self assert: (pack storageSelectors) size = 0.			pack := ContentPack2 fromDictionary: self makeExampleDictionaryWithSubdictionary. 			pack compileContentToStorageMethods.		self assert: (pack storageSelectors) size = 5.			ContentPack2 new removeStorageMethods.	! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 15:05'!
testCompToStorageMethod6"	self new testCompToStorageMethod6	"		| pack |		pack := ContentPack2 new removeStorageMethods.	self assert: (pack storageSelectors) size = 0.		pack := ContentPack2 fromDictionary: self makeExampleDictionaryWithSubdictionary. 		pack compileContentToStorageMethods.	 "now we have storage methos in the pack in addition to the content (key/value)"	self assert: (pack storageSelectors) size = 5.		pack := ContentPack2 new.		self assert: pack size = 0.		pack addContentFromStorageMethods.	 "we have use the storage methods to add the content again"		self assert: pack size  = 3.  "three entries in the ContentPackV2 instance"	self assert: (pack  at: 'square') extent = self makeSquare extent.	self assert: ((pack  at: 'moreShapes') at: 'hexagon') extent = self makeHexagon extent	! !

!ContentPack2Test methodsFor: 'Tests-Storage-Methods' stamp: 'hjh 2/2/2013 11:07'!
testCompToStorageMethod7"	self new testCompToStorageMethod7	"		| pack |		pack := ContentPack2 fromDictionary: self exampleDictWithOneLargeForm. 		pack compileContentToStorageMethods.	 "now we have storage methos in the pack in addition to the content (key/value)"	self assert: (pack storageSelectors) size = 4.		self assert: (pack perform: #object3) width + 	(pack perform: #object4) width =                         self makeLargeSquare width.	"#object1 is the mapping dictionary, #object2 uses #object3 and #object4"		self assert: (pack perform: #object2)  extent = self makeLargeSquare extent! !

!ContentPack2Test methodsFor: 'Tests-Conversions' stamp: 'hjh 2/2/2013 11:07'!
testConversionContentPackToDictionary	"	self new testConversion	"		| pack |	pack := ContentPack2  new.		self assert: (pack asDictionary) class = Dictionary.			pack := ContentPack2 new.	pack at: 'star' put: Form makeStar.		self assert: (pack asDictionary) size = 1.			! !

!ContentPack2Test methodsFor: 'Tests-Creation' stamp: 'hjh 2/2/2013 11:07'!
testConversionDictionaryToContentPack	"	self new testConversion	"		| dict |	dict := Dictionary new.		self assert: (ContentPack2 fromDictionary: dict) class = ContentPack2.	self assert: (ContentPack2 fromDictionary: dict) size = 0.			dict := Dictionary new.	dict at: 'star' put: Form makeStar.		self assert: (ContentPack2 fromDictionary: dict) class = ContentPack2.	self assert: (ContentPack2 fromDictionary: dict) size = 1.	! !

!ContentPack2Test methodsFor: 'Tests-Creation' stamp: 'hjh 2/2/2013 11:07'!
testConversionDictionaryToContentPack2	"	self new testConversionDictionaryToContentPack2	"		| pack |	pack := ContentPack2 fromDictionary: self makeExampleDictionaryWithSubdictionary.		self assert: (pack at: 'moreShapes') size = 1.! !

!ContentPack2Test methodsFor: 'Tests-Creation' stamp: 'hjh 2/2/2013 15:06'!
testCreationFromStorageMethods	"	self new testCreationFromStorageMethods	"		| dict pack |	dict := Dictionary new.	dict at: 'star' put: Form makeStar.		pack := ContentPack2 fromDictionary: dict.	self assert: pack size = 1.	pack compileContentToStorageMethods .	self assert: pack size = 1.		self assert: pack storageSelectors size = 2.		pack := ContentPack2 new.		self assert: pack size = 0.			pack addContentFromStorageMethods.		self assert: pack size = 1.		! !

!ContentPack2Test methodsFor: 'Tests-Export' stamp: 'hjh 2/2/2013 11:07'!
testExportToDisk1"	self new testExportToDisk1	"		| pack name exportDir |		name := 'test1'.		exportDir := (FileDirectory default directoryNamed: self class defaultContentDirectory)		directoryNamed:  name.		exportDir exists ifTrue: [exportDir containingDirectory deleteDirectory: name].			pack := ContentPack2 fromDictionary: self makeExampleDictionaryWithOneEntry.		pack name: name.			pack export.		self assert: exportDir exists.	self assert: (exportDir fileExists: 'square.bmp').! !

!ContentPack2Test methodsFor: 'Tests-Export' stamp: 'hjh 2/2/2013 13:02'!
testExportToDisk2"	self new testExportToDisk2	"		| pack name exportDir |		name := 'test2'.		exportDir := (FileDirectory default directoryNamed: self class defaultContentDirectory)		directoryNamed:  name.		exportDir exists ifTrue: [exportDir containingDirectory deleteDirectory: name].			pack := ContentPack2 fromDictionary: self makeExampleDictionary.		pack name: name.			pack export.		self assert: exportDir exists.	self assert: (exportDir fileExists: 'square.bmp').	self assert: (exportDir fileExists: 'star.bmp').! !

!ContentPack2Test methodsFor: 'Tests-objectSelectors' stamp: 'hjh 2/2/2013 11:08'!
testStorageObjectSelector		ContentPack2 resetStorageSelectorCounter.		self assert: ContentPack2  nextStorageSelector = #object1.		self assert: ContentPack2  nextStorageSelector = #object2.		self assert: ContentPack2  nextStorageSelector = #object3! !

!ContentPack2Test methodsFor: 'Tests-Export' stamp: 'hjh 2/2/2013 11:08'!
zztestExportToDisk3"	self new testExportToDisk3	"		| pack name |		"assertion is made to fail on purpose, check the exported directory"	"check the exported directory, actually for all export tests"		pack := ContentPack2 fromDictionary: self makeExampleDictionaryWithSubdictionary.		name := 'test3-', (Date today asSeconds rem: 1000000) / 100  printString.		pack name: name.		pack export.		self assert: 1 = 0.   "check the exported directory, actually for all export tests"! !

!ContentPack2Test class methodsFor: 'as yet unclassified' stamp: 'hjh 2/2/2013 11:08'!
defaultContentDirectory	^ContentPack2 defaultContentDirectory! !
