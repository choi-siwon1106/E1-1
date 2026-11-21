# E1-1 개발 워크스테이션 구축

터미널(리눅스 CLI), Docker, Git/GitHub를 직접 설치하고 설정해 보면서 "내 컴퓨터에서만 되는 환경"이 아니라 누가 해도 같은 결과가 나오는 개발 환경을 만들어 보는 과제이다. 모든 작업은 터미널에서 했고, 실행한 명령어와 출력 결과를 그대로 정리했다.

## 1. 프로젝트 개요

- 터미널로 폴더를 만들고 파일 권한을 바꿔 본다.
- Docker를 설치하고 컨테이너를 실행/관리한다.
- nginx 베이스 이미지로 웹 서버 이미지를 직접 만든다 (Dockerfile 직접 작성).
- 포트 매핑, 바인드 마운트, 볼륨을 설정하고 동작을 확인한다.
- Git 설정과 GitHub 연동을 한다.

## 2. 실행 환경

| 항목 | 내용 |
|---|---|
| 호스트 OS | Windows 11 Home |
| 실습 환경 | WSL2 Ubuntu 26.04.1 LTS |
| Shell | bash 5.3.9 |
| Docker | 29.9.2 (Docker Desktop 4.97.0, WSL2 백엔드) |
| Git | 2.53.0 (Ubuntu) |
| 에디터 | VS Code 1.142.0 |

서울캠퍼스 안내에는 OrbStack을 쓰라고 되어 있는데, OrbStack은 macOS 전용이라 내 Windows PC에서는 쓸 수 없었다. 대신 WSL2 + Docker Desktop을 썼고, 터미널에서 쓰는 `docker` 명령은 똑같다.

```bash
$ cat /etc/os-release | head -4
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
VERSION_ID="26.04"
VERSION="26.04.1 LTS (Resolute Raccoon)"

$ echo $SHELL
/bin/bash

$ bash --version | head -1
GNU bash, version 5.3.9(1)-release (x86_64-pc-linux-gnu)

$ docker --version
Docker version 29.9.2, build a82e528

$ git --version
git version 2.53.0
```

```powershell
PS> wsl -l -v
  NAME              STATE           VERSION
* Ubuntu            Running         2
  docker-desktop    Running         2
```

## 3. 수행 체크리스트

- [x] 터미널 기본 조작 및 폴더 구성
- [x] 권한 변경 실습 (파일 1개 + 디렉토리 1개)
- [x] Docker 설치/점검
- [x] Docker 기본 운영 명령 (pull / images / ps / logs / stats)
- [x] hello-world 실행
- [x] ubuntu 컨테이너 실행 + attach/exec 비교
- [x] Dockerfile 작성, 빌드, 실행
- [x] 포트 매핑 접속 (8080, 8081 두 번)
- [x] 바인드 마운트 반영 확인
- [x] 볼륨 영속성 확인
- [x] Git 사용자 정보 / 기본 브랜치 설정
- [ ] VS Code GitHub 로그인 + 저장소 연동 (스크린샷 필요)
- [ ] 브라우저 접속 스크린샷 (주소창 포함)

## 4. 수행 로그

### 4-1. 터미널 조작

작업 폴더는 OneDrive 안이 아니라 WSL 홈(`~/codyssey/practice`)에 만들었다.

```bash
$ pwd
/home/user

$ mkdir -p ~/codyssey/practice
$ cd ~/codyssey/practice
$ pwd
/home/user/codyssey/practice

$ touch hello.txt
$ echo "hello docker" > hello.txt
$ cat hello.txt
hello docker

$ mkdir backup
$ cp hello.txt backup/hello_copy.txt
$ mv hello.txt greeting.txt

$ touch .hidden_note
$ ls -la
total 16
drwxr-xr-x 3 user user 4096 Nov  5 13:58 .
drwxr-xr-x 3 user user 4096 Nov  5 13:57 ..
-rw-r--r-- 1 user user    0 Nov  5 13:58 .hidden_note
drwxr-xr-x 2 user user 4096 Nov  5 13:57 backup
-rw-r--r-- 1 user user   13 Nov  5 13:57 greeting.txt

$ ls -la backup
-rw-r--r-- 1 user user   13 Nov  5 13:57 hello_copy.txt

$ rm backup/hello_copy.txt
$ ls -la backup
total 8
drwxr-xr-x 2 user user 4096 Nov  5 13:57 .
drwxr-xr-x 3 user user 4096 Nov  5 13:57 ..

$ cd ..
$ pwd
/home/user/codyssey
```

| 동작 | 명령 |
|---|---|
| 현재 위치 | `pwd` |
| 목록 (숨김 포함) | `ls -la` |
| 이동 | `cd` |
| 생성 | `mkdir` |
| 복사 | `cp` |
| 이동/이름변경 | `mv` |
| 삭제 | `rm` |
| 내용 확인 | `cat` |
| 빈 파일 생성 | `touch` |

`ls`만 치면 안 보이던 `.hidden_note`가 `-a` 옵션을 붙이니까 보였다. 점(`.`)으로 시작하는 파일이 숨김 파일이다.

### 4-2. 권한 실습

```bash
# 파일: 변경 전
$ ls -l greeting.txt
-rw-r--r-- 1 user user 13 Nov  5 13:57 greeting.txt

$ chmod 600 greeting.txt
$ ls -l greeting.txt
-rw------- 1 user user 13 Nov  5 13:57 greeting.txt

$ chmod 755 greeting.txt
$ ls -l greeting.txt
-rwxr-xr-x 1 user user 13 Nov  5 13:57 greeting.txt

# 디렉토리: 변경 전
$ ls -ld backup
drwxr-xr-x 2 user user 4096 Nov  5 13:57 backup

$ chmod 700 backup
$ ls -ld backup
drwx------ 2 user user 4096 Nov  5 13:57 backup

# 원래대로 복구
$ chmod 755 backup
$ chmod 644 greeting.txt
```

| 대상 | 변경 전 | 변경 후 |
|---|---|---|
| 파일 `greeting.txt` | `-rw-r--r--` (644) | `-rw-------` (600), 다시 `-rwxr-xr-x` (755) |
| 디렉토리 `backup` | `drwxr-xr-x` (755) | `drwx------` (700) |

**절대 경로와 상대 경로**
- 절대 경로는 맨 위 `/`부터 적는 경로라서 어디에서 실행해도 같은 곳을 가리킨다. 예: `/home/user/codyssey/practice`
- 상대 경로는 지금 있는 위치를 기준으로 적는다. `practice` 폴더에 있을 때 `./backup`은 `practice/backup`이고, `cd ../..`는 `/home/user`로 올라간다.

**권한 r/w/x와 755, 644**
- r(읽기)=4, w(쓰기)=2, x(실행)=1 이고, 소유자/그룹/기타 순서로 숫자 세 개를 쓴다.
- `755` → 소유자 `rwx`(4+2+1=7), 그룹 `r-x`(5), 기타 `r-x`(5)
- `644` → 소유자 `rw-`(6), 그룹 `r--`(4), 기타 `r--`(4)
- 디렉토리에서 x는 "안으로 들어갈 수 있는 권한"이라서 디렉토리는 보통 755를 쓴다.

### 4-3. Docker 설치 및 점검

```bash
$ docker --version
Docker version 29.9.2, build a82e528

$ docker info    # 발췌 (Client 플러그인 목록은 생략)
Client:
 Version:    29.9.2
 Context:    desktop-linux
Server:
 Containers: 0
  Running: 0
  Paused: 0
  Stopped: 0
 Images: 0
 Server Version: 29.9.2
 Storage Driver: overlayfs
 Logging Driver: local
 Cgroup Driver: cgroupfs
 Cgroup Version: 2
 Kernel Version: 6.18.54.1-microsoft-standard-WSL2
 Operating System: Docker Desktop
 CPUs: 18
 Total Memory: 7.534GiB
```

`Server:` 항목까지 나오니까 데몬이 정상으로 돌고 있다는 뜻이다. 데몬이 꺼져 있으면 `Client:`만 나오고 에러가 난다.

### 4-4. Docker 기본 운영 명령

```bash
$ docker pull alpine
Using default tag: latest
latest: Pulling from library/alpine
Digest: sha256:f59abe656b692d901e184be3445e084786602108599d2a51d229c0f5a48c71bf
Status: Downloaded newer image for alpine:latest

$ docker images
IMAGE           ID             DISK USAGE   CONTENT SIZE   EXTRA
alpine:latest   f59abe656b69         13MB         3.94MB

$ docker run -d --name keep-ubuntu ubuntu sleep infinity
$ docker ps
CONTAINER ID   IMAGE     COMMAND            CREATED                  STATUS                  PORTS     NAMES
fe423e04a791   ubuntu    "sleep infinity"   Less than a second ago   Up Less than a second             keep-ubuntu

$ docker stats --no-stream
CONTAINER ID   NAME          CPU %     MEM USAGE / LIMIT     MEM %     NET I/O        BLOCK I/O   PIDS
fe423e04a791   keep-ubuntu   0.00%     2.051MiB / 7.533GiB   0.03%     1.17kB / 84B   0B / 0B     1

$ docker stop keep-ubuntu
$ docker ps -a
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS                                PORTS     NAMES
1781694abcfc   ubuntu        "bash"                   5 seconds ago    Exited (0) 4 seconds ago                        att-test
fe423e04a791   ubuntu        "sleep infinity"         5 seconds ago    Exited (137) Less than a second ago             keep-ubuntu
ab0fb42b914e   ubuntu        "bash -c 'ls / && ec…"   6 seconds ago    Exited (0) 5 seconds ago                        ubuntu-test
1f42532a6467   hello-world   "/hello"                 12 seconds ago   Exited (0) 11 seconds ago                       sharp_keldysh

$ docker logs ubuntu-test
bin
boot
...
var
hello from ubuntu
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
```

`docker stop`으로 멈춘 `keep-ubuntu`의 상태가 `Exited (137)`로 나왔다. `sleep infinity`가 종료 신호(SIGTERM)에 바로 반응하지 않아서 마지막에 강제 종료(SIGKILL)된 것으로 보인다.

### 4-5. 컨테이너 실행 실습

```bash
$ docker run hello-world
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.
...

$ docker run --name ubuntu-test ubuntu bash -c "ls / && echo hello from ubuntu && cat /etc/os-release | head -2"
bin
boot
dev
...
var
hello from ubuntu
PRETTY_NAME="Ubuntu 26.04.1 LTS"
NAME="Ubuntu"
```

`hello-world`는 메시지를 출력하고 바로 종료되고, `docker ps -a`에 `Exited (0)`으로 남는다.

**attach와 exec 차이 (직접 해 본 것)**

```bash
# exec: 이미 떠 있는 컨테이너에 새 프로세스를 하나 더 실행
$ docker exec keep-ubuntu bash -c "ls /home; echo exec-ok"
ubuntu
exec-ok
$ docker ps
CONTAINER ID   IMAGE     COMMAND            CREATED                  STATUS                  PORTS     NAMES
fe423e04a791   ubuntu    "sleep infinity"   Less than a second ago   Up Less than a second             keep-ubuntu
# → exec가 끝나도 컨테이너는 계속 Up

# attach: 컨테이너의 메인 프로세스(bash)에 직접 붙음
$ docker run -di --name att-test ubuntu bash
$ echo "echo attached-ok; exit" | docker attach att-test
$ docker ps -a
1781694abcfc   ubuntu    "bash"     1 second ago   Exited (0) Less than a second ago   att-test
# → attach로 붙은 bash를 exit 했더니 컨테이너가 Exited로 종료됨
```

| | exec | attach |
|---|---|---|
| 하는 일 | 실행 중인 컨테이너 안에서 새 프로세스를 실행 | 컨테이너의 메인 프로세스 입출력에 연결 |
| 내가 끝냈을 때 | 컨테이너는 계속 실행됨 | 메인 프로세스가 끝나면 컨테이너도 종료됨 |

정리하면, 컨테이너 안을 들여다보거나 명령을 쳐 볼 때는 `exec`이 안전하고, `attach`는 메인 프로세스에 직접 붙는 거라 실수로 `exit`하면 컨테이너가 꺼진다. (이번 실행에서 `attached-ok` 글자는 화면에 출력되지 않았다. 입력을 파이프로 넣어서 tty 없이 붙었기 때문으로 보이고, 위 비교는 컨테이너 상태 변화를 기준으로 했다.)

### 4-6. 커스텀 이미지 (Dockerfile)

- 선택: **(A) 웹 서버 베이스 이미지 + 정적 콘텐츠 교체**
- 베이스 이미지: `nginx:alpine` (가벼워서 선택)

웹 서버 소스는 [`app/index.html`](app/index.html), 이미지 정의는 [`Dockerfile`](Dockerfile)에 있다.

```dockerfile
# 베이스 이미지: 가벼운 nginx (alpine 버전)
FROM nginx:alpine

# 이미지 정보 표시용 라벨
LABEL org.opencontainers.image.title="e1-1-web"

# 환경 변수 (실행 모드 표시용)
ENV APP_ENV=dev

# 기본 페이지를 내가 만든 페이지로 교체
COPY app/ /usr/share/nginx/html/

# 컨테이너가 정상인지 주기적으로 확인
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD wget -qO- http://localhost/ > /dev/null || exit 1

EXPOSE 80
```

| 커스텀 포인트 | 목적 |
|---|---|
| `COPY app/ ...` | nginx 기본 페이지 대신 내가 만든 페이지를 서비스 |
| `LABEL` | 이미지에 이름 정보를 남겨서 `docker inspect`로 확인 가능하게 함 |
| `ENV APP_ENV=dev` | 실행 모드를 환경 변수로 분리 (코드 수정 없이 변경 가능) |
| `HEALTHCHECK` | 컨테이너가 실제로 응답하는지 주기적으로 검사 |
| `EXPOSE 80` | 컨테이너가 쓰는 포트를 문서처럼 표시 |

```bash
$ docker build -t my-web:1.0 .
#1 [internal] load build definition from Dockerfile
...
#6 [2/2] COPY app/ /usr/share/nginx/html/
#6 DONE 0.1s
#7 exporting to image
#7 naming to docker.io/library/my-web:1.0 done

$ docker images my-web
IMAGE        ID             DISK USAGE   CONTENT SIZE   EXTRA
my-web:1.0   6b1e33c1f615       93.6MB         26.4MB

$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'
NAMES         STATUS                    PORTS
my-web-8081   Up 15 seconds (healthy)   0.0.0.0:8081->80/tcp, [::]:8081->80/tcp
my-web-8080   Up 15 seconds (healthy)   0.0.0.0:8080->80/tcp, [::]:8080->80/tcp

$ docker exec my-web-8080 printenv APP_ENV
dev

$ docker inspect --format '{{index .Config.Labels "org.opencontainers.image.title"}}' my-web:1.0
e1-1-web

$ docker logs my-web-8080 | tail -3
172.17.0.1 - - [21/Nov/2026:16:41:38 +0000] "GET / HTTP/1.1" 200 385 "-" "curl/8.18.0" "-"
::1 - - [21/Nov/2026:16:41:44 +0000] "GET / HTTP/1.1" 200 385 "-" "Wget" "-"
```

처음에는 `(health: starting)`이었다가 10초 정도 지나니 `(healthy)`로 바뀌었다. 로그의 마지막 줄 `Wget`은 HEALTHCHECK가 보낸 요청이다.

### 4-7. 포트 매핑 및 접속 증거

같은 이미지를 호스트 포트만 다르게 해서 두 개 실행했다.

```bash
$ docker run -d -p 8080:80 --name my-web-8080 my-web:1.0
$ docker run -d -p 8081:80 --name my-web-8081 my-web:1.0

$ curl -s http://localhost:8080
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>E1-1 내 첫 Docker 웹 서버</title>
  ...
  <h1>Hello, Docker!</h1>
  <p>nginx 컨테이너에서 서비스 중인 페이지입니다.</p>
  <p>버전: v1</p>
</body>
</html>

$ curl -s http://localhost:8081
(위와 동일한 응답)
```

- 브라우저 스크린샷 (주소창에 `localhost:8080` 표시): `docs/images/port-8080.png` (추가 예정)
- 브라우저 스크린샷 (주소창에 `localhost:8081` 표시): `docs/images/port-8081.png` (추가 예정)

**포트 매핑이 필요한 이유**

컨테이너는 자기만의 네트워크를 가진 격리된 환경이라서, 컨테이너 안에서 nginx가 80번 포트를 열고 있어도 내 컴퓨터(호스트)에서는 바로 접근할 수 없다. `-p 8080:80`은 "호스트의 8080번으로 오는 요청을 컨테이너의 80번으로 넘겨 달라"는 설정이다. 그리고 컨테이너마다 내부 포트가 똑같이 80이어도 호스트 포트를 8080, 8081처럼 다르게 주면 같은 이미지를 여러 개 동시에 띄울 수 있다.

### 4-8. 바인드 마운트

호스트의 폴더를 컨테이너 안에 그대로 연결하는 방식이다. 이미지를 다시 빌드하지 않아도 호스트에서 파일을 고치면 바로 반영된다.

```bash
$ mkdir -p ~/codyssey/bind/site && cd ~/codyssey/bind
$ echo "<h1>bind mount before</h1>" > site/index.html

$ docker run -d -p 8082:80 -v $(pwd)/site:/usr/share/nginx/html --name bind-test nginx:alpine

# 변경 전
$ cat site/index.html
<h1>bind mount before</h1>
$ curl -s http://localhost:8082
<h1>bind mount before</h1>

# 호스트에서 파일 수정
$ echo "<h1>bind mount after</h1>" > site/index.html

# 변경 후 (컨테이너를 다시 만들지 않았음)
$ curl -s http://localhost:8082
<h1>bind mount after</h1>
$ docker exec bind-test cat /usr/share/nginx/html/index.html
<h1>bind mount after</h1>
```

| | 호스트 파일 | `curl localhost:8082` 응답 |
|---|---|---|
| 변경 전 | `bind mount before` | `bind mount before` |
| 변경 후 | `bind mount after` | `bind mount after` |

바인드 마운트 폴더는 OneDrive 폴더가 아니라 WSL 홈(`~/codyssey/bind`)에 만들었다. OneDrive 안에 두면 동기화 때문에 파일 반영이 늦거나 꼬일 수 있을 것 같아서 피했다.

### 4-9. Docker 볼륨 영속성

볼륨은 Docker가 관리하는 저장 공간이라 컨테이너를 지워도 남아 있다.

```bash
$ docker volume create mydata
mydata

$ docker volume ls
DRIVER    VOLUME NAME
local     mydata

$ docker run -d --name vol-test -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test bash -c 'echo hi > /data/hello.txt && cat /data/hello.txt'
hi

# 컨테이너 삭제
$ docker rm -f vol-test
vol-test
$ docker ps -a --filter name=vol-test
CONTAINER ID   IMAGE     COMMAND   CREATED   STATUS    PORTS     NAMES
$ docker volume ls
DRIVER    VOLUME NAME
local     mydata

# 새 컨테이너에 같은 볼륨 연결
$ docker run -d --name vol-test2 -v mydata:/data ubuntu sleep infinity
$ docker exec vol-test2 bash -c 'cat /data/hello.txt'
hi

$ docker volume inspect mydata
[
    {
        "CreatedAt": "2026-11-21T16:42:02Z",
        "Driver": "local",
        "Labels": null,
        "Mountpoint": "/var/lib/docker/volumes/mydata/_data",
        "Name": "mydata",
        "Options": null,
        "Scope": "local"
    }
]
```

| | 컨테이너 | `/data/hello.txt` |
|---|---|---|
| 삭제 전 | `vol-test` | `hi` |
| 삭제 후 | 없음 (`docker ps -a`에서 사라짐) | 볼륨 `mydata`는 그대로 남아 있음 |
| 새 컨테이너 | `vol-test2` | `hi` 그대로 유지 |

컨테이너 안의 파일은 컨테이너를 지우면 같이 사라지지만, 볼륨에 저장한 데이터는 컨테이너와 별개로 남는다. 그래서 DB 데이터처럼 지워지면 안 되는 데이터는 볼륨에 저장한다.

### 4-10. Git 설정 및 GitHub 연동

```bash
$ git config --global user.name "choi-siwon1106"
$ git config --global user.email "<masked>"
$ git config --global init.defaultBranch main

$ git config --list
user.name=choi-siwon1106
user.email=<masked>
init.defaultbranch=main
```

(이메일은 마스킹했다.)

- VS Code GitHub 로그인 및 저장소 연동 스크린샷: `docs/images/vscode-github.png` (추가 예정)

**Git과 GitHub의 차이**
- Git은 내 컴퓨터에서 파일의 변경 이력을 관리하는 버전 관리 도구이다. 인터넷 없이도 쓸 수 있다.
- GitHub는 Git 저장소를 인터넷에 올려서 보관하고 다른 사람과 같이 작업(공유, 리뷰, 이슈 등)할 수 있게 해 주는 원격 플랫폼이다.
- 그래서 `git commit`은 내 컴퓨터에 기록하는 것이고, `git push`를 해야 GitHub에 올라간다.

## 5. 검증 방법 요약

| 항목 | 검증 명령 | 확인한 것 |
|---|---|---|
| Docker 설치 | `docker --version`, `docker info` | 클라이언트/서버 둘 다 29.9.2, 데몬 동작 |
| 컨테이너 실행 | `docker run hello-world`, `docker ps -a` | 메시지 출력, `Exited (0)` |
| 이미지 빌드 | `docker build`, `docker images my-web` | `my-web:1.0` 생성 |
| 포트 매핑 | `curl localhost:8080`, `curl localhost:8081` | 둘 다 같은 페이지 응답 |
| 헬스체크 | `docker ps` | `(healthy)` 확인 |
| 바인드 마운트 | 호스트 파일 수정 후 `curl localhost:8082` | 수정한 내용이 바로 반영 |
| 볼륨 영속성 | 컨테이너 삭제 후 새 컨테이너에서 `cat` | `hi` 유지 |

## 6. 트러블슈팅

### 6-1. WSL 설치 실패
- **문제**: `wsl --install -d Ubuntu`를 실행해도 설치되지 않고 "wsl.exe --install을 실행하라"는 안내만 나왔다.
- **원인 가설**: 관리자 권한 없이 실행했거나, WSL 기능 자체가 아직 설치되지 않은 상태일 것이다.
- **확인**: `wsl --version`은 출력되지 않았고 `wsl -l -v`는 배포판이 없다고 나왔다.
- **해결**: 설치 명령을 다시 실행하니 "시스템을 다시 시작하면 변경 사항이 적용됩니다"가 나왔다. 재부팅 후 `wsl --install -d Ubuntu`를 한 번 더 실행해서 Ubuntu가 설치됐다.

### 6-2. Ubuntu에서 `docker` 명령을 찾을 수 없음
- **문제**: Ubuntu 터미널에서 `docker pull alpine`을 실행했더니 `The command 'docker' could not be found in this WSL 2 distro.`가 나왔다. 전에는 같은 명령이 잘 됐다.
- **원인 가설**: Docker가 설치가 안 된 게 아니라 Docker Desktop이 꺼져 있어서 WSL 연동이 끊겼을 것이다.
- **확인**: `wsl -l -v`에서 `docker-desktop`이 `Stopped`로 나왔다. Docker Desktop 프로세스도 없었다.
- **해결**: Docker Desktop을 실행하고 `docker info`에 `Server Version`이 나오는 것을 확인한 뒤 같은 명령을 다시 실행하니 정상 동작했다. WSL에서 Docker를 쓰려면 Docker Desktop이 먼저 켜져 있어야 한다는 것을 알게 됐다.

## 7. 재현 방법

```bash
# 1) 저장소 받기
git clone <저장소 주소>
cd E1-1

# 2) 이미지 빌드
docker build -t my-web:1.0 .

# 3) 실행 (호스트 8080 → 컨테이너 80)
docker run -d -p 8080:80 --name my-web-8080 my-web:1.0

# 4) 확인
curl http://localhost:8080
```

- Docker Desktop(또는 Docker 엔진)이 실행 중이어야 한다.
- 바인드 마운트 실습은 `~/codyssey/bind/site/index.html`을 만들고 4-8의 명령을 그대로 따라 하면 된다. 경로는 본인 홈 폴더로 바꿔도 된다.
- 8080, 8081, 8082 포트를 다른 프로그램이 쓰고 있으면 `-p` 앞쪽 숫자를 바꾼다.

## 8. 보안 유의사항

- 이메일, 토큰, 비밀번호는 문서에 넣지 않고 마스킹했다.
- GitHub 로그인은 VS Code의 로그인 기능을 쓰고, 토큰은 기록하지 않는다.
