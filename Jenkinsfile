node {
    def SOURCEDIR = pwd()
    try {
        stage("Clean up") {
            step([$class: 'WsCleanup'])
        }
        stage("Checkout Code") {
            checkout scm
        }
        stage("Run the cUrl Examples") {
            withEnv(["API_KEY=${env.ROSETTE_API_KEY}", "ALT_URL=${env.BINDING_TEST_URL}"]) {
                sh "./run-examples.sh -a API_KEY=${API_KEY} -u ALT_URL=${ALT_URL}"
            }
        }
        slack(true)
    } catch (e) {
        currentBuild.result = "FAILED"
        slack(false)
        throw e
    }
}

def slack(boolean success) {
    def color = success ? "#00FF00" : "#FF0000"
    def status = success ? "SUCCESSFUL" : "FAILED"
    def message = status + ": Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]' (${env.BUILD_URL})"
    slackSend(color: color, channel: "#rapid", message: message)
}