pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "your-dockerhub-username/my-private-repo"
        IMAGE_TAG = "${BUILD_NUMBER}"
        REGISTRY = "https://index.docker.io/v1/"
    }

    triggers {
        // Requires GitHub webhook configured
        githubPush()
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry("${REGISTRY}", "dockerhub-creds") {
                        docker.image("${DOCKER_IMAGE}:${IMAGE_TAG}").push()
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    script {
                        sh """
                        sed -i 's|DOCKER_IMAGE|${DOCKER_IMAGE}:${IMAGE_TAG}|g' k8s/deployment.yaml
                        kubectl apply -f k8s/deployment.yaml
                        """
                    }
                }
            }
        }
    }

    post {
        success {
            echo "Deployment successful!"
        }
        failure {
            echo "Pipeline failed!"
        }
    }
}
