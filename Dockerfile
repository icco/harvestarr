FROM ryakel/stream-harvestarr:v1.9.10

RUN apk upgrade --no-cache && apk add --no-cache deno patch
RUN pip install --no-cache-dir -U yt-dlp yt-dlp-ejs

# Episode matching fixes, none of which are in a released base image yet.
#
# 1. ytsearch() returned the first entry extract_info handed back, trusting
#    matchtitle to have removed the rest. It doesn't: YoutubeDL._match_entry
#    returns before the title check for any entry it can't confirm is a single
#    video, so every playlist in a channel-search result is unfiltered. The
#    "Epicly Later'd" playlist sat at index 0 and won every episode — and with
#    a fixed outtmpl plus nooverwrites, yt-dlp wrote the playlist's first item
#    into each episode's filename.
# 2. upperescape() made the "(Part N)" half of a title optional rather than
#    just its brackets, so every part of a series collapsed onto one regex.
# 3. regex.site was assigned and never read — inert despite being documented.
# 4. Unrecognised series/service config keys now warn instead of being
#    silently ignored.
# 5. regex.require (new) scopes a series to one show on a channel that carries
#    several — "Max Schaaf" and "Arto Saari" were matching Let It Kill You.
#    A part-labelled upload can no longer satisfy an episode Sonarr models as
#    whole; part 1 used to download and flip hasFile.
# 6. The search runs flat (extract_flat: in_playlist). A channel search
#    carries the channel's playlists alongside its videos and yt-dlp recursed
#    into all 13 of them, largest 1773 items, for every episode — enough to
#    get rate-limited by YouTube. is_single_video() refused to return one
#    anyway.
# 7. matchtitle is no longer set at all. yt-dlp guards its title check with
#    `if 'title' in info_dict` — key present, value possibly None — so one
#    private video in a playlist raises TypeError, ignoreerrors swallows it,
#    and extract_info returns None for the WHOLE playlist. That is why all 31
#    Hot Ones episodes reported "No metadata returned". The check lives in the
#    match_filter callable instead, which tolerates a null title.
#
# ryakel/stream-harvestarr#157. Necessarily carries #152 (the Shorts
# match_filter) too, since (1) composes with that filter rather than replacing
# it, and v1.9.10 still has the inert 'match-filter' string key.
#
# Drop the whole block once a base image ships #157.
COPY patches/0001-ytsearch-entry-selection.patch /tmp/
RUN patch -p1 -d / --no-backup-if-mismatch < /tmp/0001-ytsearch-entry-selection.patch \
  && rm /tmp/0001-ytsearch-entry-selection.patch \
  && grep -q 'def is_single_video' /app/stream_harvestarr.py \
  && grep -q 'def title_matches' /app/stream_harvestarr.py \
  && grep -q 'def episode_title_matches' /app/stream_harvestarr.py \
  && grep -q 'def make_title_filter' /app/stream_harvestarr.py \
  && grep -q 'def warn_unknown_keys' /app/stream_harvestarr.py \
  && grep -q 'def has_part_marker' /app/stream_harvestarr.py \
  && grep -q 'MatchRules' /app/stream_harvestarr.py \
  && grep -q "'extract_flat': 'in_playlist'" /app/stream_harvestarr.py \
  && grep -q 'COLLECTION_URL_RE' /app/stream_harvestarr.py \
  && grep -q 'match_filter_func' /app/stream_harvestarr.py \
  && ! grep -q "'match-filter'" /app/stream_harvestarr.py \
  && ! grep -q "'matchtitle':" /app/stream_harvestarr.py \
  && python -c "import ast; ast.parse(open('/app/stream_harvestarr.py').read())" \
  && python -c "import ast; ast.parse(open('/app/utils.py').read())"
