FROM node:22-alpine AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

FROM base AS build
WORKDIR /app
COPY . /app

RUN corepack enable
RUN apk add --no-cache python3 alpine-sdk git

RUN --mount=type=cache,id=pnpm,target=/pnpm/store \
    pnpm install --prod --frozen-lockfile

RUN pnpm deploy --filter=@imput/cobalt-api --prod /prod/api

FROM base AS api
WORKDIR /app

# Yahan hum nakli git history bana rahe hain
RUN apk add --no-cache git && \
    git init && \
    git config user.email "you@example.com" && \
    git config user.name "Your Name" && \
    git commit --allow-empty -m "init"

COPY --from=build --chown=node:node /prod/api /app

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
