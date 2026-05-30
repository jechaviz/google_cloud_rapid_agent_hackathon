FROM thevlang/vlang:latest AS build

WORKDIR /app
COPY . .
RUN v -prod -o /agent cmd/agent

FROM debian:bookworm-slim
COPY --from=build /agent /agent
ENV APP_PORT=8080
EXPOSE 8080
CMD ["/bin/sh", "-c", "/agent serve --port ${APP_PORT}"]
