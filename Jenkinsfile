#!/usr/bin/env groovy
pipeline {
    agent any
       triggers {
        pollSCM "* * * * *"
       }
    stages {
        stage('Build Container') { 
            steps {
                echo '=== Building Deployment Docker Container ==='
                sh 'make build-test' 
            }
        }
        stage('Initialize') {
            steps {
                echo '=== Linting and Validating Sample Product Terraform ==='
                sh 'make init'
            }
        }
        stage('Unit Test') {
            steps {
                echo '=== Plan Sample Product Terraform ==='
                sh 'make plan'
            }
        }
        stage('Validation') {
            steps {
                echo '=== Validating Plan Sample Product Terraform ==='
                sh 'make validate'
            }
        }
        stage('Deploy') {
            when {
                branch 'master'
            }
            steps {
                echo '=== Deploy Sample Product ==='
                sh 'make deploy'
            }
        }
        stage('Deliver') {
            when {
                branch 'master'
            }
            steps {
                echo '=== Pushing Sample EKS Cluster Docker Image ==='
                script {
                    sh 'aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 440766640997.dkr.ecr.us-west-2.amazonaws.com'
                    sh 'docker tag gpn-team-force-cluster-autoscaler:test 440766640997.dkr.ecr.us-east-2.amazonaws.com/gpn-team-force-cluster-autoscaler:latest'
                    sh 'docker push 440766640997.dkr.ecr.us-east-2.amazonaws.com/gpn-team-force-cluster-autoscaler:latest'
                }
            }
        }
        stage('Clean-Up') {
            steps {
                echo '=== Delete the Sample Product Docker Images Locally ==='
                sh("docker rmi -f gpn-team-force-demo-eks-cluster:test || :")
            }
        }
    }
}
