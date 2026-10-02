pipeline {
    agent {
        label 'Jenkins-Agent'
    }
    
    tools {
        jdk 'java21'
        maven 'Maven3'
    }
    
    environment {
        APP_NAME           = "employeemanagementsystem"
        RELEASE            = "1.0.0"
        DOCKER_USER        = "erly123"
        DOCKER_PASS        = 'dockerhub'
        IMAGE_NAME         = "${DOCKER_USER}/${APP_NAME}" 
        IMAGE_TAG          = "${RELEASE}-${BUILD_NUMBER}"

        // --- VARIABLES DE DÉPLOIEMENT AWS ---
        SSH_CREDENTIALS_ID = 'aws-ubuntu-ssh-key' // ID de votre clé PEM dans Jenkins
        AWS_INSTANCE_IP    = '13.60.40.13'       // IP de votre EC2 AWS
        AWS_USER           = 'ubuntu' 
    }
    
    stages {
        stage("Cleanup Workspace") {
            steps {
                cleanWs()
            }
        }
        
        stage("Checkout from SCM") {
            steps {
                git branch: 'main', credentialsId: 'Github', url: 'https://github.com/Binguiyolo/devops-app/'
            }  
        }
        
        stage("Build Application") {
            steps {
                sh "mvn clean package"
            }
        }
        
        stage("Test Application") {
            steps {
                sh "mvn test"
            }
        }
        
        stage('Sonarqube Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-tokens') {
                        sh "mvn sonar:sonar"  
                    }
                }
            }
        }
        
        stage("Quality Gate") {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'jenkins-sonarqube-tokens'
                }
            }
        }
        
        stage("Build and Push Docker Image") {
            steps {
                script {
                    def cleanImageName = "${IMAGE_NAME}".toLowerCase().trim()
                    
                    // Laissez l'URL vide ('') pour Docker Hub, 'dockerhub' est l'ID de vos credentials Jenkins
                    docker.withRegistry('', 'dockerhub') {
                        // Le point "." indique que le build s'exécute dans le workspace Jenkins actuel
                        def dockerImage = docker.build(cleanImageName, ".")
                        
                        // Push des tags
                        dockerImage.push("${IMAGE_TAG}")
                        dockerImage.push('latest')
                    }
                }
            }
        }

        stage("Trivy Scan") {
            steps {
                script {
                    def cleanImageName = "${IMAGE_NAME}".toLowerCase().trim()
                    
                    sh """
                        mkdir -p \$HOME/trivy-tmp
                        export TMPDIR=\$HOME/trivy-tmp

                        docker run --rm \
                            -v /var/run/docker.sock:/var/run/docker.sock \
                            -v \$HOME/.cache:/root/.cache/ \
                            aquasec/trivy:latest image --severity HIGH,CRITICAL --exit-code 0 ${cleanImageName}:${IMAGE_TAG}
                    """
                }
            }
        }
        
        stage('Deploy to Server') {
            steps {
                // Utilisation recommandée de sshagent pour charger proprement votre clé 'aws-ubuntu-ssh-key'
                sshagent([ "${SSH_CREDENTIALS_ID}" ]) {
                    sh """
                        ssh -o StrictHostKeyChecking=no ${AWS_USER}@${AWS_INSTANCE_IP} << 'EOF'
                            # 1. Connexion à Docker Hub
                            echo "dockerhub" | docker login -u "erly123" --password-stdin || true

                            # 2. Récupérer la dernière image
                            docker pull erly123/employeemanagementsystem:latest

                            # 3. Nettoyer l'ancien conteneur s'il existe
                            docker stop employeemanagementsystem || true
                            docker rm employeemanagementsystem || true

                            # 4. Lancer le nouveau conteneur
                            docker run -d --name employeemanagementsystem -p 5173:8080 --restart always erly123/employeemanagementsystem:latest

                            # 5. Vérification
                            echo "Vérification du conteneur sur le serveur distant :"
                            docker ps -a
EOF
                    """
                }
            }
        }
      
        stage('Cleanup Artifacts') {
            steps {
                script {
                    // Passage en minuscules pour correspondre au format généré par docker.build
                    def cleanImageName = "${IMAGE_NAME}".toLowerCase().trim()
                    sh "docker rmi ${cleanImageName}:${IMAGE_TAG} || true"
                    sh "docker rmi ${cleanImageName}:latest || true"
                }
            }
        }
    }
}

  

