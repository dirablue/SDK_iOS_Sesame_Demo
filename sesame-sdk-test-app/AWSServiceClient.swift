//
//  AWSServiceClient.Swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/19.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import AWSCognitoIdentityProvider.AWSCognitoIdentityUserPool
import AWSAPIGateway
import SesameSDK

let cognitoIdentityUserPoolId = "us-east-1_K7R63YLyO"
let cognitoIdentityUserPoolAppClientId = "1kl85keqtjvo88erq6tkoie733"
let cognitoIdentityUserPoolAppClientSecret = "1s5uimd7rbj2a4cunpf25sjsn9stiq79i7d8aacc5ea2oaijm0d2"
let identityProviderCognito = "cognito-idp.us-east-1.amazonaws.com/us-east-1_K7R63YLyO"

public class AWSCognitoOAuthService: NSObject, AWSCognitoIdentityInteractiveAuthenticationDelegate {
    public static let shared = AWSCognitoOAuthService()

    var pool: AWSCognitoIdentityUserPool

    private override init() {
        let awsConfig = AWSServiceConfiguration(region: .USEast1, credentialsProvider: nil)
        let awsUserPoolConfig = AWSCognitoIdentityUserPoolConfiguration(
            clientId: cognitoIdentityUserPoolAppClientId,
            clientSecret: cognitoIdentityUserPoolAppClientSecret,
            poolId: cognitoIdentityUserPoolId)

        AWSCognitoIdentityUserPool.register(
            with: awsConfig,
            userPoolConfiguration: awsUserPoolConfig,
            forKey: "UserPool")

        AWSServiceManager.default()?.defaultServiceConfiguration = awsConfig
        pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        super.init()
        pool.delegate = self
    }

    public var signedInUsername: String? {
        if let user = pool.currentUser() {
            return user.username
        }
        return nil
    }

    public var isSignedIn: Bool {
        return pool.currentUser()!.isSignedIn
    }

    public func loginWithUsernamePassword(username: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        pool.getUser(username).getSession(username, password: password, validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask) -> (AnyObject)? in
            if let error = task.error {
                completion(error)
            } else {
                completion(nil)
            }
            return nil
        })
    }

    public func logout() {
        pool.currentUser()?.signOut()
    }
}

extension AWSCognitoOAuthService: CHLoginProvider {
    public func oauthToken() throws -> CHOauthToken {
        // refresh token if idToken is expired
        if let user = pool.currentUser() {
            let task = user.getSession().continueWith { (task) in
                if let session = task.result,
                    let idToken = session.idToken {
                    return AWSTask<CHOauthToken>(result: CHOauthToken(identityProviderCognito, idToken.tokenString))
                } else {
                    return AWSTask<CHOauthToken>(error: NSError(domain: "app_define", code: 1, userInfo: nil))
                }
            }

            task.waitUntilFinished()
            if let token = task.result as? CHOauthToken {
                return token
            } else {
                if let error = task.error {
                    throw error
                } else {
                    throw NSError(domain: "app_define", code: 3, userInfo: nil)
                }
            }
        }
        throw NSError(domain: "app_define", code: 2, userInfo: nil)
    }
}
