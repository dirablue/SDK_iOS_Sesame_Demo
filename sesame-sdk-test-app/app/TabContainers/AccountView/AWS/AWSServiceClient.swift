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

public class AWSCognitoOAuthService: NSObject {
    public static let shared = AWSCognitoOAuthService()

    var pool: AWSCognitoIdentityUserPool

    private override init() {
        let serviceConfiguration = AWSServiceConfiguration(region: CognitoIdentityUserPoolRegion, credentialsProvider: nil)
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(
            clientId: CognitoIdentityUserPoolAppClientId,
            clientSecret: CognitoIdentityUserPoolAppClientSecret,
            poolId: CognitoIdentityUserPoolId)

        AWSCognitoIdentityUserPool.register(
            with: serviceConfiguration,
            userPoolConfiguration: poolConfiguration,
            forKey: AWSCognitoUserPoolsSignInProviderKey)

        pool = AWSCognitoIdentityUserPool(forKey: AWSCognitoUserPoolsSignInProviderKey)
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

    public func loginWithUsernamePassword(username: String, password: String, completion: @escaping (_ error: NSError?) -> Void) {
        pool.getUser(username.toMail()).getSession(username, password: password, validationData: nil).continueWith(
            block: { (task: AWSTask) -> (AnyObject)? in
            if let error = task.error {
                completion(error as NSError)
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
extension AWSCognitoOAuthService:AWSCognitoIdentityInteractiveAuthenticationDelegate{
}
extension AWSCognitoOAuthService: CHLoginProvider {//todo 動態轉靜態以節省效能
    public func oauthToken() -> CHOauthToken {
        let task = pool.currentUser()!.getSession().continueWith { (task) in
                if let session = task.result,
                    let idToken = session.idToken {
                    UserDefaults.init(suiteName: CHAppGroupApp)?.set(idToken.tokenString, forKey: "towidget")
                    return AWSTask<CHOauthToken>(result: CHOauthToken(identityProviderCognito, idToken.tokenString))
                } else {
                    return AWSTask<CHOauthToken>(error: NSError(domain: "app_define", code: 1, userInfo: nil))
                }
            }
        return task.result as? CHOauthToken ?? CHOauthToken("","")
    }
}
