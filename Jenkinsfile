pipeline {
agent {
 label 'Jenkins-Slave'
}
  tools {
    jdk 'JDK21'
    maven 'Maven3'
        }
 environment {
 APP_NAME="employeemanagementsystem"
 RELEASE= "1.0.0"
 DOCKER_USER= "erly123"
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
    withSonarQubeEnv(credentialsId:'Jenkins-Sonarqube-Tokens'){
     sh"mvn sonar:sonar"  
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
  
     
 stage ("Build & Push Docker Image") {
    steps {
        script {
            // Étape de diagnostic : affiche le dossier actuel et son contenu dans les logs Jenkins
            sh "pwd"
            sh "ls -la"
            
            docker.withRegistry('', DOCKER_PASS) {
                def cleanImageName = "${IMAGE_NAME}".toLowerCase().trim()
                
                // Build direct
                docker build -t "$JD_IMAGE" -f home/ubuntu/devops-app/Dockerfile .

                docker_image = docker.build(cleanImageName, ".")
                
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
  

