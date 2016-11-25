//
//  Model.h
//  ThreeDViewer
//
//  Created by xiangwei wang on 9/28/16.
//  Copyright © 2016 xiangwei wang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#define ErrorDomain @"Model"

//法线
typedef struct {
    float x;
    float y;
    float z;
} Normal;

//点坐标
typedef struct {
    float x;
    float y;
    float z;
} Position;

//纹理
typedef struct {
    float u;
    float v;
} Textcoord;


//顶点，包含坐标，纹理，法线数据
typedef struct {
    Position position;
    Textcoord textcoord;
    Normal normal;
    //该顶点的索引
    long positionIndex;
} SceneVertex;

@interface Material : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, assign) GLKVector4 ambient;
@property(nonatomic, assign) GLKVector4 diffuse;
@property(nonatomic, assign) GLKVector4 spectral;
@property(nonatomic, strong) NSString *kdName;
@property(nonatomic, strong) GLKTextureInfo* mapKdTexture;
@property(nonatomic, assign) float shininess;

+(NSDictionary *) loadMaterialFromFile:(NSString *) file;
+(instancetype) defaultMaterial;
-(instancetype) initWithName:(NSString *) name;
@end

@interface MaterialGroup : NSObject

-(instancetype) initWithMaterialName:(NSString *) name;

@property(nonatomic, strong, readonly) NSString *name;
@property(nonatomic, assign) NSUInteger numOfVertices;
@end


@interface ModelGroup : NSObject

-(instancetype) initWithName:(NSString *) name;

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSMutableArray<MaterialGroup *> *materialGroup;

@end

@class Model;
@protocol ModelDelegate <NSObject>
-(void) modelDidFinishedWithError:(NSError *) error;
-(void) modelDidProcessed:(NSString *) process;
@end

@interface Model : NSObject<NSCoding> {
    
}
@property(nonatomic, readonly) NSString *path;
@property(nonatomic, weak) id<ModelDelegate> delegate;
@property(nonatomic, readonly) Position center;
@property(nonatomic, readonly) float diameter;
@property(nonatomic, readonly) float zDiameter;
@property(nonatomic, readonly) float minX;
@property(nonatomic, readonly) float minY;
@property(nonatomic, readonly) float minZ;
@property(nonatomic, readonly) float maxX;
@property(nonatomic, readonly) float maxY;
@property(nonatomic, readonly) float maxZ;
@property(nonatomic, readonly) BOOL ready;
//分组
@property(nonatomic, readonly) NSMutableArray<ModelGroup *> *modelGroup;
//从mtl文件读到的Material内容
@property(nonatomic, readonly) NSMutableDictionary *materialDict;
@property(nonatomic, readonly) NSMutableArray *materialFiles;
//模型数据里有纹理数据吗
@property(nonatomic, readonly) BOOL hasVertexCoord;
//模型数据里有法线数据吗
@property(nonatomic, readonly) BOOL hasNormal;

//顶点个数，一个顶点代表数据里的一个v行
@property(nonatomic, readonly) NSUInteger numOfVertex;
@property(nonatomic, readonly) NSUInteger numOfTriangles;
@property(nonatomic, readonly) SceneVertex *pVertices;

-(instancetype) initWithPath:(NSString *) path delegate:(id<ModelDelegate>) delegate;
//- (void)encodeWithCoder:(NSCoder *)aCoder;
//- (instancetype)initWithCoder:(NSCoder *)aDecoder;

@end
