//
//  B3DLabel.m
//  Bane3D
//
//  Created by Andreas Hanft on 14.01.13.
//  Copyright (c) 2013 talantium.net. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "B3DLabel.h"

#import "B3DTextureFont.h"
#import "B3DConstants.h"
#import "B3DShaderDefaultBaseColor.h"
#import "B3DRenderMan.h"
#import "B3DShader.h"
#import "B3DMaterial.h"
#import "B3DScene.h"
#import "B3DCamera.h"
#import "B3DVisibleNode+Protected.h"


@interface B3DLabel ()
{
    @private
        BOOL                _textDirty;
        GLint               _vertices;
    
        GLuint              _vertexArrayObject;
        GLuint              _vertexBufferObject;
}

@property (nonatomic, readwrite, weak) B3DTextureFont*     textureFont;

- (void) createBuffers;
- (void) tearDownBuffers;

@end


@implementation B3DLabel

- (id) initWithText:(NSString*)text
{
    return [self initWithFont:[UIFont systemFontOfSize:B3DLabelDefaultFontSize] text:text];
}

- (id) initWithFontNamed:(NSString*)fontName size:(CGFloat)size
{
    return [self initWithFont:[UIFont fontWithName:fontName size:size] text:nil];
}

- (id) initWithFontNamed:(NSString*)fontName size:(CGFloat)size text:(NSString*)text
{
    return [self initWithFont:[UIFont fontWithName:fontName size:size] text:text];
}

- (id) initWithFont:(UIFont*)font text:(NSString*)text
{
    self = [super init];
    if (self)
    {
        [self useShader:[B3DShaderDefaultBaseColor token]];
        
        if (font)
		{
            B3DAssetToken* textureFontToken = [B3DTextureFont tokenForFont:font];
            [self useAssetWithToken:textureFontToken
                          atKeyPath:@"material.texture"];
            
            [self useAssetWithToken:textureFontToken
                          atKeyPath:@"textureFont"];
		}

        _batchable  = NO;
        _useOrtho   = YES;
        
        if (text)
        {
            _text = [text copy];
            _textDirty = YES;
        }
    }
    
    return self;
}

- (void) dealloc
{
    [self tearDownBuffers];
}

- (void) create
{
    [super create];
    
    [self createBuffers];
}

- (void) awake
{
    [super awake];
    
    self.material.baseColor = self.color;
}

- (void) destroy
{
    [self tearDownBuffers];
    
    [super destroy];
}


#pragma mark - Buffer Handling

- (void) createBuffers
{
    // Creating VAO's must be done on the main thread, see
    // http://stackoverflow.com/questions/7125257/can-vertex-array-objects-vaos-be-shared-across-eaglcontexts-in-opengl-es
    
    dispatch_block_t block = ^(void)
    {
        // Create a buffer and array storage to render a single sprite node
        if (_vertexArrayObject == 0)
        {
            // Create and bind a vertex array object.
            glGenVertexArraysOES(1, &_vertexArrayObject);
            glBindVertexArrayOES(_vertexArrayObject);
            
            // Configure the attributes in the VAO.
            glGenBuffers(1, &_vertexBufferObject);
            glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
            glBufferData(GL_ARRAY_BUFFER, sizeof(B3DTextureFontCharSprite) * B3DLabelMaxLabelLength, NULL, GL_STREAM_DRAW);
            
            GLsizei size = sizeof(B3DTextureFontCharVertice);
            
            glEnableVertexAttribArray(B3DVertexAttributesPosition);
            glVertexAttribPointer(B3DVertexAttributesPosition, 3, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(0));
            
            glEnableVertexAttribArray(B3DVertexAttributesTexCoord0);
            glVertexAttribPointer(B3DVertexAttributesTexCoord0, 2, GL_FLOAT, GL_FALSE, size, BUFFER_OFFSET(12));
            
            // Bind back to the default state.
            glBindVertexArrayOES(0);
        }
    };
    
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

- (void) tearDownBuffers
{
    if (_vertexBufferObject != 0)
    {
        glDeleteBuffers(1, &_vertexBufferObject);
        
        _vertexBufferObject = 0;
    }
    
    if (_vertexArrayObject != 0)
    {
        glDeleteVertexArraysOES(1, &_vertexArrayObject);
        
        _vertexArrayObject = 0;
    }
    
    _textDirty = YES;
}


#pragma mark - Properties

- (void) setText:(NSString*)text
{
    if ([_text isEqualToString:text] == NO)
    {
        _text = [text copy];
        _size = CGSizeZero;
        _textDirty = YES;
    }
}


#pragma mark - Loop

- (void) update
{
    [super update];
    
    if (_textDirty)
    {
        _vertices = 0;
        NSDictionary* charDict = _textureFont.charDict;

        unsigned int length = _text.length;
        unichar buffer[length + 1];
        [_text getCharacters:buffer range:NSMakeRange(0, length)];
        
        CGFloat spacing = 0.0f;
        CGPoint currentPosition = CGPointZero;

        NSString* currentCharAsString = nil;
        B3DTextureFontCharMapInfo currentCharInfo;
        
        glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
        B3DTextureFontCharSprite* textRepresentation = (B3DTextureFontCharSprite*) glMapBufferOES(GL_ARRAY_BUFFER, GL_WRITE_ONLY_OES);
        if (textRepresentation)
        {
            for (int i = 0; i < length; ++i)
            {
                unichar currentChar = buffer[i];
                currentCharAsString = [NSString stringWithCharacters:&currentChar length:1];
                
                NSValue* value = [charDict objectForKey:currentCharAsString];
                if (value == nil)
                {
                    value = [charDict objectForKey:@"?"];
                }
                [value getValue:&currentCharInfo];
                
                textRepresentation[i].bottomLeft.position   = GLKVector3Make(currentPosition.x, currentPosition.y, 0.0f);
                textRepresentation[i].bottomRight.position  = GLKVector3Make(currentPosition.x + currentCharInfo.size.width, currentPosition.y, 0.0f);
                textRepresentation[i].topLeft.position      = GLKVector3Make(currentPosition.x, currentPosition.y + currentCharInfo.size.height, 0.0f);
                textRepresentation[i].topRight.position     = GLKVector3Make(currentPosition.x + currentCharInfo.size.width, currentPosition.y + currentCharInfo.size.height, 0.0f);
                currentPosition.x += spacing + currentCharInfo.size.width;
                
                _size.width = currentPosition.x - spacing; // Remove spacing for bounding size
                _size.height = MAX(_size.height, currentCharInfo.size.height);
                
                textRepresentation[i].bottomLeft.texCoords  = currentCharInfo.textCoords[0];
                textRepresentation[i].bottomRight.texCoords = currentCharInfo.textCoords[1];
                textRepresentation[i].topLeft.texCoords     = currentCharInfo.textCoords[2];
                textRepresentation[i].topRight.texCoords    = currentCharInfo.textCoords[3];
                
                textRepresentation[i].degeneratedFirst      = textRepresentation[i].bottomLeft;
                textRepresentation[i].degeneratedLast       = textRepresentation[i].topRight;
                
                _vertices += 6;
            }
            
            // Discard last degenerated sprite
            _vertices -= 1;
            glUnmapBufferOES(GL_ARRAY_BUFFER);
            
            _textDirty = NO;
        }
        else
        {
            LogError(@"No VBO available for label!");
        }
    }
}

- (void) draw
{
    [super draw];
    
    if (_opaque)
    {
        // No batching atm
        [self render];
    }
    else
    {
        // We need to z-sort any nodes prior drawing!
        [_renderMan drawTransparentLabel:self];
    }
}

- (void) render
{
    // Optimize access to some properties
    B3DShader* shader = self.material.shader;

    if (_useOrtho)
    {
        [self.parentScene useOrthoCamera];
    }
    
    // Bind the vertex array storage for single sprite rendering
    glBindVertexArrayOES(_vertexArrayObject);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferObject);
    
    // Create Model-View-Projection-Matrix based on currently used scene camera
    static GLKMatrix4 matrix_mvp;
    matrix_mvp = GLKMatrix4Multiply(self.parentScene.mainCamera.viewMatrix, [self absoluteTransform]);
    [shader setMatrix4Value:matrix_mvp forUniformNamed:B3DShaderUniformMatrixMVP];
    [shader setIntValue:0 forUniformNamed:B3DShaderUniformTextureBase];
    [shader setBoolValue:YES forUniformNamed:B3DShaderUniformToggleTextureAlphaOnly];
    
    [_material enable];
    
    // Finally draw
    glDisable(GL_CULL_FACE);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, _vertices);
    glEnable(GL_CULL_FACE);
    
    [_material disable];
    
    if (_useOrtho)
    {
        [self.parentScene usePerspectiveCamera];
    }
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}


@end
