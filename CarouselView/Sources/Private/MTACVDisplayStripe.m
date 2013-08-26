#import "MTACVDisplayStripe.h"
#import "CarouselViewItem.h"

const float MTADisplayStripeVertexStep = 0.05f;

typedef struct {
    float position[3];
    float textureCoord[2];
} MTACVDisplayStripeVertex;

#pragma mark MTACVDisplayStripe private interface

@interface MTACVDisplayStripe()

@property (nonatomic, assign, readwrite) CGFloat angleSector;

@property (nonatomic, assign) MTACVDisplayStripeVertex* vertices;
@property (nonatomic, assign) NSUInteger verticesLength;
@property (nonatomic, assign) GLubyte* indices;
@property (nonatomic, assign) NSUInteger indicesLength;

@property (nonatomic, assign) GLuint vertexBuffer;
@property (nonatomic, assign) GLuint indexBuffer;

-(void)calcVertices;
-(void)prepareVBOs;

@end

#pragma mark - MTACVDisplayStripe implementation

@implementation MTACVDisplayStripe
@synthesize angleSector, item, radius, glRaito;
@synthesize positionSlot, texCoordSlot, colorUniform, textureUniform, drawTypeUniform;
@synthesize vertices, verticesLength, indices, indicesLength;
@synthesize vertexBuffer, indexBuffer;

#pragma mark - MTACVDisplayStripe init methods

-(id)initWithRadius:(CGFloat)aRadius glRaito:(CGFloat)aRaito {
    if ((self = [super init])) {
        radius = aRadius;
        glRaito = aRaito;
    }
    return self;
}

#pragma mark - MTACVDisplayStripe public methods

-(void)draw:(MTACVDisplayStripeDrawType)aType {
    glBindBuffer(GL_ARRAY_BUFFER, self.vertexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, self.indexBuffer);
    
    if (self.item.texture) {
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(self.item.texture.target, self.item.texture.name);
        glUniform1i(self.textureUniform, 0);
    }
    
    GLKVector4 colorVec = GLKVector4Make(1.f, 1.f, 1.f, 1.f);
    GLint drawType = 1;
    if (aType == MTACVDisplayStripeDrawSelect) {
        drawType = 0;
    } else {
        if (![self.item.backgroundColor getRed:&colorVec.r green:&colorVec.g blue:&colorVec.b alpha:&colorVec.a]) {
            //NSLog(@"Can't convert color");
        }
    }
    glUniform1i(self.drawTypeUniform, drawType);
    glUniform4fv(self.colorUniform, 1, (GLfloat*)&colorVec);
    
    glVertexAttribPointer( self.positionSlot
                         , 3
                         , GL_FLOAT
                         , GL_FALSE
                         , sizeof(MTACVDisplayStripeVertex)
                         , 0);
    glVertexAttribPointer( self.texCoordSlot
                         , 2
                         , GL_FLOAT
                         , GL_FALSE
                         , sizeof(MTACVDisplayStripeVertex)
                         , (GLvoid*) (sizeof(float)*3));
    
    glDrawElements(GL_TRIANGLE_STRIP, indicesLength/sizeof(GLubyte), GL_UNSIGNED_BYTE, 0);
}

#pragma mark - MTACVDisplayStripe accessor methods

-(void)setItem:(id<CarouselViewItem>)aItem {
    if (aItem == item) {
        return;
    }
    item = aItem;
    [self calcVertices];
    [self prepareVBOs];
}

#pragma mark - MTACVDisplayStripe private methods

-(void)calcVertices {
    if (self.vertices) {
        free(self.vertices);
        self.vertices = 0;
        self.verticesLength = 0;
    }
    if (self.indices) {
        free(self.indices);
        self.indices = 0;
        self.indicesLength = 0;
    }
    

    CGFloat glRadius = self.radius * self.glRaito;
    CGSize glSize = CGSizeMake(self.item.size.width * self.glRaito, self.item.size.height * self.glRaito);
    self.angleSector = M_PI*2*(glSize.width / (glRadius*2*M_PI));
    
    NSUInteger verLines = (NSUInteger)((float)glSize.width / (float)MTADisplayStripeVertexStep);
    self.verticesLength = sizeof(MTACVDisplayStripeVertex)*((verLines+1)*2);
    self.indicesLength = sizeof(GLubyte)*(verLines)*6;
    if (verLines == 0) {
        return;
    }
    
    self.vertices = malloc(self.verticesLength);
    if (!self.verticesLength) {
        NSLog(@"Malloc error. (MTACVDisplayStripe)");
        exit(1);
    }
    self.indices = malloc(self.indicesLength);
    if (!self.indicesLength) {
        NSLog(@"Malloc error. (MTACVDisplayStripe)");
        exit(1);
    }
    
    float texStep = 1.f / (float)verLines;
    float texVal = 0.f;
    float horVal = 0.f;
    for (NSUInteger i = 0; i < verLines+1; i++) {
        CGFloat angle = self.angleSector*(horVal/glSize.width);
        CGFloat x = sin(angle)*glRadius;
        CGFloat z = cos(angle)*glRadius;
        
        vertices[i].position[0] = x;
        vertices[i].position[1] = -glSize.height/2.f;
        vertices[i].position[2] = -z;
        vertices[i].textureCoord[0] = texVal;
        vertices[i].textureCoord[1] = 1.f;
        
        vertices[i+verLines+1].position[0] = x;
        vertices[i+verLines+1].position[1] = glSize.height/2.f;
        vertices[i+verLines+1].position[2] = -z;
        vertices[i+verLines+1].textureCoord[0] = texVal;
        vertices[i+verLines+1].textureCoord[1] = 0.f;
        
        texVal += texStep;
        horVal += MTADisplayStripeVertexStep;
    }
    
    for (NSUInteger i = 0; i < verLines; i++) {
        indices[i*6]   = i;
        indices[i*6+1] = i+1;
        indices[i*6+2] = i+verLines+1;
        
        indices[i*6+3] = i+1;
        indices[i*6+4] = i+verLines+1;
        indices[i*6+5] = i+verLines+2;
    }
}

-(void)prepareVBOs {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, verticesLength, vertices, GL_STATIC_DRAW);
    
    glGenBuffers(1, &indexBuffer);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indicesLength, indices, GL_STATIC_DRAW);
}

@end
