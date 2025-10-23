pipeline {
    agent any

    environment {
        IMAGE_NAME = "powerhouse"
        IMAGE_TAG = "latest"
        DOCKERHUB_USER = "heisenbergzz"       // your Docker Hub username
        CONTAINER_NAME = "powerhouse-container"
        EC2_IP = "107.20.108.153"             // your EC2 public IP
    }

    triggers {
        // Trigger pipeline automatically on GitHub push
        githubPush()
    }

    stages {
        stage('Checkout Code') {
            steps {
                echo "Cloning repository..."
                git branch: 'main', url: 'https://github.com/ParthaV30/Powerhouse-events-page.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Push Docker Image to Docker Hub') {
            steps {
                script {
                    echo "Logging into Docker Hub..."
                    withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                        sh "echo $PASSWORD | docker login -u $USERNAME --password-stdin"
                    }
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to EC2') {
            steps {
                script {
                    echo "Deploying container on EC2..."

                    // Stop and remove old container if exists
                    sh """
                        docker ps -q --filter name=${CONTAINER_NAME} | grep -q . && \
                        docker stop ${CONTAINER_NAME} && docker rm ${CONTAINER_NAME} || \
                        echo 'No old container to remove'
                    """

                    // Run the new container
                    sh "docker run -d -p 80:80 --name ${CONTAINER_NAME} ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful! Your site is live at http://${EC2_IP}"
        }
        failure {
            echo "❌ Build or deployment failed. Check the console logs for details."
        }
    }
}
