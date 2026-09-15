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
  
     
stage("Build and Push Docker Image") {
    steps {
        script {
            // Nettoyage du nom de l'image
            def cleanImageName = "${IMAGE_NAME}".toLowerCase().trim()
            
            // Connexion au Registre Docker et exécution du Build/Push
            docker.withRegistry('', DOCKER_PASS) {
                
                // On spécifie le chemin absolu du Dockerfile avec l'option -f 
                // Le "." à la fin définit le contexte de build (le workspace actuel)
                def dockerImage = docker.build(cleanImageName, "-f /home/ubuntu/devops-app/Dockerfile /home/ubuntu/devops-app ")
                
                // Push des tags
                dockerImage.push("${IMAGE_TAG}")
                dockerImage.push('latest')
            }
        }
    }
}



   stage ("Trivy Scan"){
    steps{
    script{
    sh '''
                        docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        -v $HOME/.cache:/root/.cache/ \
                        aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 erly123/employeemanagementsystem
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
  

