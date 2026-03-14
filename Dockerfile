FROM ryakel/stream-harvestarr:v1.6.15

RUN apk upgrade --no-cache && apk add --no-cache deno
