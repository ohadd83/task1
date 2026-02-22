pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "ohadd306/temp"
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
    stage('Deploy') { 
        when {
            branch 'main'
        }
        steps {
            echo "Deploying to production..."
        }
      }    

    stage('Build Docker Image') {
        steps {
            // We use sh instead of the docker variable
            sh "docker build -t ${DOCKER_IMAGE}:${IMAGE_TAG} ."
        }
   }            


    stage('Push to DockerHub') {
        steps {
            // This safely injects your DockerHub username and password from the 'dockerhub-creds' ID
            withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', passwordVariable: 'DOCKER_PASSWORD', usernameVariable: 'DOCKER_USERNAME')]) {
                sh "echo \$DOCKER_PASSWORD | docker login -u \$DOCKER_USERNAME --password-stdin"
                sh "docker push ${DOCKER_IMAGE}:${IMAGE_TAG}"
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
