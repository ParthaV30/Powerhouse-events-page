pipeline {
    agent any

    environment {
        IMAGE_NAME = "powerhouse"
        IMAGE_TAG = "latest"
        DOCKERHUB_USER = "heisenbergzz"    // Change this to your Docker Hub username
        CONTAINER_NAME = "powerhouse-container"
        EC2_IP = "107.20.108.153"
    }

    triggers {
        // Trigger build automatically when a push is made to the GitHub repo
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Cloning the repository..."
                git branch: 'main', url: 'https://github.com/ParthaV30/Powerhouse-events-page.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "sudo docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    echo "Logging into Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh "echo $PASSWORD | sudo docker login -u $USERNAME --password-stdin"
                    }
                    sh "sudo docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "sudo docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Deploying new container on EC2..."

                    // Stop and remove old container if exists
                    sh """
                        sudo docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && \
                        sudo docker stop ${CONTAINER_NAME} && sudo docker rm ${CONTAINER_NAME} || echo 'No old container running'
                    """

                    // Run the new version
                    sh "sudo docker run -d -p 80:80 --name ${CONTAINER_NAME} ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Live at: http://${EC2_IP}"
        }
        failure {
            echo "❌ Build or Deployment failed. Check logs."
        }
    }
}

