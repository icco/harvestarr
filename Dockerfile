FROM ryakel/stream-harvestarr:v1.6.15

RUN apk upgrade --no-cache && apk add --no-cache deno \
    && pip install --no-cache-dir yt-dlp-ejs \
    && echo "--remote-components ejs:github" > /etc/yt-dlp.conf
