
FROM alpine

WORKDIR /work
COPY run.sh .
COPY update.sh .
RUN apk add --no-cache bash git nodejs npm \
	python make curl thttpd rsync unzip \
	chromium harfbuzz nss freetype \
	ttf-freefont && \
	npm i -g npm@latest jest-cli 

EXPOSE 80

CMD ["bash", "run.sh"]

HEALTHCHECK --interval=2m --timeout=5s --start-period=5m \
	CMD curl -f http://localhost || exit 1

