//
//  AWSCognitoOAuthService.swift
//  sesame-sdk-test-app
//
//  Created by Yiling on 2019/08/19.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import AWSCognitoIdentityProvider.AWSCognitoIdentityUserPool
import PromiseKit
import AWSAPIGateway
import SesameSDK

let cognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let cognitoIdentityUserPoolId = "us-east-1_K7R63YLyO"
let cognitoIdentityUserPoolAppClientId = "1kl85keqtjvo88erq6tkoie733"
let cognitoIdentityUserPoolAppClientSecret = "1s5uimd7rbj2a4cunpf25sjsn9stiq79i7d8aacc5ea2oaijm0d2"
let identityProviderCognito = "cognito-idp.us-east-1.amazonaws.com/us-east-1_K7R63YLyO"

public class AWSCognitoOAuthService: NSObject, AWSCognitoIdentityInteractiveAuthenticationDelegate, CHLoginProvider {
    public static let shared = AWSCognitoOAuthService()

    internal var configuration: AWSServiceConfiguration
    internal var pool: AWSCognitoIdentityUserPool

    var user: AWSCognitoIdentityUser
    var poolConfiguration: AWSCognitoIdentityUserPoolConfiguration?

    private override init() {
        configuration = AWSServiceConfiguration(region: cognitoIdentityUserPoolRegion, credentialsProvider: nil)

        AWSCognitoIdentityUserPool.register(with: configuration, userPoolConfiguration: AWSCognitoIdentityUserPoolConfiguration.init(clientId: cognitoIdentityUserPoolAppClientId, clientSecret: cognitoIdentityUserPoolAppClientSecret, poolId: cognitoIdentityUserPoolId), forKey: "UserPool")

        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
        pool = AWSCognitoIdentityUserPool(forKey: "UserPool")
        user = pool.currentUser()!
    }

    public func applicationDidLaunch(application: UIApplication, launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        let serviceConfiguration = AWSServiceConfiguration(region: cognitoIdentityUserPoolRegion, credentialsProvider: nil)
        poolConfiguration = AWSCognitoIdentityUserPoolConfiguration.init(clientId: cognitoIdentityUserPoolAppClientId, clientSecret: cognitoIdentityUserPoolAppClientSecret, poolId: cognitoIdentityUserPoolId)
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration!, forKey: "UserPool")
        pool.delegate = self
    }

    public var signedInUsername: String? {
        if let user = pool.currentUser() {
            return user.username
        }
        return nil
    }

    public var isSignedIn: Bool {
        if let user = pool.currentUser() {
            return user.isSignedIn
        }
        return false
    }

    public func oauthToken() throws -> CHOauthToken {
        // refresh token if idToken is expired
        if let user = pool.currentUser() {
            let task = user.getSession().continueWith { (task) in
                if let session = task.result {
                    return AWSTask<CHOauthToken>(result: CHOauthToken(identityProviderCognito, session.idToken!.tokenString))
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

    public func continueLoginSession() {
        CHAccountManager.shared.continueLoginSession(identityProvider: self)
    }

    public func loginCandyhouseWithCurrentLoginSession(callback: @escaping (_ result: CHApiResult) -> Void) {
        CHAccountManager.shared.login(identityProvider: self, result: { (_, result) in
            callback(result)
        })
    }

    public func login(username: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        // step 1: email login -> get idToken
        // step 2: AccountManager: login
        // response: error
        weak var weakSelf = self
        AWSCognitoOAuthService.shared.login(username: username, password: password)
            .then { (result: AWSCognitoIdentityUserSession) -> (Promise<Any>) in
                return Promise.init(resolver: { (seal) in
                    CHAccountManager.shared.login(identityProvider: weakSelf!, result: { (_, apiResult) in
                        if apiResult.success {
                            seal.fulfill(apiResult)
                        } else {
                            let err = NSError(domain: "app_defined", code: 400, userInfo: ["code": apiResult.errorCode!])
                            seal.reject(err as Error)
                        }
                    })
                })
            }.done { (_: Any) -> Void in
                CHAccountManager.shared.deviceManager.flushDevices({(_, apiResult, _) in
                    print("flushDevices \(apiResult.success)")
                })
                completion(nil)
            }.catch { (error) in
                completion(error)
        }
    }

    private func login(username: String, password: String) -> Promise<AWSCognitoIdentityUserSession> {
        pool.clearAll()

        if user.username != username {
            user = pool.getUser(username)
        }

        weak var weakSelf = self
        return Promise.init(resolver: { seal in
            user.getSession(user.username!, password: password as String, validationData: nil).continueWith(executor: AWSExecutor.mainThread(), block: { (task: AWSTask) -> AnyObject? in
                if let error = task.error {
                    seal.reject(error)
                } else {
                    weakSelf!.user.updateDeviceStatus(true).continueOnSuccessWith(block: { (_: AWSTask) -> Any? in
                        return nil
                    })
                    seal.fulfill(task.result!)
                }
                return nil
            })
        })
    }

    public func logout() {
        if let user = pool.currentUser() {
            user.signOut()
        }
        CHAccountManager.shared.logout()
    }
}
