ARG BASE_IMAGE=node
ARG IMAGE_TAG=latest

FROM ${BASE_IMAGE}:${IMAGE_TAG}

ADD --chown=1000:1000 ./instant-search-demo/ /instant-search-demo/

WORKDIR /instant-search-demo

EXPOSE 3000

USER 1000

RUN npm install

CMD ["npm", "start"]

LABEL org.opencontainers.image.created=2022-04-22
