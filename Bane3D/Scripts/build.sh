#!/bin/sh
#
# build.sh
#
# Created by Marco Köppel on 03.01.11.
# Modified by Andreas Hanft on 06.04.11, 23.02.13
# Copyright 2012 talantium.net. All rights reserved.
#

    # Define these to suit your nefarious purposes
    FRAMEWORK_NAME=${PROJECT_NAME}
    FRAMEWORK_VERSION=1.0
    FRAMEWORK_CURRENT_VERSION=0.1
    FRAMEWORK_COMPATIBILITY_VERSION=6.0
    BUILD_TYPE=${CONFIGURATION}


    # Build binaries for the two main architectures

    echo "Framework > Building native binary..."
    CRIT_ERRS=$(xcodebuild -configuration ${CONFIGURATION} -target ${PROJECT_NAME} -sdk iphoneos | grep -A 5 error)
    if [ -n "$CRIT_ERRS" ]; then
        echo "Framework > Error(s) while building native binary:"
        echo "$CRIT_ERRS"
        exit 1
    fi

    echo "Framework > Building simulator binary..."
    CRIT_ERRS=$(xcodebuild -configuration ${CONFIGURATION} -target ${PROJECT_NAME} -sdk iphonesimulator | grep -A 5 error)
    if [ -n "$CRIT_ERRS" ]; then
        echo "Framework > Error(s) while building simulator binary:"
        echo "$CRIT_ERRS"
        exit 1
    fi


    # Enable global script bailout on error
    set -e
 
    # Where we'll put the final framework bundle.
    # The script presumes we're in the project root directory.
    # Xcode builds in "build" by default
    FRAMEWORK_BUILD_PATH="Framework"  
 
	# This is the full name of the framework we'll build  
    FRAMEWORK_DIR=$FRAMEWORK_BUILD_PATH/$FRAMEWORK_NAME.framework
	mkdir -p $FRAMEWORK_DIR
	
    # Clean any existing framework that might already be present
    echo "Framework > Cleaning any existing files..."  

    ###[ -d "$FRAMEWORK_BUILD_PATH" ] && rm -rf "$FRAMEWORK_BUILD_PATH"  
	find "$FRAMEWORK_BUILD_PATH"/ -path '*/.svn' -prune -o -type f -exec rm -f {} +
	
    # Build the canonical Framework bundle directory structure  
    echo "Framework > Creating framework bundle directory structure..."  
      
    mkdir -p $FRAMEWORK_DIR/Versions  
    mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION  
    mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Resources  
    mkdir -p $FRAMEWORK_DIR/Versions/$FRAMEWORK_VERSION/Headers  
 
	# Creating Symbolic links, but first delete any leftovers
    echo "Framework > Creating symlinks..."  
	rm -f $FRAMEWORK_VERSION $FRAMEWORK_DIR/Versions/Current
    ln -s $FRAMEWORK_VERSION $FRAMEWORK_DIR/Versions/Current
	rm -f Versions/Current/Headers $FRAMEWORK_DIR/Headers
    ln -s Versions/Current/Headers $FRAMEWORK_DIR/Headers 
	rm -f Versions/Current/Resources $FRAMEWORK_DIR/Resources
    ln -s Versions/Current/Resources $FRAMEWORK_DIR/Resources  
	rm -f Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_DIR/$FRAMEWORK_NAME
    ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_DIR/$FRAMEWORK_NAME  
 
    # Check that this is what your static libraries are called
    FRAMEWORK_INPUT_ARM_FILES="build/$BUILD_TYPE-iphoneos/lib$FRAMEWORK_NAME.a"
    FRAMEWORK_INPUT_I386_FILES="build/$BUILD_TYPE-iphonesimulator/lib$FRAMEWORK_NAME.a"  

    # The trick for creating a fully usable library is  
    # to use lipo to glue the different library  
    # versions together into one file. When an  
    # application is linked to this library, the  
    # linker will extract the appropriate platform  
    # version and use that.  
    # The library file is given the same name as the  
    # framework with no .a extension.  
    echo "Framework > Gluing framework library together..."  
    lipo "$FRAMEWORK_INPUT_ARM_FILES" "$FRAMEWORK_INPUT_I386_FILES" -create -output "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"

    # Uncomment if you want some detailed information about the built fat
    #lipo -detailed_info "$FRAMEWORK_DIR/Versions/Current/$FRAMEWORK_NAME"
 
    # Now copy the final assets over: your library header files and the plist file
    echo "Framework > Copying assets into current version..."
    cp Resources/Framework.plist $FRAMEWORK_DIR/Info.plist

    # Recursively copy all header files also copying the folder structure
    # (from: http://www.mcwalter.org/technology/shell/recursive.html )
    function copy_files()
    {
        echo "Framework > Copying $1 files"
        tar -cf - `find . -name "*.$1" -print` | ( cd $2 && tar xBf - )
    }
    
    # All .h files in Code/$FRAMEWORK_NAME should be copied!
    # Enter Code-Dir so its not included in copy process
    cd Code/$FRAMEWORK_NAME/
    copy_files h ../../$FRAMEWORK_DIR/Headers/
    # TODO Maybe add other header file types like .hpp as required

    # Return to project root dir
    cd ../..
