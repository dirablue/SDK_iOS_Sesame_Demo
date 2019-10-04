// Generated by Apple Swift version 5.0.1 effective-4.2 (swiftlang-1001.0.82.4 clang-1001.0.46.5)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgcc-compat"

#if !defined(__has_include)
# define __has_include(x) 0
#endif
#if !defined(__has_attribute)
# define __has_attribute(x) 0
#endif
#if !defined(__has_feature)
# define __has_feature(x) 0
#endif
#if !defined(__has_warning)
# define __has_warning(x) 0
#endif

#if __has_include(<swift/objc-prologue.h>)
# include <swift/objc-prologue.h>
#endif

#pragma clang diagnostic ignored "-Wauto-import"
#include <Foundation/Foundation.h>
#include <stdint.h>
#include <stddef.h>
#include <stdbool.h>

#if !defined(SWIFT_TYPEDEFS)
# define SWIFT_TYPEDEFS 1
# if __has_include(<uchar.h>)
#  include <uchar.h>
# elif !defined(__cplusplus)
typedef uint_least16_t char16_t;
typedef uint_least32_t char32_t;
# endif
typedef float swift_float2  __attribute__((__ext_vector_type__(2)));
typedef float swift_float3  __attribute__((__ext_vector_type__(3)));
typedef float swift_float4  __attribute__((__ext_vector_type__(4)));
typedef double swift_double2  __attribute__((__ext_vector_type__(2)));
typedef double swift_double3  __attribute__((__ext_vector_type__(3)));
typedef double swift_double4  __attribute__((__ext_vector_type__(4)));
typedef int swift_int2  __attribute__((__ext_vector_type__(2)));
typedef int swift_int3  __attribute__((__ext_vector_type__(3)));
typedef int swift_int4  __attribute__((__ext_vector_type__(4)));
typedef unsigned int swift_uint2  __attribute__((__ext_vector_type__(2)));
typedef unsigned int swift_uint3  __attribute__((__ext_vector_type__(3)));
typedef unsigned int swift_uint4  __attribute__((__ext_vector_type__(4)));
#endif

#if !defined(SWIFT_PASTE)
# define SWIFT_PASTE_HELPER(x, y) x##y
# define SWIFT_PASTE(x, y) SWIFT_PASTE_HELPER(x, y)
#endif
#if !defined(SWIFT_METATYPE)
# define SWIFT_METATYPE(X) Class
#endif
#if !defined(SWIFT_CLASS_PROPERTY)
# if __has_feature(objc_class_property)
#  define SWIFT_CLASS_PROPERTY(...) __VA_ARGS__
# else
#  define SWIFT_CLASS_PROPERTY(...)
# endif
#endif

#if __has_attribute(objc_runtime_name)
# define SWIFT_RUNTIME_NAME(X) __attribute__((objc_runtime_name(X)))
#else
# define SWIFT_RUNTIME_NAME(X)
#endif
#if __has_attribute(swift_name)
# define SWIFT_COMPILE_NAME(X) __attribute__((swift_name(X)))
#else
# define SWIFT_COMPILE_NAME(X)
#endif
#if __has_attribute(objc_method_family)
# define SWIFT_METHOD_FAMILY(X) __attribute__((objc_method_family(X)))
#else
# define SWIFT_METHOD_FAMILY(X)
#endif
#if __has_attribute(noescape)
# define SWIFT_NOESCAPE __attribute__((noescape))
#else
# define SWIFT_NOESCAPE
#endif
#if __has_attribute(warn_unused_result)
# define SWIFT_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
# define SWIFT_WARN_UNUSED_RESULT
#endif
#if __has_attribute(noreturn)
# define SWIFT_NORETURN __attribute__((noreturn))
#else
# define SWIFT_NORETURN
#endif
#if !defined(SWIFT_CLASS_EXTRA)
# define SWIFT_CLASS_EXTRA
#endif
#if !defined(SWIFT_PROTOCOL_EXTRA)
# define SWIFT_PROTOCOL_EXTRA
#endif
#if !defined(SWIFT_ENUM_EXTRA)
# define SWIFT_ENUM_EXTRA
#endif
#if !defined(SWIFT_CLASS)
# if __has_attribute(objc_subclassing_restricted)
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) __attribute__((objc_subclassing_restricted)) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# else
#  define SWIFT_CLASS(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
#  define SWIFT_CLASS_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_CLASS_EXTRA
# endif
#endif

#if !defined(SWIFT_PROTOCOL)
# define SWIFT_PROTOCOL(SWIFT_NAME) SWIFT_RUNTIME_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
# define SWIFT_PROTOCOL_NAMED(SWIFT_NAME) SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_PROTOCOL_EXTRA
#endif

#if !defined(SWIFT_EXTENSION)
# define SWIFT_EXTENSION(M) SWIFT_PASTE(M##_Swift_, __LINE__)
#endif

#if !defined(OBJC_DESIGNATED_INITIALIZER)
# if __has_attribute(objc_designated_initializer)
#  define OBJC_DESIGNATED_INITIALIZER __attribute__((objc_designated_initializer))
# else
#  define OBJC_DESIGNATED_INITIALIZER
# endif
#endif
#if !defined(SWIFT_ENUM_ATTR)
# if defined(__has_attribute) && __has_attribute(enum_extensibility)
#  define SWIFT_ENUM_ATTR(_extensibility) __attribute__((enum_extensibility(_extensibility)))
# else
#  define SWIFT_ENUM_ATTR(_extensibility)
# endif
#endif
#if !defined(SWIFT_ENUM)
# define SWIFT_ENUM(_type, _name, _extensibility) enum _name : _type _name; enum SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# if __has_feature(generalized_swift_name)
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) enum _name : _type _name SWIFT_COMPILE_NAME(SWIFT_NAME); enum SWIFT_COMPILE_NAME(SWIFT_NAME) SWIFT_ENUM_ATTR(_extensibility) SWIFT_ENUM_EXTRA _name : _type
# else
#  define SWIFT_ENUM_NAMED(_type, _name, SWIFT_NAME, _extensibility) SWIFT_ENUM(_type, _name, _extensibility)
# endif
#endif
#if !defined(SWIFT_UNAVAILABLE)
# define SWIFT_UNAVAILABLE __attribute__((unavailable))
#endif
#if !defined(SWIFT_UNAVAILABLE_MSG)
# define SWIFT_UNAVAILABLE_MSG(msg) __attribute__((unavailable(msg)))
#endif
#if !defined(SWIFT_AVAILABILITY)
# define SWIFT_AVAILABILITY(plat, ...) __attribute__((availability(plat, __VA_ARGS__)))
#endif
#if !defined(SWIFT_DEPRECATED)
# define SWIFT_DEPRECATED __attribute__((deprecated))
#endif
#if !defined(SWIFT_DEPRECATED_MSG)
# define SWIFT_DEPRECATED_MSG(...) __attribute__((deprecated(__VA_ARGS__)))
#endif
#if __has_feature(attribute_diagnose_if_objc)
# define SWIFT_DEPRECATED_OBJC(Msg) __attribute__((diagnose_if(1, Msg, "warning")))
#else
# define SWIFT_DEPRECATED_OBJC(Msg) SWIFT_DEPRECATED_MSG(Msg)
#endif
#if __has_feature(modules)
#if __has_warning("-Watimport-in-framework-header")
#pragma clang diagnostic ignored "-Watimport-in-framework-header"
#endif
@import AWSCore;
@import Foundation;
@import ObjectiveC;
#endif

#import <AWSMobileClient/AWSMobileClient.h>

#pragma clang diagnostic ignored "-Wproperty-attribute-mismatch"
#pragma clang diagnostic ignored "-Wduplicate-method-arg"
#if __has_warning("-Wpragma-clang-attribute")
# pragma clang diagnostic ignored "-Wpragma-clang-attribute"
#endif
#pragma clang diagnostic ignored "-Wunknown-pragmas"
#pragma clang diagnostic ignored "-Wnullability"

#if __has_attribute(external_source_symbol)
# pragma push_macro("any")
# undef any
# pragma clang attribute push(__attribute__((external_source_symbol(language="Swift", defined_in="AWSMobileClient",generated_declaration))), apply_to=any(function,enum,objc_interface,objc_category,objc_protocol))
# pragma pop_macro("any")
#endif

@class UIApplication;
@protocol AWSIdentityProviderManager;
@protocol AWSCognitoCredentialsProviderHelper;

/// <code>AWSMobileClient</code> is used for all auth related operations when your app is accessing AWS backend.
SWIFT_CLASS("_TtC15AWSMobileClient15AWSMobileClient")
@interface AWSMobileClient : _AWSMobileClient
/// The identity id associated with this provider. This value will be fetched from the keychain at startup. If you do not want to reuse the existing identity id, you must call the clearKeychain method. If the identityId is not fetched yet, it will return nil. Use <code>getIdentityId()</code> method to force a server fetch when identityId is not available.
@property (nonatomic, readonly, copy) NSString * _Nullable identityId;
- (BOOL)interceptApplication:(UIApplication * _Nonnull)application openURL:(NSURL * _Nonnull)url sourceApplication:(NSString * _Nullable)sourceApplication annotation:(id _Nonnull)annotation SWIFT_WARN_UNUSED_RESULT;
/// Returns true if there is a user currently signed in.
@property (nonatomic, readonly) BOOL isSignedIn;
/// The singleton instance of <code>AWSMobileClient</code>.
///
/// returns:
/// The singleton <code>AWSMobileClient</code> instance.
+ (AWSMobileClient * _Nonnull)sharedInstance SWIFT_WARN_UNUSED_RESULT;
- (nonnull instancetype)initWithRegionType:(AWSRegionType)regionType identityPoolId:(NSString * _Nonnull)identityPoolId OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithRegionType:(AWSRegionType)regionType identityPoolId:(NSString * _Nonnull)identityPoolId identityProviderManager:(id <AWSIdentityProviderManager> _Nullable)identityProviderManager OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithRegionType:(AWSRegionType)regionType identityProvider:(id <AWSCognitoCredentialsProviderHelper> _Nonnull)identityProvider OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithRegionType:(AWSRegionType)regionType unauthRoleArn:(NSString * _Nullable)unauthRoleArn authRoleArn:(NSString * _Nullable)authRoleArn identityProvider:(id <AWSCognitoCredentialsProviderHelper> _Nonnull)identityProvider OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)initWithRegionType:(AWSRegionType)regionType identityPoolId:(NSString * _Nonnull)identityPoolId unauthRoleArn:(NSString * _Nullable)unauthRoleArn authRoleArn:(NSString * _Nullable)authRoleArn identityProviderManager:(id <AWSIdentityProviderManager> _Nullable)identityProviderManager OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init OBJC_DESIGNATED_INITIALIZER;
@end



@class NSDictionary;

@interface AWSMobileClient (SWIFT_EXTENSION(AWSMobileClient)) <AWSIdentityProviderManager>
/// Each entry in logins represents a single login with an identity provider. The key is the domain of the login provider (e.g. ‘graph.facebook.com’) and the value is the OAuth/OpenId Connect token that results from an authentication with that login provider.
- (AWSTask<NSDictionary *> * _Nonnull)logins SWIFT_WARN_UNUSED_RESULT;
@end

@class AWSSignInProviderConfig;
@class AWSCognitoCredentialsProvider;

@interface AWSMobileClient (SWIFT_EXTENSION(AWSMobileClient))
- (BOOL)interceptApplication:(UIApplication * _Nonnull)application didFinishLaunchingWithOptions:(NSDictionary * _Nullable)launchOptions SWIFT_WARN_UNUSED_RESULT;
- (BOOL)interceptApplication:(UIApplication * _Nonnull)application didFinishLaunchingWithOptions:(NSDictionary * _Nullable)launchOptions resumeSessionWithCompletionHandler:(void (^ _Nonnull)(id _Nonnull, NSError * _Nonnull))completionHandler SWIFT_WARN_UNUSED_RESULT;
- (void)setSignInProviders:(NSArray<AWSSignInProviderConfig *> * _Nullable)signInProviderConfig;
/// Get the credentials provider object which provides <code>AWSCredentials</code>.
///
/// returns:
/// An object which implements <code>AWSCredentialsProvider</code>.
- (AWSCognitoCredentialsProvider * _Nonnull)getCredentialsProvider SWIFT_WARN_UNUSED_RESULT;
@end

@class AWSCredentials;
@class NSString;

@interface AWSMobileClient (SWIFT_EXTENSION(AWSMobileClient))
/// Asynchronously returns a valid AWS credentials or an error object if it cannot retrieve valid credentials. It should cache valid credentials as much as possible and refresh them when they are invalid.
///
/// returns:
/// A valid AWS credentials or an error object describing the error.
- (AWSTask<AWSCredentials *> * _Nonnull)credentials SWIFT_WARN_UNUSED_RESULT;
/// Invalidates the cached temporary AWS credentials. If the credentials provider does not cache temporary credentials, this operation is a no-op.
- (void)invalidateCachedTemporaryCredentials;
/// Get/retrieve the identity id for this provider. If an identity id is already set on this provider, no remote call is made and the identity will be returned as a result of the AWSTask (the identityId is also available as a property). If no identityId is set on this provider, one will be retrieved from the service.
///
/// returns:
/// Asynchronous task which contains the identity id or error.
- (AWSTask<NSString *> * _Nonnull)getIdentityId SWIFT_WARN_UNUSED_RESULT;
/// Clear the cached AWS credentials for this provider.
- (void)clearCredentials;
/// Clear ALL saved values for this provider (identityId, credentials, logins).
- (void)clearKeychain;
@end





@class UIImage;
@class UIColor;

/// The options object for drop-in UI which allows changing properties like logo image and background color.
SWIFT_CLASS("_TtC15AWSMobileClient15SignInUIOptions")
@interface SignInUIOptions : NSObject
/// If true, the end user can cancel the sign-in operation and go back to previous view controller.
@property (nonatomic, readonly) BOOL canCancel;
/// The logo image to be displayed on the sign-in screen.
@property (nonatomic, readonly, strong) UIImage * _Nullable logoImage;
/// The background color of the sign-in screen.
@property (nonatomic, readonly, strong) UIColor * _Nullable backgroundColor;
/// Initializer for the drop-in UI configuration.
/// \param canCancel If set to true, the end user can cancel the sign-in operation and go back to previous view controller.
///
/// \param logoImage The logo image to be displayed on the sign-in screen.
///
/// \param backgroundColor The background color of the sign-in screen.
///
- (nonnull instancetype)initWithCanCancel:(BOOL)canCancel logoImage:(UIImage * _Nullable)logoImage backgroundColor:(UIColor * _Nullable)backgroundColor OBJC_DESIGNATED_INITIALIZER;
- (nonnull instancetype)init SWIFT_UNAVAILABLE;
+ (nonnull instancetype)new SWIFT_DEPRECATED_MSG("-init is unavailable");
@end

#if __has_attribute(external_source_symbol)
# pragma clang attribute pop
#endif
#pragma clang diagnostic pop
