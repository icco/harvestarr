FROM ryakel/stream-harvestarr:v1.9.8

RUN apk upgrade --no-cache && apk add --no-cache deno
RUN pip install --no-cache-dir -U yt-dlp yt-dlp-ejs

# Sonarr v4 rejects a string seriesId in RescanSeries commands (HTTP 500)
RUN sed -i 's/"seriesId": str(series_id)/"seriesId": int(series_id)/' /app/stream_harvestarr.py \
  && grep -q 'int(series_id)' /app/stream_harvestarr.py
