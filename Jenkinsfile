pipeline {
agent {
 label 'Jenkins-Agent'
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

  // --- VARIABLES DE DÉPLOIEMENT AWS ---
    SSH_CREDENTIALS_ID = 'aws-ubuntu-ssh-key' // ID de votre clé PEM dans Jenkins
    AWS_INSTANCE_IP   = ':13.60.40.109' // IP de votre EC2 AWS
    AWS_USER          = 'ubuntu' 
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
    withSonarQubeEnv(credentialsId:'jenkins-sonarqube-tokens'){
     sh"mvn sonar:sonar"  
    }
    }
   }
    
   }
   stage ("Quality Gate"){
    steps {
    script {

     waitForQualityGate  abortPipeline : false,credentialsId:'jenkins-sonarqube-tokens'
 
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
                def dockerImage = docker.build(cleanImageName, "-f /home/ubuntu/Dockerfile /home/ubuntu/ ")
                
                // Push des tags
                dockerImage.push("${IMAGE_TAG}")
                dockerImage.push('latest')
            }
        }
    }
}



   stage ("Trivy Scan") {
    steps {
        script {
            sh '''
                mkdir -p $HOME/trivy-tmp
                export TMPDIR=$HOME/trivy-tmp

                # Scan local (si Trivy est installé sur l'agent)
                trivy image --scanners vuln,misconfig erly123/employeemanagementsystem
                
                # Optionnel : ignorer les index Java si nécessaire (sans antislash en fin de commentaire)
                trivy image --skip-java-db-update erly123/employeemanagementsystem

                # Scan via Docker
                docker run --rm \
                    -v /var/run/docker.sock:/var/run/docker.sock \
                    -v $HOME/.cache:/root/.cache/ \
                    aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 erly123/employeemanagementsystem
            '''
        }
    }
}

   // --- NOUVELLE ÉTAPE : DÉPLOIEMENT SUR AWS UBUNTU SUR LE PORT 5173 ---
    stage("Deploy to AWS") {
      steps {
        script {
          def cleanImageName = "${IMAGE_NAME}".toLowerCase().trim()
          
          // Utilisation du plugin SSH Agent pour se connecter à AWS de manière sécurisée
          sshagent([env.SSH_CREDENTIALS_ID]) {
            sh """
            ssh -o StrictHostKeyChecking=no ${AWS_USER}@${AWS_INSTANCE_IP} '
                # 1. Connexion au Docker Hub sur le serveur distant pour récupérer l'image privée (si elle est privée)
                echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin || true
                
                # 2. Récupérer la dernière version de l'image sur le serveur AWS
                # docker pull ${cleanImageName}:latest
                
                # 3. Arrêter et supprimer l'ancien conteneur s'il existe
                docker stop ${APP_NAME} || true
                docker rm ${APP_NAME} || true
                   # 4. Lancer le nouveau conteneur sur le port 5173
                # Le format est -p PORT_EXTERNE:PORT_INTERNE. 
                # Si votre application Java écoute sur le port 8080 dans le conteneur, on fait 5173:8080
                docker run -d --name ${APP_NAME} -p 5173:8080 --restart always ${cleanImageName}:latest
                
                echo "Application déployée avec succès sur le port 5173 !"
              '
            """
            }
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
  

