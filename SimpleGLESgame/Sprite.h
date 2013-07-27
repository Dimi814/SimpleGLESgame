//
//  Sprite.h
//  SimpleGLESgame
//
//  Created by Dimitriy Dounaev on 30/05/13.
//  Copyright (c) 2013 Dimitriy Dounaev. All rights reserved.
//

#import <Foundation/Foundation.h>

#define SQUARE_SIZE 80.0f

@interface Sprite : NSObject


- (id)initWithEffect:(GLKBaseEffect *)baseEffect;

@property (nonatomic, strong) GLKTextureInfo *textureInfo;
@property (assign) GLKVector2 position;
@property (assign) float rotation;
@property (assign) float rotationVelocity;
@property (assign) GLKVector2 velocity;

- (void)render;
- (void)update;

@end
