# raspberrypi3_yocto_docker
raspberrypi3 yocto sdk in docker


## download poky, open-embedded, meta layer
우선, poky와 open embedded, raspberry pi meta layer를 다운 받는다.  
공식 문서에 따르면, poky는 open embedded의 파생버전이고, yocto의 빌드 시스템으로 사용되고 있다고 한다.  
oe-core는 점점 고도화를 거치면서 핵심적인 기능만 남았다고 한다. 
아래 URL을 보면, dunfell브랜치가 비교적 최근까지 패치가 되고 있는 것으로 보인다.  
https://git.yoctoproject.org/meta-raspberrypi  

~~~bash
$ git clone git://git.yoctoproject.org/poky.git -b dunfell
$ cd poky
$ git clone git://git.openembedded.org/meta-openembedded -b dunfell
$ git clone git://git.yoctoproject.org/meta-raspberrypi -b dunfell
~~~

### meta-layer 추가
oe-init-build-env스크립트를 실행한 뒤에 디렉토리 지정을 하지 않으면 default 디렉토리 이름인 build디렉토리를 생성 후 이동된다.  
oe-init-build-env스크립트는 빌드를 위한 환경변수 설정들을 하는 것으로 보인다.  
~~~bash
$ source oe-init-build-env
~~~

Docker컨테이너를 실행해서 사용할 경우, root계정으로 실행되서 에러가 발생해서  
conf/sanity.conf를 생성해주어야한다.  
~~~bash
$ touch conf/sanity.conf
~~~
나중에 docker 컨테이너 실행 옵션을 계정을 만들어서 실행하도록 바꿔보자...  
라즈베리파이를 위해 메타레이어를 추가해야한다.  
기본으로 설치된 메타레이어를 확인해보자.  

~~~bash
$ bitbake-layers show-layers
root@d2c2d6462f96:/workdir/rpi/poky/build# bitbake-layers show-layers
NOTE: Starting bitbake server...
layer                 path                                      priority
==========================================================================
meta                  /workdir/rpi/poky/meta              5
meta-poky             /workdir/rpi/poky/meta-poky         5
meta-yocto-bsp        /workdir/rpi/poky/meta-yocto-bsp    5
~~~
  
poky/meta-raspberrypi/README.md를 보면, dependency가 있는 meta layer들은 아래 4개로 확인된다.  
 - meta-oe
 - meta-multimedia
 - meta-networking
 - meta-python
  
여기에 meta-oe, meta-multimedia, meta-networking, meta-python 레이어를 추가해주어야한다.  
메타레이어를 추가하는 방법은 두 가지가 있다.  
 - conf/bblayers.conf를 수정해서 추가하는 방법
 - bitbake명령을 사용해서 추가하는 방법
bitbake 명령으로 추가해보자...
~~~bash
$ bitbake-layers add-layer ../meta-openembedded/meta-oe
$ bitbake-layers add-layer ../meta-openembedded/meta-python
$ bitbake-layers add-layer ../meta-openembedded/meta-networking
$ bitbake-layers add-layer ../meta-openembedded/meta-multimedia
$ bitbake-layers add-layer ../meta-raspberrypi
~~~

## 타겟 머신 설정 (conf/local.conf)
conf/local.conf를 아래와 같이 수정, 추가한다.  
부팅로그를 보기 위해 UART설정을 추가했다.  
~~~bash
# This sets the default machine to be qemux86 if no other machine is selected:
# MACHINE ??= "qemux86"
MACHINE ??= "raspberrypi3-64"
ENABLE_UART = "1"
~~~

## build
~~~bash
$ bitbake core-image-base
~~~
qemu 관련 에러가 발생한다. qemu 패키지를 설치해줘야한다.  
yocto 공식 커뮤니티에서는 아래처럼 설치하라고 나와있다.  
~~~bash
$ sudo apt-get build-dep qemu
~~~
dockerfile로 image를 빌드할 것이기 때문에 CLI기반의 명령이 필요하다.  
source.list에 deb-src가 있어야한다고 한다.(https://blog.studioego.info/4045)  
CLI로 실행하기 위해서는 아래 URL처럼 sed 명령을 사용하면 된다.  
https://unix.stackexchange.com/questions/158395/apt-get-build-dep-is-unable-to-find-a-source-package
  
Dockerfile에 아래 라인을 추가한다.  
~~~bash
# RUN apt-get build-dep qemu
RUN sed -Ei 's/^# deb-src /deb-src /' /etc/apt/sources.list
RUN apt-get update
~~~  
빌드 성공!.. 이미지를 구워보자...  
  
아래 URL을 주로 참고했다.  
https://docs.yoctoproject.org/3.1.1/ref-manual/ref-manual.html#ubuntu-packages

## firmware download
아래의 wsl디렉토리의 core-image-base-raspberrypi3-64-xxx.rootfs.wic.bz2파일을 sdcard에 복사한다.  
~~~
\\wsl.localhost\Ubuntu\home\rpi\model3_B\pokey\build\tmp\deploy\raspberrypi3-64\core-image-base-raspberrypi3-64-20230128034249.rootfs.wic.bz2
~~~
usb를 꽂고 lsblk커맨드 입력해서 mount된 디바이스 확인한다.  
/dev/sda1이 sdcard로 인식된다.  
  
압축을 풀고 dd  명령으로 sdcard에 이미지를 굽는다.  
~~~bash
$ bzip2 -d -f core-image-base-raspberrypi3-64-xxx.rootfs.wic.bz2
$ sudo dd bs=4M if=core-image-base-raspberrypi3-64-xxx.rootfs.wic of=/dev/sda
$ sync
~~~
  
그대로 raspberry pi에 sdcard를 꽂고 부팅하면,  
bluetooth 로그가 출력되면서 UART로그가 깨져서 출력된다.  
bluetooth가 uart0을 사용하는 듯하다.  
PC에 sdcard를 꽂고 boot디렉토리의 config.txt에 아래 라인을 추가한다.  
~~~bash
dtoverlay=disable-bt
~~~
  
cmdline.txt도 수정해준다.(uart baudrate 수정)  
~~~bash
dwc_otg.lpm_enable=0 console=ttyAMA0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait
~~~