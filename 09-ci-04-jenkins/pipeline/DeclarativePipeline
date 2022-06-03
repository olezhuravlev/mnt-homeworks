pipeline {
    agent {
        label 'linux'
    }
    stages {
        stage('test') {
            steps {
                sh "molecule test -s simple --destroy always"
            }
        }
    }
}
