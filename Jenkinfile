pipeline {
    agent any

    environment {
        // 1. Harbor 및 이미지 정보
        HARBOR_URL       = "shkch.duckdns.org"
        HARBOR_PROJECT   = "ptlog"      // Harbor 프로젝트 명 (필요시 수정)
        HARBOR_CREDS_ID  = "harbor-creds"
        IMAGE_NAME       = "ptlog"          // ptlog 이미지 이름
        
        // 2. Kubernetes 배포 정보
        KUBE_CREDS_ID    = "kubeconfig-creds"
        NAMESPACE        = "default"        // 배포할 네임스페이스
        DEPLOYMENT_NAME  = "ptlog-web"      // k8s/deployment.yaml의 metadata.name과 일치해야 함
        
        // 3. SSH 터널링 정보 (제공해주신 정보 유지)
        K8S_USER         = "server4"
        SSH_HOST         = "sangsu02.iptime.org"
        K8S_TARGET_IP    = "192.168.0.10"
        K8S_PORT         = "6443"
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Define Image Tag') {
            steps {
                script {
                    // Git Short Commit Hash를 태그로 사용
                    env.IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short=8 HEAD').trim()
                    echo "Using Image Tag: ${env.IMAGE_TAG}"
                }
            }
        }

        stage('Build & Push Image') {
            steps {
                // Harbor 로그인
                withCredentials([usernamePassword(credentialsId: env.HARBOR_CREDS_ID, usernameVariable: 'HARBOR_USER', passwordVariable: 'HARBOR_PASS')]) {
                    sh "docker login ${env.HARBOR_URL} -u ${HARBOR_USER} -p '${HARBOR_PASS}'" 
                }

                echo "Building Ptlog (Flutter Web) Image..."
                // ptlog는 루트에 Dockerfile이 있으므로 dir() 블록 없이 바로 빌드
                script {
                    def fullImageName = "${env.HARBOR_URL}/${env.HARBOR_PROJECT}/${env.IMAGE_NAME}:${env.IMAGE_TAG}"
                    def latestImageName = "${env.HARBOR_URL}/${env.HARBOR_PROJECT}/${env.IMAGE_NAME}:latest"
                    
                    // 빌드 (Dockerfile이 프로젝트 루트에 있어야 함)
                    sh "docker build -t ${fullImageName} ."
                    
                    // 푸시 (태그 버전 & latest 버전)
                    sh "docker push ${fullImageName}"
                    
                    // Latest 태그 추가 및 푸시 (선택사항)
                    sh "docker tag ${fullImageName} ${latestImageName}"
                    sh "docker push ${latestImageName}"
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    def localPort = 8888 
                    def KUBECONFIG_PATH

                    // 1. SSH 터널 시작
                    sshagent(['k8s-master-ssh-key']) { // Jenkins에 등록된 SSH Key ID 확인 필요
                        
                        // 터널 백그라운드 실행
                        sh "nohup ssh -o StrictHostKeyChecking=no -N -L ${localPort}:${env.K8S_TARGET_IP}:${env.K8S_PORT} ${env.K8S_USER}@${env.SSH_HOST} > /dev/null 2>&1 & echo \$! > tunnel.pid"
                        
                        def tunnelPid = readFile('tunnel.pid').trim()
                        sleep 5 // 터널 안정화 대기

                        // 2. Kubeconfig 설정 및 배포
                        withCredentials([file(credentialsId: env.KUBE_CREDS_ID, variable: 'KUBECONFIG_FILE')]) {
                            
                            // 로컬 포트로 API 서버 주소 변경
                            sh "sed -i 's|server:.*|server: https://127.0.0.1:${localPort}|g' ${KUBECONFIG_FILE} || true" 
                            KUBECONFIG_PATH = env.KUBECONFIG_FILE
                            
                            dir('k8s') {
                                // 이미지 태그 교체 (Kustomize가 없어도 sed로 처리 가능)
                                // deployment.yaml 파일 내의 image: 부분을 찾아 새 태그로 변경
                                sh """
                                sed -i 's|image: ${env.HARBOR_URL}/${env.HARBOR_PROJECT}/${env.IMAGE_NAME}:.*|image: ${env.HARBOR_URL}/${env.HARBOR_PROJECT}/${env.IMAGE_NAME}:${env.IMAGE_TAG}|' deployment.yaml
                                """

                                // 변경된 내용 확인 (디버깅용)
                                sh "cat deployment.yaml | grep image:"

                                // Apply
                                sh "KUBECONFIG=${KUBECONFIG_PATH} kubectl apply -f deployment.yaml || true" 
                                
                                // 강제 롤아웃 (이미지가 같더라도 재시작하려면 필요, 태그가 바뀌면 자동으로 됨)
                                sh "KUBECONFIG=${KUBECONFIG_PATH} kubectl rollout restart deployment ${env.DEPLOYMENT_NAME} -n ${env.NAMESPACE} || true"
                            }
                        }
                        
                        // 3. 터널 종료
                        sh "kill ${tunnelPid} || true" 
                        sh "rm -f tunnel.pid || true"
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker logout ${env.HARBOR_URL} || true"
            // 혹시 남아있을 수 있는 터널 프로세스 정리
            sh "rm -f tunnel.pid || true"
        }
    }
}