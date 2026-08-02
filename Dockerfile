FROM ryakel/stream-harvestarr:v1.9.10

RUN apk upgrade --no-cache && apk add --no-cache deno patch
RUN pip install --no-cache-dir -U yt-dlp yt-dlp-ejs

# ytsearch() returned the first entry extract_info handed back, trusting
# matchtitle to have removed the rest. It doesn't: YoutubeDL._match_entry
# returns before the title check for any entry it can't confirm is a single
# video, so every playlist in a channel-search result is unfiltered. The
# "Epicly Later'd" playlist sat at index 0 and won every episode — and with a
# fixed outtmpl plus nooverwrites, yt-dlp wrote the playlist's first item into
# each episode's filename. Also makes the "(Part N)" half of a title required
# rather than optional, so parts stop collapsing onto one another.
#
# ryakel/stream-harvestarr#157. Drop once a base image carries it.
COPY patches/0001-ytsearch-entry-selection.patch /tmp/
RUN patch -p1 -d / --no-backup-if-mismatch < /tmp/0001-ytsearch-entry-selection.patch \
  && rm /tmp/0001-ytsearch-entry-selection.patch \
  && grep -q 'def is_single_video' /app/stream_harvestarr.py \
  && grep -q 'def title_matches' /app/stream_harvestarr.py \
  && grep -q 'COLLECTION_URL_RE' /app/stream_harvestarr.py \
  && python -c "import ast; ast.parse(open('/app/stream_harvestarr.py').read())" \
  && python -c "import ast; ast.parse(open('/app/utils.py').read())"
