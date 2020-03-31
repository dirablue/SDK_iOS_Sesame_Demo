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

    public var tokenToPase = CHOauthToken("","")

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
extension AWSCognitoOAuthService: CHLoginProvider {
    public func oauthToken() -> CHOauthToken {
        //f6f7ce55-815e-4be3-b482-04fa8591384f
//        L.d("🔥","UI請求token",pool.currentUser()?.username)
//        pool.currentUser()!.getSession().
        pool.currentUser()
        let task = pool.currentUser()!.getSession().continueWith { (task) in
                if let session = task.result,

                    let idToken = session.idToken {
//                    L.d("⚠️","jwttoken",idToken.tokenString)
//                    L.d("🔥","UI收到token",idToken.tokenString.count)
                    UserDefaults.init(suiteName: CHAppGroupApp)?.set(idToken.tokenString, forKey: "towidget")
                    return AWSTask<CHOauthToken>(result: CHOauthToken(identityProviderCognito, idToken.tokenString))
                } else {
//                    L.d("🔥","請求發生錯誤")
                    return AWSTask<CHOauthToken>(error: NSError(domain: "app_define", code: 1, userInfo: nil))
                }
            }

//        L.d("🔥","UI測試等待函數")
//        task.waitUntilFinished()

        let chToken =   task.result as? CHOauthToken ?? CHOauthToken("--","--")
//        L.d("🔥","UI被調用返回token","after waitUntilFinished",chToken.token.count)
        return chToken
    }
}
