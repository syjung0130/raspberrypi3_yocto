# Docker install
https://docs.docker.com/engine/install/ubuntu/
~~~
$sudo apt-get install docker.io
$sudo chmod 666 /var/run/docker.sock
$sudo chown root:docker /var/run/docker.sock
$sudo docker login -u "your id"
~~~

# Docker build  
 - cd docker
 - docker build -t rpi:imx-1 .

# docker image 조회
 - docker images

# Run Docker container 
 - docker run -it --volume="$PWD/..:/workdir/rpi" raspi:imx-1

# 또는 스크립트 실행
 - ./run_container.sh

# 참고(docker install, sdk build시에 발생한 에러로 인해 추가한 부분)
-----------------------------------------
## docker 설치 후 /var/run/docker.sock의 permission denied가 발생하는 경우
occidere commented on Oct 20, 2019 •  
docker 설치 후 /var/run/docker.sock의 permission denied 발생하는 경우  
 - 상황  
  ~~~
  docker 설치 후 usermod로 사용자를 docker 그룹에 추가까지 완료 후 터미널 재접속까지 했으나 permission denied 발생
  (설치 참고: https://blog.naver.com/occidere/221390946271)
  DEV-[occiderepi301:/home/occidere] docker ps -a
  Got permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get http://%2Fvar%2Frun%2Fdocker.sock/v1.40/containers/json?all=1: dial unix /var/run/docker.sock: connect: permission denied
  ~~~
  
 - 해결  
  ~~~
  ##/var/run/docker.sock 파일의 권한을 666으로 변경하여 그룹 내 다른 사용자도 접근 가능하게 변경
  $sudo chmod 666 /var/run/docker.sock
  ##또는 chown 으로 group ownership 변경
  $sudo chown root:docker /var/run/docker.sock
  ~~~
