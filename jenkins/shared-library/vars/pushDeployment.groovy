def call(String imageName, String newTag, String deploymentFile, String githubCreds, String email, String repoUrl) {
    def repo = repoUrl.replaceFirst('^https://', '')

    withCredentials([
        usernamePassword(credentialsId: githubCreds, usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_PASSWORD')
    ]) {
        sh """
            sed -i 's|image: ${imageName}:.*|image: ${imageName}:${newTag}|' ${deploymentFile}
            echo "Pushing updated deployment manifest to ${repo}..."

            git config user.email "${email}"
            git config user.name "${GITHUB_USERNAME}"

            git add ${deploymentFile}
            git commit -m "chore(gitops): update ${imageName} image tag to ${newTag} [skip ci]"

            git push https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@${repo} HEAD:main
        """
    }
}
