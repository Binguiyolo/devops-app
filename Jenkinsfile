pipeline {
agent {
 label 'Jenkins-Slave'
}
  tools {
    jdk 'JDK21'
    maven 'MAVEN3'
    
        }
  stages{
  stage ("Cleanup Workspace"){
  steps{
  cleanWs()
  }
 
  }
    stage ("Checkout from SCM"){
    steps{
    git branch :'main',credentialsId: 'github',url:'https://github.com/Binguiyolo/devops-app/'
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
  }
}
