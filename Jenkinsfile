
import groovy.json.JsonSlurper

//  Blazemeter Environment - Workspace / Account
def workspaceID = 348607
def account = 352831

// Blazemeter Mock Service Details
def ServiceID = "144952"
def MockThinkTime = "0"

// Blazemeter Tests - Performance Test ID / Functional Test ID / Functional Test Suite ID
def BMTestID = 10987127
def BMfunctest = 11379990
def BMfuncsuitetest = 10137037

	
pipeline {
   agent any
   stages {
      stage('Development') {
         steps {
            echo 'Extract Build to Develpoment Environment'
            echo 'Prepare Environment - Create Mock Services'
            sh "sed  -i 's/BUILDNUMBER/${BUILD_NUMBER}/g' /var/jenkins_home/workspace/Digital_Bank_Demo_WebSite/demowebsite/finance-update-demo/index.html"
	    sh "sed  -i 's/BUILDNUMBER/${BUILD_NUMBER}/g' /var/jenkins_home/workspace/Digital_Bank_Demo_WebSite/demowebsite/finance-update-demo/contact.html"
	    sh "sed  -i 's/BUILDNUMBER/${BUILD_NUMBER}/g' /var/jenkins_home/workspace/Digital_Bank_Demo_WebSite/demowebsite/finance-update-demo/about.html"
	    sh "/bin/cp -r /home/perfecto/perfecto-test-backup.sh /home/perfecto/perfecto-test.sh"
	    sh "sed  -i 's/BUILD_NUMBER/${BUILD_NUMBER}/g' /home/perfecto/perfecto-test.sh"
		
  	    sshagent(['website']) {
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'whoami'"
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'mkdir /tmp/www'"
		 sh "scp -r /var/jenkins_home/workspace/Digital_Bank_Demo_WebSite/demowebsite/finance-update-demo/* kpuzey@10.128.0.81:/tmp/www "
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'sudo cp -r /tmp/www/* /var/www/html/'"
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'rm -r -f /tmp/www'"
		 sh "'/home/perfecto/perfecto-test.sh'"
	//	 junit skipPublishingChecks: true, testResults: "demowebsite/testresults/${BUILD_NUMBER}-report.xml"
		 junit ${BUILD_NUMBER}-report.xml
             }
            script {
//  Mock Service Definition
	echo "UI Sanity Test - Jenkins Build " + BUILD_NUMBER
 
  def payload = """{ "description": "Jenkins Build $BUILD_NUMBER", "endpointPreference": "HTTPS", "harborId": "605c5c25c2db93377c7bbbf4","type": "TRANSACTIONAL",
  "liveSystemHost": "null", "liveSystemPort": "null", "name": "Jenkins Build $BUILD_NUMBER", "serviceId": ${ServiceID}, "shipId":"62dfc37917224310c4622ca3" ,"thinkTime": ${MockThinkTime},
   "mockServiceTransactions": [{"txnId":4231706,"priority":10},{"txnId":4231707,"priority":10},{"txnId":4231708,"priority":10}]}"""

 // Create Mock Service using payload patchOrg
	       def response = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'POST', requestBody: payload , url: "https://mock.blazemeter.com/api/v1/workspaces/" + workspaceID + "/service-mocks"
               def json = new JsonSlurper().parseText(response.content)
               mockid = json.result.id
               echo "Mock Service IDs: ${json.result.id}"
            }
         echo "Prepare Environment - Start Mock Services - Jenkins Build " + BUILD_NUMBER
            script {
            // Start Mock Service
		    
	    def response = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://mock.blazemeter.com/api/v1/workspaces/" +workspaceID + "/service-mocks/"+ mockid + "/deploy"
            def json = new JsonSlurper().parseText(response.content)
            }
	    script {
            while (true) {
	    sleep 60

	    // Retrieve Status of Mock Service    
	    
	    def response = httpRequest authentication: 'BMCredentials', acceptType: 'APPLICATION_JSON_UTF8', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://mock.blazemeter.com/api/v1/workspaces/" +workspaceID + "/service-mocks/"+ mockid
            def json = new JsonSlurper().parseText(response.content)
            mockendpoint = json.result.httpsEndpoint
            mockstat = json.result.status
            if ( mockstat == 'RUNNING') break
            }
           }  
       echo "Mock Service Jenkins Build " + BUILD_NUMBER + "  Started -  Endpoint details " + mockendpoint
	   echo "Deploy Digital Bank Build" + BUILD_NUMBER + "  to Test Environment"
	   sleep 5
 //          echo "Configuring Digital Banking application with mock service details"
//           script {
	// Start Blazemeter  Performance Test
//	    echo "Start Blazemeter Performance Test "
//		   
//	       def response = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'POST', url: "https://a.blazemeter.com/api/v4/tests/"+BMTestID+"/Start"
//               def json = new JsonSlurper().parseText(response.content)
//               testsessionid = json.result.sessionsId[0]
//	       echo "Test Session ID =  " + testsessionid
//	   }
//	    script {
//            while (true) {
//	    sleep 120
//	    // Check Status of Test    
//	    def response = httpRequest authentication: 'BMCredentials', acceptType: 'APPLICATION_JSON_UTF8', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://a.blazemeter.com:443/api/latest/sessions/"+testsessionid
//	    def json = new JsonSlurper().parseText(response.content)
  //          testthreshold = json.result.failedThresholds
    //        teststat = json.result.status
      //      if ( teststat == 'ENDED') break
        //    }
          //  if (testthreshold == 0 ) {
  //              echo 'Test Passed'
//		testresult = "Blazemeter Performance Test Passed"
  //          } else {
    //            echo 'Test Failed '
//		testresult = "Blazemeter Performance Test Failed"
  //          }  
    //       } 
		 
//script {
// Start Blazemeter Functional Test Suite with Test Data Model
// echo "Define Test Data Model"
// def datamodel = """{"dependencies":{"data":{"kind":"tdm","type":"object",
// "properties":{"FirstName":{"type":"string"},"LastName":{"type":"string"},"EmailAddress":{"type":"string"}},
// "requirements":{"FirstName":"randlov(0,seedlist(\\"firstnames\\"))","LastName":"randlov(0, seedlist(\\"lastnames\\"))","EmailAddress":"(\${FirstName}+\\".\\"+\${LastName}+\\"@gmail.com\\").replace(/ /g,\\".\\")"},"repeat":"5"}}}"""
//
// echo "Start Functional test"
// def dmresponse = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'PUT', requestBody: datamodel , url: "https://a.blazemeter.com/api/v4/tests/"+BMfunctest
//
// }
 
// script {
//            while (true) {
//	    sleep 120
//	    // Check Status of Test    
//	    def response = httpRequest authentication: 'BMCredentials', acceptType: 'APPLICATION_JSON_UTF8', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://a.blazemeter.com:443/api/v4/masters/"+testmasterid+"/status?events=false"
//	    def json = new JsonSlurper().parseText(response.content)
  //          teststat = json.result.status
//	    echo "Test Status = " + teststat
  //          if ( teststat == "ENDED") break
//            }
////	    def response = httpRequest authentication: 'BMCredentials', acceptType: 'APPLICATION_JSON_UTF8', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://a.blazemeter.com:443/api/v4/masters/"+testmasterid+"/full?external=false"    def json = new JsonSlurper().parseText(response.content)
//            projectID = json.result.projectId
//	    testresult = json.result.passed
  //          if (testresult == true ) {
//                echo 'Test Passed'
//		echo "Test details : https://a.blazemeter.com/app/#/accounts/"+account+"/workspaces/"+workspaceID+"/projects/"+projectID+"/masters/"+testmasterid+"/cross-browser-summary"
//		testresult = "Blazemeter Test Passed"
  //          } else {
    //            echo 'Test Failed '
//		"Test details : https://a.blazemeter.com/app/#/accounts/"+account+"/workspaces/"+workspaceID+"/projects/"+projectID+"/masters/"+testmasterid+"/cross-browser-summary"
//		testresult = "Blazemeter Test Failed"
//            }  
  //         }  
//           script {
//	// Start Blazemeter Functional Test Suite
//	    echo "Define Test Data"
//	    def datamodel = """{"dependencies":{"data":{"kind":"tdm","type":"object","properties":{"FirstName":{"type":"string"},"LastName":{"type":"string"},"EmailAddress":{"type":"string"},"SSN":{"type":"string"},"home_phone":{"type":"string"},"mobile_phone":{"type":"string"},"work_phone":{"type":"string"},"index":{"type":"string"},"dob":{"type":"string"},"address":{"type":"string"},"city":{"type":"string"},"state":{"type":"string"},"zip_code":{"type":"string"},"jenkins_build":{"type":"string"}},"requirements":{"FirstName":"randlov(0,seedlist(\\"firstnames\\"))","LastName":"randlov(0, seedlist(\\"lastnames\\"))","EmailAddress":"(\${FirstName}+\\".\\"+\${LastName}+\\"@gmail.com\\").replace(/ /g,\\".\\")","SSN":"randDigits(3,3)+\\"-\\"+randDigits(2,2)+\\"-\\"+randDigits(4,4)","home_phone":"\\"(\\"+randDigits(3,3)+\\")\\"+randDigits(3,3)+\\"-\\"+randDigits(4,4)","mobile_phone":"\\"(\\"+randDigits(3,3)+\\")\\"+randDigits(3,3)+\\"-\\"+randDigits(4,4)","work_phone":"\\"(\\"+randDigits(3,3)+\\")\\"+randDigits(3,3)+\\"-\\"+randDigits(4,4)","index":"randInt(1,100)","jenkins_build":"${BUILD_NUMBER}" ,"dob":"datetime(dateOfBirth(18, 100,now()),\\"MM/DD/YYYY\\")","address":"valueFromSeedlist(\\"usaddress-multicol\\", \${index}, 1)","city":"valueFromSeedlist(\\"usaddress-multicol\\", \${index}, 2) ","state":"valueFromSeedlist(\\"usaddress-multicol\\", \${index}, 3) ","zip_code":"valueFromSeedlist(\\"usaddress-multicol\\", \${index}, 4)"},"repeat":"5"}}}"""
//	    def dmresponse = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'PUT', requestBody: datamodel , url: "https://a.blazemeter.com/api/v4/tests/"+BMfunctest
 	    
//	    echo "Start Blazemeter Functional Test Suite"
//		   
//	     def response = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'POST', url: "https://a.blazemeter.com/api/v4/multi-tests/"+BMfuncsuitetest+"/start"
  //           def json = new JsonSlurper().parseText(response.content)
//             testmasterid = json.result.id
//	   }
//	    script {
  //          while (true) {
//	    sleep 120
	    // Check Status of Test    
//	    def response = httpRequest authentication: 'BMCredentials', acceptType: 'APPLICATION_JSON_UTF8', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://a.blazemeter.com:443/api/v4/masters/"+testmasterid+"/test-suite-summary"
//	    def json = new JsonSlurper().parseText(response.content)
  //          endtime = json.result.suiteSummary.ended
//	    echo "End Time = " + endtime
//            if ( endtime > 0 ) break
 //           }
//	    def suiteresponse = httpRequest authentication: 'BMCredentials', acceptType: 'APPLICATION_JSON_UTF8', contentType: 'APPLICATION_JSON', httpMode: 'GET', url: "https://a.blazemeter.com:443/api/v4/masters/"+testmasterid+"/full?external=false"
//	    def suitejson = new JsonSlurper().parseText(suiteresponse.content)
//            projectID = suitejson.result.projectId
//            testresult = suitejson.result.passed
//            if (testresult == true ) {
//                echo 'Test Passed'
//		echo "Test details : https://a.blazemeter.com/app/#/accounts/"+account+"/workspaces/"+workspaceID+"/projects/"+projectID"+/masters/"+testmasterid+"/suite-report"
//		testresult = "Blazemeter Test Suite Passed"
//            } else {
//                echo 'Test Failed '
//		echo "Test details : https://a.blazemeter.com/app/#/accounts/"+account+"/workspaces/"+workspaceID+"/projects/"+projectID+"/masters/"+testmasterid+"/suite-report"
//		testresult = "Blazemeter Test Suite Failed"
//            }  
//           }  

           script {
            // Define Variable
             def USER_INPUT = input(
                    message: 'Deployment Paused                ', // + testresult,
                    parameters: [
                            [$class: 'ChoiceParameterDefinition',
                             choices: ['Yes','No'].join('\n'),
                             name: 'input',
                             description: 'Do you want to proceed?']
                    ])

            echo "The answer is: ${USER_INPUT}"

            if( "${USER_INPUT}" == "Yes"){
            echo "Deployment Continuing"
            } else {
	    echo "Deployment Cancelled by user input"
       	   script {

	    // Delete Mock Service
		   
	    def response = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'DELETE', url: "https://mock.blazemeter.com/api/v1/workspaces/" +workspaceID + "/service-mocks/"+ mockid
            echo "Deleting Mock Service Jenkins Build " + BUILD_NUMBER
            echo "Reverting website"
		sh "'/home/perfecto/perfecto-test.sh'"
	    sshagent(['website']) {
                 // some block
                 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'whoami'"
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'mkdir /tmp/www'"
		 sh "scp -r /var/jenkins_home/workspace/Digital_Bank_Demo_WebSite/demowebsite/finance-original/* kpuzey@10.128.0.81:/tmp/www "
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'sudo cp -r /tmp/www/* /var/www/html/'"
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'rm -r -f /tmp/www'"
             }
          }
            break
            }
        }
	   script {
            def response = httpRequest authentication: 'BMCredentials', contentType: 'APPLICATION_JSON', httpMode: 'DELETE', url: "https://mock.blazemeter.com/api/v1/workspaces/" +workspaceID + "/service-mocks/"+ mockid
            echo "Reverting website"
	    sshagent(['website']) {
                 // some block
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'whoami'"
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'mkdir /tmp/www'"
		 sh "scp -r /var/jenkins_home/workspace/Digital_Bank_Demo_WebSite/demowebsite/finance-original/* kpuzey@10.128.0.81:/tmp/www "
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'sudo cp -r /tmp/www/* /var/www/html/'"
		 sh "ssh -o StrictHostKeyChecking=no -l kpuzey 10.128.0.81 'rm -r -f /tmp/www'"
	    }
           echo "Deleting Mock Service Jenkins Build " + BUILD_NUMBER
            }
           }
          }
         stage('QA') {
         steps {
            echo 'Deploy Build to QA Environment'
         }
      }
	stage('UAT') {
         steps {
            echo 'Deploy Build to QA Environment'
         }
      }
     }
 }

