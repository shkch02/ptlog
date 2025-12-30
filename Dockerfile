# 1. Build Stage: Flutter 빌드 환경
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# 의존성 파일 복사 및 설치
COPY pubspec.* ./
RUN flutter pub get

# 전체 소스 복사 및 웹 빌드
COPY . .
RUN flutter build web --release

# 2. Production Stage: Nginx로 서빙
FROM nginx:alpine

# Nginx 기본 설정 파일 교체 (SPA 라우팅 문제 해결용, 아래 팁 참조)
 COPY nginx.conf /etc/nginx/conf.d/default.conf 

# 빌드된 결과물을 Nginx 폴더로 복사
COPY --from=build /app/build/web /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]