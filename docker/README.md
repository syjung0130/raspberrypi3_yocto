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
