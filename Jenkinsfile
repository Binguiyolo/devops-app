pipeline {
agent {
 label 'Jenkins-Slave'
}
  tools {
    jdk 'JDK21'
    maven 'Maven3'
    
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
   stage ('Quality Gate'){
    steps {
    script {
     waitForQualityGate abortPipeline : false,credentialsId:'Jenkins-Sonarqube-Tokens'
    }
    }
   }
  }
}
