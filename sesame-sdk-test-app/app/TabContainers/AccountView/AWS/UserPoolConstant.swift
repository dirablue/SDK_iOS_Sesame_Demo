//
//  UserPoolConstant.swift
//  sesame-sdk-test-app
//
//  Created by tse on 2019/12/19.
//  Copyright © 2019 Cerberus. All rights reserved.
//
import AWSCognitoIdentityProvider.AWSCognitoIdentityUserPool

let CognitoIdentityUserPoolRegion: AWSRegionType = .USEast1
let CognitoIdentityUserPoolId = "us-east-1_69JF5fktv"
let CognitoIdentityUserPoolAppClientId = "21v9tlqp4qtjbau7k1epb15n8f"
let CognitoIdentityUserPoolAppClientSecret = "1k1ni8bnjifjpsl2pg9n2061ln7ja1hdan2ptkdu7b5ups44ud8d"
let AWSCognitoUserPoolsSignInProviderKey = "UserPool"
let identityProviderCognito = "cognito-idp.us-east-1.amazonaws.com/\(CognitoIdentityUserPoolId)"
