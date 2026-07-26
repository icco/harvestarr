FROM ryakel/stream-harvestarr:v1.9.8

RUN apk upgrade --no-cache && apk add --no-cache deno
RUN pip install --no-cache-dir -U yt-dlp yt-dlp-ejs

# Sonarr v4 rejects a string seriesId in RescanSeries commands (HTTP 500)
RUN sed -i 's/"seriesId": str(series_id)/"seriesId": int(series_id)/' /app/stream_harvestarr.py \
  && grep -q 'int(series_id)' /app/stream_harvestarr.py

# ignoreerrors makes yt-dlp return None from extract_info rather than raise, and
# ytsearch() indexes it: the TypeError kills the scheduler, so the container
# restart-loops and nothing downloads. Drop once the base image handles it.
RUN sed -i "s|if 'entries' in result and|if 'entries' in (result or {}) and|" /app/stream_harvestarr.py \
  && sed -i "s|video_url = result.get('webpage_url') or result.get('url')|video_url = (result or {}).get('webpage_url') or (result or {}).get('url')|" /app/stream_harvestarr.py \
  && sed -i "s|logger.error(e)$|logger.error(e); return False, ''|" /app/stream_harvestarr.py \
  && grep -q 'in (result or {})' /app/stream_harvestarr.py \
  && grep -q "(result or {}).get('webpage_url')" /app/stream_harvestarr.py \
  && grep -q "logger.error(e); return False, ''" /app/stream_harvestarr.py \
  && python -c "import ast; ast.parse(open('/app/stream_harvestarr.py').read())"
