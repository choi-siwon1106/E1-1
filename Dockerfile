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
