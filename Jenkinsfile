pipeline {
    agent any

    environment {
        IMAGE_NAME = "powerhouse"
        IMAGE_TAG = "latest"
        DOCKERHUB_USER = "heisenbergzz"
        DEV_CONTAINER = "powerhouse-dev"
        PROD_CONTAINER = "powerhouse-prod"
        DEV_PORT = 8080
        PROD_PORT = 80
        DEV_EC2_IP = "107.20.108.153"    // Dev EC2 or same server, different port
        PROD_EC2_IP = "107.20.108.153"   // Prod EC2 or main server
    }

    triggers {
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
                        sh "echo \$PASSWORD | docker login -u \$USERNAME --password-stdin"
                    }
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy to Dev') {
            when {
                branch 'dev'
            }
            steps {
                script {
                    echo "Deploying to Dev container..."
                    // Stop old dev container if exists
                    sh """
                        docker rm -f ${DEV_CONTAINER} || echo 'No old dev container'
                        docker run -d -p ${DEV_PORT}:80 --name ${DEV_CONTAINER} ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                    """
                    // Health check
                    sh "sleep 10" // give container time to start
                    sh "curl -f http://${DEV_EC2_IP}:${DEV_PORT} || exit 1"
                }
            }
        }

        stage('Deploy to Prod') {
            when {
                branch 'main'
            }
            steps {
                script {
                    echo "Deploying to Prod container..."
                    // Run new container temporarily on PROD_PORT+1 to test
                    sh """
                        TEMP_PORT=8081
                        docker run -d -p \$TEMP_PORT:80 --name ${PROD_CONTAINER}-new ${DOCKERHUB_USER}/${IMAGE_NAME}:${IMAGE_TAG}
                        sleep 10
                        curl -f http://${PROD_EC2_IP}:\$TEMP_PORT || { echo 'Health check failed'; docker rm -f ${PROD_CONTAINER}-new; exit 1; }
                        docker rm -f ${PROD_CONTAINER} || echo 'No old prod container'
                        docker rename ${PROD_CONTAINER}-new ${PROD_CONTAINER}
                    """
                }
            }
        }
    }

    post {
        success {
            echo "✅ Deployment successful!"
        }
        failure {
            echo "❌ Build or deployment failed. Check console logs."
        }
    }
}
