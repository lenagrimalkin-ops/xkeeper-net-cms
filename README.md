# xkeeper-net-cms

Strapi 5 — headless CMS для x-keeper.net (редизайн).

## Демо-стенд (Phase A MVP)

- **Strapi admin:** https://xkeeper-net-cms.onrender.com/admin
- **Public API:** https://xkeeper-net-cms.onrender.com/api/*
- **Frontend:** https://xkeeper-net-frontend-76ip5ndmn-lenagrimalkin-ops-projects.vercel.app
- **Брифинг проекта:** [Confluence — Draft v0.6](https://x-keeper.atlassian.net/wiki/spaces/P/pages/2023981067)
- **План миграции:** [Confluence](https://x-keeper.atlassian.net/wiki/spaces/P/pages/2044035091)

Деплой: GitHub `lenagrimalkin-ops/xkeeper-net-cms` → Render auto-deploy on push.

## Content-types

Все типы описаны как **код** в `src/api/` и `src/components/`. Strapi подхватывает их при старте — никаких UI-кликов в Content-Type Builder не требуется.

Структура:

- **`src/components/shared/*`** — 12 переиспользуемых компонентов: seo, feature, spec, cta, number-stat, faq-item, case-item, review-item, partner-item, link, social-link.
- **`src/components/blocks/*`** — 12 блоков для Dynamic Zone: hero, text-media, advantages, numbers, cases, services-turnkey, cta-block, faq, form, reviews, video, partners.
- **`src/api/page/`** — Page (универсальная страница с конструктором блоков).
- **`src/api/product/`** — Product (карточка оборудования).
- **`src/api/service/`** — Service (страница услуги).
- **`src/api/solution/`** — Solution (отраслевое решение).
- **`src/api/global-setting/`** — Global Settings (single type).

Полная спецификация: [docs/content-types.md](docs/content-types.md).

## После первого деплоя — что сделать в админке

После того как Render передеплоил с новыми схемами:

### 1. Включить публичный доступ к API (1 минута)

Settings → Users & Permissions Plugin → Roles → **Public** → отметить:

| Content type | find | findOne |
|---|---|---|
| Page | ✓ | ✓ |
| Product | ✓ | ✓ |
| Service | ✓ | ✓ |
| Solution | ✓ | ✓ |
| Global-setting | ✓ | — |

Нажать **Save** в правом верхнем углу.

Без этого фронт получит 401/403 при попытке прочитать содержимое.

### 2. Создать API Token для фронта

Settings → API Tokens → **Create new API Token**:

- Name: `xkeeper-net-frontend`
- Description: `Read-only token for Vercel frontend`
- Token duration: **Unlimited**
- Token type: **Read-only**

Жми **Save** → токен покажется **один раз** — скопируй сразу.

Этот токен попозже добавим как `STRAPI_TOKEN` env в Vercel-проект.

### 3. Заполнить тестовый контент

В Content Manager создать минимальный набор:

1. **Global Settings** — заполнить телефон, email, реквизиты, навигацию (5 пунктов меню).
2. **Page** «Главная» — `isHome=true`, добавить блоки: hero, numbers, advantages, services-turnkey, partners, form.
3. **Product** «Invis 3D W» — заполнить технические характеристики.
4. **Service** «Установка и маркирование» — короткая страница.
5. **Solution** «Для лизингодателей» — лендинг.

## Локальная разработка

```bash
npm install
cp .env.example .env
# заполнить .env: APP_KEYS, JWT_SECRET, и т.д. (генерируется openssl rand -base64 24)
npm run develop   # http://localhost:1337/admin
```

## База данных

- **Текущая** (Phase A demo): Postgres на Render free tier (срок 90 дней, потом перевыпуск).
- **Локальная**: SQLite в `.tmp/data.db` (если не переопределить DATABASE_CLIENT).
- **Прод**: будет k8s + Postgres в namespace vibe-panel.

## Переезд на X-Keeper org

Когда admin создаст репо `X-Keeper/xkeeper-net-cms`:

```bash
git remote set-url origin https://github.com/X-Keeper/xkeeper-net-cms.git
git push -u origin main
# Также добавить .github/workflows/k8s-stage.yml (он уже здесь) → push tag stage-v* → k8s deploy
```
