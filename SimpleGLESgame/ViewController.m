//
//  ViewController.m
//  SimpleGLESgame
//
//  Created by Dimitriy Dounaev on 10/05/13.
//  Copyright (c) 2013 Dimitriy Dounaev. All rights reserved.
//

#import "ViewController.h"
#import "Sprite.h"

typedef struct {
    
    GLKVector3 positionCoordinates;
    GLKVector2 textureCoordinates;
    
} VertexData;


VertexData vertices[] = {
    
    {{ -SQUARE_SIZE/2, -SQUARE_SIZE/2, 0.0f}, {0.0f, 0.0f}},
    {{ SQUARE_SIZE/2,  -SQUARE_SIZE/2, 0.0f},{1.0f, 0.0f}},
    {{ -SQUARE_SIZE/2, SQUARE_SIZE/2, 0.0f}, {0.0f, 1.0f}},
    {{  -SQUARE_SIZE/2, SQUARE_SIZE/2, 0.0f}, {0.0f, 1.0f}},
    {{  SQUARE_SIZE/2, -SQUARE_SIZE/2, 0.0f}, {1.0f, 0.0f}},
    {{  SQUARE_SIZE/2, SQUARE_SIZE/2, 0.0f}, {1.0f, 1.0f}}
    
};

@interface ViewController ()

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) Sprite *playerRocket;
@property (nonatomic, strong) NSMutableArray *rockArray;

@end

@implementation ViewController {
    
    GLuint _vertexBufferID;
    NSMutableArray *balls;
    GLKTextureInfo *_ballTextureInfo;
    GLKTextureInfo *_rockTextureInfo;
    
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        
         balls = [[NSMutableArray alloc] initWithCapacity:20];
        self.rockArray = [[NSMutableArray alloc] initWithCapacity:20];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    [EAGLContext setCurrentContext:self.context];
    
    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.useConstantColor = YES;
    //self.baseEffect.constantColor = GLKVector4Make(1.0f, 0.0f, 0.0f, 1.0f);
    
    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakeOrtho(0, 640, 0, 1136, 0, 0);
    
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    
    glGenBuffers(1, &_vertexBufferID);
    glBindBuffer(GL_ARRAY_BUFFER, _vertexBufferID);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(VertexData),offsetof(VertexData, positionCoordinates));
    
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(VertexData), (GLvoid *) offsetof(VertexData, textureCoordinates));
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(changeRocketLocation:)];
    [self.view addGestureRecognizer:gestureRecognizer];
    
    UISwipeGestureRecognizer *swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(shoot:)];
    swipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeGestureRecognizer];
    
    
    
    GLKTextureInfo *textureInfo = [self loadImage:@"IOSRocket"];
    _ballTextureInfo = [self loadImage:@"ball.png"];
    _rockTextureInfo = [self loadImage:@"RockForGame.png"];

    
    self.playerRocket = [[Sprite alloc] initWithEffect:self.baseEffect];
    self.playerRocket.textureInfo = textureInfo;
    self.playerRocket.position = GLKVector2Make(320, 200);

}

- (GLKTextureInfo *)loadImage:(NSString *)imageName
{
    CGImageRef imageReference = [[UIImage imageNamed:imageName] CGImage];
    
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:imageReference
                                                               options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:GLKTextureLoaderOriginBottomLeft]
                                                                 error:NULL];
    
    return textureInfo;
}
                                                 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    [EAGLContext setCurrentContext:self.context];
    glDeleteBuffers(1, &_vertexBufferID);
    
    GLuint textureBufferID = self.playerRocket.textureInfo.name;
    glDeleteTextures(1, &textureBufferID);
    textureBufferID = _ballTextureInfo.name;
    glDeleteTextures(1, &textureBufferID);
    textureBufferID = _rockTextureInfo.name;
    glDeleteTextures(1, &textureBufferID);
    
    self.baseEffect = nil;
    self.context = nil;
    
    [EAGLContext setCurrentContext:nil];
    
}

- (void)addRock
{
    Sprite *newRock;
    
    int xLocation = (arc4random()%(int)self.view.bounds.size.width*2)+1;
    GLKVector2 position = GLKVector2Make(xLocation, SQUARE_SIZE + self.view.bounds.size.height*2);
    
    for (Sprite *rock in self.rockArray) {
        if (rock.position.y < 0 - SQUARE_SIZE) {
            rock.position = position;
            newRock = rock;
            break;
        }
    }
    
    if (newRock == nil) {
    newRock = [[Sprite alloc] initWithEffect:self.baseEffect];
    newRock.textureInfo = _rockTextureInfo;
    newRock.position = position;
    newRock.velocity = GLKVector2Make(0.0f, -5.0f);
    newRock.rotationVelocity = -5;
    [self.rockArray addObject:newRock];
    }
    
    NSLog(@"%d", [self.rockArray count]);
}

- (void)changeRocketLocation:(UITapGestureRecognizer *)gestureRecognizer
{
    int xLocation = [gestureRecognizer locationInView:self.view].x;
    
    self.playerRocket.position = GLKVector2Make(xLocation*2, 200);
}

- (void)shoot:(UISwipeGestureRecognizer *)gestureRecognizer
{
    Sprite *ball;
    
    for (Sprite *newball in balls) {
        if (newball.position.y > self.view.bounds.size.height*2) {
            ball = newball;
            ball.position = GLKVector2Add(self.playerRocket.position, GLKVector2Make(0.0f, SQUARE_SIZE*0.8));
            break;
        }
    }
    if (ball == nil) {
    ball = [[Sprite alloc] initWithEffect:self.baseEffect];
    ball.textureInfo = _ballTextureInfo;
    ball.position = GLKVector2Add(self.playerRocket.position, GLKVector2Make(0.0f, SQUARE_SIZE*0.8));
    ball.velocity = GLKVector2Make(0.0f, 10.0f);
    ball.rotationVelocity = 5;
    [balls addObject:ball];
    }
}

#pragma mark - GLKView delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClear(GL_COLOR_BUFFER_BIT);
    
    [self.playerRocket render];
    for ( Sprite *ball in balls ) {
        if (!(ball.position.y > self.view.bounds.size.height*2))
        [ball render];
    }
    
    for ( Sprite *rock in self.rockArray ) {
        if (!(rock.position.y < 0 - SQUARE_SIZE))
            [rock render];
    }
}

- (BOOL)checkForCollision:(Sprite *)rock ball:(Sprite *)ball
{
    return !(rock.position.x + SQUARE_SIZE/2 <= ball.position.x - SQUARE_SIZE/2 ||
             rock.position.x - SQUARE_SIZE/2 >= ball.position.x + SQUARE_SIZE/2 ||
             rock.position.y + SQUARE_SIZE/2 <= ball.position.y - SQUARE_SIZE/2 ||
             rock.position.y - SQUARE_SIZE/2 >= ball.position.y + SQUARE_SIZE/2);
}

- (void)update
{
    
    for (Sprite *rock in self.rockArray) {
        
        if ([self checkForCollision:rock ball:self.playerRocket]) {
            rock.position = GLKVector2Make(0.0f, 0 - SQUARE_SIZE);
        }
        
        for (Sprite *ball in balls) {
            if ([self checkForCollision:rock ball:ball]) {
                rock.position = GLKVector2Make(0.0f, 0 - SQUARE_SIZE);
                ball.position = GLKVector2Make(0.0f, self.view.bounds.size.height*2);
            }
        }
    }
    
    static double lastRock;
    lastRock += self.timeSinceLastUpdate;
    if (lastRock >= 1.0f) {
        [self addRock];
        lastRock = 0.0f;
    }
    
    [self.playerRocket update];
    for ( Sprite *ball in balls ) {
        if (!(ball.position.y > self.view.bounds.size.height*2))
        [ball update];
    }
    
    for ( Sprite *rock in self.rockArray ) {
        if (!(rock.position.y < 0 - SQUARE_SIZE))
            [rock update];
    }
}

@end
