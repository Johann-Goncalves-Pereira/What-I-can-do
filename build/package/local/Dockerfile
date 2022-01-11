FROM node:16.13
ARG BASE_API_URL
ENV BASE_API_URL=${BASE_API_URL}
WORKDIR /app
COPY package.json package.json
COPY yarn.lock yarn.lock
RUN yarn install
ENTRYPOINT ["/app/run/scripts/run.sh"]
EXPOSE 9000
