# Copy the application and build it
ARG BASE_IMAGE=node
ARG IMAGE_TAG=latest

FROM ${BASE_IMAGE}:${IMAGE_TAG}

ADD --chown=1000:1000 ./instant-search-demo/ /instant-search-demo/
WORKDIR /instant-search-demo
EXPOSE 3000
USER 1000
RUN npm install
CMD ["npm", "start"]

LABEL org.opencontainers.image.created="${DATE}"
LABEL org.opencontainers.image.url="https://github.com/algolia/instant-search-demo"
LABEL org.opencontainers.image.source="https://github.com/algolia/instant-search-demo"
LABEL org.opencontainers.image.version="${IMAGE_TAG}"
LABEL org.opencontainers.image.revision="${IMAGE_TAG}"
LABEL org.opencontainers.image.vendor="Algolia"
LABEL org.opencontainers.image.title="instant-search-demo"
LABEL org.opencontainers.image.description="Instant-Search demo"
