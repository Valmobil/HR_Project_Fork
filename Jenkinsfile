#!groovy
import groovy.json.JsonSlurperClassic
node {

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def MASTER_USER_CRED_ID = 'hr_management_user_master'
    def MASTER_KEY_CRED_ID = 'hr_management_key_master'
    def CRED_PREFIX = 'hr_management_user_'
    def KEY_PREFIX = 'hr_management_key_'
    def USER_CRED_ID
    def KEY_CRED_ID

    def SFDC_HOST = 'https://login.salesforce.com'
    
    def JWT_KEY_CRED_ID = 'sfdx'
    def JWT_KEY_LOCATION = '/var/lib/jenkins/certificates/hr_management/server.key'

    def ORG_USERNAME = ''
    def CONNECTED_APP_CONSUMER_KEY = ''
    def toolbelt = tool 'toolbelt'


    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    echo 'CHANGE_ID ' + env.CHANGE_ID
    echo 'CHANGE_TARGET ' + env.CHANGE_TARGET
    echo 'BRANCH_NAME ' + env.BRANCH_NAME

    if (env.CHANGE_TARGET != null && env.CHANGE_TARGET != 'master') {
        // if PR to not master
        return;
    } else if (env.CHANGE_TARGET == 'master') {
        // if PR to master
        USER_CRED_ID = MASTER_USER_CRED_ID
        KEY_CRED_ID = MASTER_KEY_CRED_ID
    } else {
        // if commit, not a PR
        USER_CRED_ID = CRED_PREFIX + env.BRANCH_NAME
        KEY_CRED_ID = KEY_PREFIX + env.BRANCH_NAME
    }

    boolean isPrToMaster = env.CHANGE_TARGET == 'master'

    boolean isOrgRelatedBranch = stringCredentialsExist(USER_CRED_ID)
    echo 'isOrgRelatedBranch ' + String.valueOf(isOrgRelatedBranch)

    if (!isOrgRelatedBranch) {
        return
    }

    withCredentials([
                string(credentialsId: USER_CRED_ID, variable: 'USER'),
                string(credentialsId: KEY_CRED_ID, variable: 'KEY'),
                ]) {
            ORG_USERNAME = USER
            CONNECTED_APP_CONSUMER_KEY = KEY
    }

    echo 'USERNAME ' + ORG_USERNAME

    withCredentials([file(credentialsId: JWT_KEY_CRED_ID, variable: 'jwt_key_file')]) {
        
        stage('Deploy To Org') {
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --username ${ORG_USERNAME} --jwtkeyfile ${JWT_KEY_LOCATION} --setdefaultdevhubusername --instanceurl ${SFDC_HOST}"
            if (rc != 0) { error 'hub org authorization failed' }

            if (isPrToMaster) {
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:deploy --checkonly --testlevel RunLocalTests --targetusername ${ORG_USERNAME} -p force-app"
                if (rc != 0) {
                    error 'Validation failed'
                }
            } else {
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:deploy --targetusername ${ORG_USERNAME} -p force-app"
                if (rc != 0) {
                    error 'Deploy failed'
                }
            }
        }

        if (env.BRANCH_NAME == 'master') {
            stage('Run Apex Test') {
                sh "mkdir -p ${RUN_ARTIFACT_DIR}"
                timeout(time: 320, unit: 'SECONDS') {
                    rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat tap --targetusername ${ORG_USERNAME}"
                    if (rc != 0) {
                        error 'apex test run failed'
                    }
                }
            }

            stage('collect results') {
                junit keepLongStdio: true, testResults: 'tests/**/*-junit.xml'
            }
        }
    }
}

boolean stringCredentialsExist(String id) {
    try {
        withCredentials([string(credentialsId: id, variable: 'irrelevant')]) {
            true
        }
    } catch (_) {
        false
    }
}
