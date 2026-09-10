pipeline {
agent {
 label 'Jenkins-Slave'
}
  tools {
    jdk 'JDK21'
    maven 'Maven3'
        }
 environment {
 APP_NAME="EmployeeManagementSystem"
 RELEASE= "1.0.0"
 DOCKER_USER= "Erly123"
 DOCKER_PASS='dockerhub'
 IMAGE_NAME="${ DOCKER_USER}"+"/"+"${APP_NAME}" 
 IMAGE_TAG="${RELEASE}-${BUILD_NUMBER}"
 }
  stages{
  stage ("Cleanup Workspace"){
  steps{
  cleanWs()
  }
 
  }
    stage ("Checkout from SCM"){
    steps{
    git branch :'main',credentialsId: 'Github',url:'https://github.com/Binguiyolo/devops-app/'
    }  
    }
    stage ("Build Application"){
    steps{
    sh "mvn clean package"
    }
    }
    stage ("Test Application"){
    steps{
    sh "mvn test"
        }
       }
   stage ('Sonarqube Analysis'){
   steps{
    script {
    withSonarQubeEnv(credentialsId:'Jenkins-Sonar-Tokens'){
     sh"mvn sonar:sonar" 
    }
    }
   }
    
   }
   stage ("Quality Gate"){
    steps {
    script {

     waitForQualityGate  abortPipeline : false,'Sonarqube-Server'
     def qg = waitForQualityGate()
      if (qg.status != 'OK') {
                    error "Pipeline aborti en raison de l'échec du Quality Gate: ${qg.status}"
    }
    }
   }
   }
  
  stage ("Build & Push Docker Image"){
   steps {

    script{
     docker.withRegistry('',DOCKER_PASS){
     docker_image = docker.build "${IMAGE_NAME}"
     }
     docker.withRegistry('',DOCKER_PASS){
     docker_image.push("${IMAGE_TAG}")
     docker_image.push('latest')
     }
    }
   }
  }
   stage ("Trivy Scan"){
    steps{
    script{
     sh('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image Erly123/EmployeeManagementSystem:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGHT, CRITICAL --format table')
    }
   }
   }
  
 stage ('Cleanup Artifacts'){
 steps {
  script {
  sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
   sh "docker rmi ${IMAGE_NAME}:latest"
  }
 }
 }
}
}
  

