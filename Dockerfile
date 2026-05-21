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

# Yahan hum Git ki zaruraton ko fake kar rahe hain taake API khush ho jaye
RUN apk add --no-cache git && \
    git init && \
    git config user.email "deploy@render.com" && \
    git config user.name "Render Deploy" && \
    git remote add origin https://github.com/alibacha12/cobalt.git && \
    git commit --allow-empty -m "fix: initialize git repository for api"

COPY --from=build --chown=node:node /prod/api /app

# Ye command ensure karti hai ke permissions sahi rahein
RUN chown -R node:node /app

USER node

EXPOSE 9000
CMD [ "node", "src/cobalt" ]
