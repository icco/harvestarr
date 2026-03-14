FROM ryakel/stream-harvestarr:v1.6.15

RUN apk upgrade --no-cache && apk add --no-cache deno
RUN pip install --no-cache-dir -U yt-dlp yt-dlp-ejs
