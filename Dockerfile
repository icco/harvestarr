FROM ryakel/stream-harvestarr:v1.6.15

RUN apt-get update && apt-get install -y unzip curl \
    && curl -fsSL https://deno.land/install.sh | DENO_INSTALL=/usr/local sh \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
