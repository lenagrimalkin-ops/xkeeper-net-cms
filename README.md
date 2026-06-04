# xkeeper-net-cms

Strapi 5 — headless CMS для x-keeper.net (редизайн).

- **Stage admin:** https://cms.xkeeper-net.stage.x-keeper.net/admin
- **Frontend:** https://xkeeper-net.stage.x-keeper.net (репо `X-Keeper/xkeeper-net-frontend`)
- **Брифинг проекта:** [Confluence — Draft v0.6](https://x-keeper.atlassian.net/wiki/spaces/P/pages/2023981067)
- **План миграции:** [Confluence](https://x-keeper.atlassian.net/wiki/spaces/P/pages/2044035091)

## Бутстрап (один раз, после клонирования)

Файлы Strapi (config/, src/, package.json) генерируются официальным CLI. Этот репо изначально содержит только deploy-обвязку (Dockerfile, workflow, values, .env.example).

```bash
cd ~/xk/xkeeper-net-cms

# Заводим Strapi в текущей директории.
# --no-run чтобы не стартовать сразу, --skip-cloud чтобы не звал в Strapi Cloud.
npx create-strapi@latest . \
  --typescript \
  --skip-cloud \
  --no-run \
  --dbclient=sqlite \
  --dbname=tmp \
  --use-npm

# Скопировать .env.example → .env (для локального запуска)
cp .env.example .env

# Сгенерировать реальные секреты на место replace-me
# (для локала, для стейджа — пока хардкод в deploy/values-stage.yaml, см. TODO)
node -e "console.log('APP_KEYS=' + [1,2].map(() => require('crypto').randomBytes(16).toString('base64')).join(','))" >> .env
```

## Локальный запуск

```bash
npm install
npm run develop   # http://localhost:1337/admin
```

Первый запуск попросит создать super-admin аккаунт.

## Деплой на stage

По тегу `stage-vYYYYMMDD-<descr>-HHMMSS`:

```bash
TS=$(date +%H%M%S)
DATE=$(date +%Y%m%d)
git tag -a "stage-v${DATE}-<short>-${TS}" -m "Deploy <что>"
git push origin "stage-v${DATE}-<short>-${TS}"
```

## База данных

- **Phase A (сейчас):** SQLite в эфемерном томе пода. **Контент пропадает при рестарте/redeploy.** Для демо это ок — пересоздать 5 страниц быстро.
- **Phase B:** переключиться на PostgreSQL (отдельный Helm-релиз или существующий PG в кластере), DATABASE_URL из k8s Secret, медиа на PVC.

## Секреты

Сейчас в `deploy/values-stage.yaml` хардкод `phaseA-placeholder` (отметить TODO). Перед первой раздачей доступа маркетингу:
1. Сгенерировать настоящие случайные значения для `APP_KEYS`, `API_TOKEN_SALT`, `ADMIN_JWT_SECRET`, `TRANSFER_TOKEN_SALT`, `JWT_SECRET`.
2. Положить в k8s Secret (через админа или kubectl).
3. В values-stage.yaml заменить `env:` на `envFrom: [secretRef:]`.

## Как работать с контентом

См. секцию «Strapi 101» в этом README или внутренний гайд (отдельный документ для маркетинга).
