ContentPack
-----------------

A utility for Cuis and Squeak Smalltalk to move resources into and out of the image file as source code.

This is a rewrite of a version of the class ContentPack which is in Cuis Smalltalk (https://github.com/jvuletich/Cuis) done by Casey Ransberger.

It allows to move graphical resources (Bitmaps stored externally as PNG and JPG files) as code into and out of Cuis and Squeak images.

The bitmaps may be stored as code thus with a single file many resources may be installed.

--Hannes Hirzel, February 2012


### Usage note

- Add-Ons-ContentPack-Core.pck.st is the base code for Cuis in Cuis *.pck.st format
- Add-Ons-ContentPack-Core.hjh.3.mcz is the same code ready to be filed into Cuis or Squeak
- Add-Ons-ContentPack-Examples-hjh.1.mcz is a subclass of ContentPack2. The file loads in Cuis and Squeak. Loading needs time. Then see class side.



### The comment of class ContentPack


#### General aim

In the words of Juan Vuletich

http://www.jvuletich.org/pipermail/cuis_jvuletich.org/2012-May/000025.html

The idea is to let collaborators of art resources (graphics and sound designers) use whatever tool they prefer. For them, the resources are PNG or WAV. But we need to get them in source code, to load them as updates. ContentPack takes those external files and turns them into code (that creates live instances). Then the change set is included in the update stream. As we have the live objects, a later updates removes all that code. And we are done. Later, if we want to do another run of edition with external tools, ContentPack lets us export the resources as files, so our artist updates them. Then the process is repeated.

The following is copied from the release notes of Cuis 3.3:

ContentPack - A clean solution for a problem Squeak had for over a decade! (by Casey Ransberger)

- Manages internal/external resources
- Allows import / export to enable use of use existing artifacts and external tools
- Does not depend on external files for image update
- Updates done with code (enabling change sets of Monticello packages)
- Avoids cruft accumulation, code for resources is removed after update

All these properties are important, and ContentPack solves the issue really well.



#### This implementation

ContentPack is  a specialized dictionary to hold content as instances of Form and ColorForm and later other resources. The content is organized as a dictionary of dictionaries.


ContentPack includes utility methods to convert its content into methodscontaining the data. 
Thus with a fileOut content may be transferred to another Smalltalk image.

An individual resource like a ColorForm is converted to a method. 

A mapping (#classFileExtensionMapping) serves to define which file types are included.
Currently the mapping for recreating the objects is hard coded into the storing and retrieving methods.

A test class to test ContentPack2 is provided.


#### Requirements

 
No requirements in Cuis; in Squeak a compatibility package _CuisCompatibilityForSqueak_
is needed.

See class side 'creation' protocol how to construct instance.

There is as well another package 'Add-Ons-ContentPack-Examples' which demonstrates how this class is used.

	
The content is expected to be in a subdirectory 'Content/myPack'.
See protocol 'configuration' on the class side.


#### Useful expression

        ContentPack2 new removeStorageMethods

to remove the content which is stored in methods.

     		
#### Limitations

Only Forms and ColorForms are managed. Loading larger instances of forms may take a long time (10 minutes and more). 
The bitmaps are not stored in compressed format. However on the other side the content may be made available in source code form.


#### Further work

Instead of storing all the content in the class as integer values of the *.BMP equivalent store it in compressed form (i.e. in PNG or JPG format).

See 

        Form fromBinaryStream: aBinaryStream

The binary stream may be created in memory from a stored ByteArray.

Add StrikeFont and Midi files file as supported file type



####  Acknowledgment

This code is a a major rewrite of the class ContentPack contained in  [1]  done by Casey Ramsberger.


#### Reference

[1] Source: https://github.com/jvuletich/Cuis