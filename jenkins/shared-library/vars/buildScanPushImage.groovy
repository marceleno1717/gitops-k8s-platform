def call(String imageName, String dockerCreds) {
    sh "docker build -t ${imageName} ."

    sh "trivy image --severity HIGH,CRITICAL --exit-code 0 ${imageName}"

    withCredentials([usernamePassword(credentialsId: dockerCreds, usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
        sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
        sh "docker push ${imageName}"
    }

    sh "docker rmi ${imageName}"
}
