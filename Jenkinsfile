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
 DOCKER_PASS="Yeshua_4me"
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
    withSonarQubeEnv(credentialsID:'Jenkins-Sonarqube-Tokens'){
     sh'mvn clean verify  sonar:sonar'
    }
    }
   }
    
   }
   stage ("Quality Gate"){
    steps {
    script {
     waitForQualityGate  abortPipeline : false,credentialsId:'Jenkins-Sonarqube-Tokens'
    }
    }
   }
  stage ("Build & Push Docker Image"){
   steps {

    script{
     docker.withRegistry('',DOCKER_PASS){
     docker.image = docker.build "${IMAGE_NAME}"
     }
     docker.withRegistry('',DOCKER_PASS){
     docker_image.push("${IMAGE_TAG}")
     docker_image.push('latest')
     }
    }
   }
  }
  }
}
