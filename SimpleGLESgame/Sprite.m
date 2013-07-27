//
//  Sprite.m
//  SimpleGLESgame
//
//  Created by Dimitriy Dounaev on 30/05/13.
//  Copyright (c) 2013 Dimitriy Dounaev. All rights reserved.
//

#import "Sprite.h"

@interface Sprite()

@property (nonatomic, weak) GLKBaseEffect *baseEffect;

@end

@implementation Sprite

- (id)initWithEffect:(GLKBaseEffect *)baseEffect
{
    if ((self = [super init])) {
        
        self.baseEffect = baseEffect;

    }
    
    return self;
}


- (void)render
{
    self.baseEffect.texture2d0.name = self.textureInfo.name;
    self.baseEffect.texture2d0.target = self.textureInfo.target;
    
    
    GLKMatrix4 modelviewMatrix =
    GLKMatrix4Translate(GLKMatrix4Identity, self.position.x, self.position.y, 0);
    modelviewMatrix = GLKMatrix4Rotate(modelviewMatrix, GLKMathDegreesToRadians(self.rotation), 0.0f, 0.0f, 1.0f);
    self.baseEffect.transform.modelviewMatrix = modelviewMatrix;
    
    [self.baseEffect prepareToDraw];
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
}

- (void)update
{
    self.position = GLKVector2Add(self.position, self.velocity);
    self.rotation += self.rotationVelocity;
}

@end
