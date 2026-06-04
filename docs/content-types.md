# Strapi content-types для Фазы A

Спецификация для пошагового набивания в Content-Type Builder. Соответствует §7.3 [брифа Draft v0.6](https://x-keeper.atlassian.net/wiki/spaces/P/pages/2023981067).

## Архитектурное решение

`Block` из §7.3 — это **не отдельный content-type**, а **Strapi Components + Dynamic Zone**. Каждый тип блока — компонент; у `Page`/`Product`/`Solution`/`Service` есть поле `blocks: Dynamic Zone`, куда маркетинг кидает любые компоненты в нужном порядке.

## Порядок создания (важен)

1. Shared-компоненты (4 шт) — на них ссылаются всё остальное
2. Block-компоненты (12 шт) — для dynamic zone
3. Collection Types: `Product` → `Service` → `Solution` → `Page` (порядок такой, потому что Solution ссылается на Product/Service)
4. Single Type: `GlobalSettings`
5. Public permissions + API Token + CORS

---

## 1. Shared-компоненты (категория `shared`)

### `shared.seo`
Переиспользуется в Page/Product/Solution/Service.

| Поле | Тип Strapi | Заметки |
|---|---|---|
| metaTitle | Text (short) | required |
| metaDescription | Text (long) | required |
| metaKeywords | Text (short) | опционально |
| ogImage | Media (single, images) | для соцсетей |
| canonicalUrl | Text (short) | опционально |

### `shared.feature`
Для блока «Преимущества» и для Product.

| Поле | Тип | |
|---|---|---|
| title | Text (short) | required |
| description | Text (long) | |
| icon | Media (single, images) | SVG/PNG |

### `shared.spec`
Для технических характеристик Product.

| Поле | Тип | |
|---|---|---|
| name | Text (short) | required — "Срок службы" |
| value | Text (short) | required — "до 7 лет" |
| group | Text (short) | "Питание" / "Корпус" — для группировки в таблице |

### `shared.cta`
Кнопка призыва.

| Поле | Тип | |
|---|---|---|
| label | Text (short) | required — "Получить предложение" |
| url | Text (short) | required — "/contacts#form" |
| style | Enumeration | `primary` / `secondary` / `text` |

---

## 2. Block-компоненты (категория `blocks`)

Используются как варианты в Dynamic Zone.

| Компонент | Поля |
|---|---|
| **`blocks.hero`** | `heading` Text · `subheading` Text · `backgroundMedia` Media · `cta` shared.cta |
| **`blocks.text-media`** | `title` Text · `body` Rich Text · `media` Media · `mediaPosition` Enumeration (`left`/`right`) |
| **`blocks.advantages`** | `title` Text · `items` shared.feature (Repeatable) |
| **`blocks.numbers`** | `title` Text · `items` Repeatable component (`number` Text — "120 000+", `label` Text — "клиентов") |
| **`blocks.cases`** | `title` Text · `items` Repeatable component (`title` Text, `problem` Text, `solution` Text, `result` Text, `image` Media) |
| **`blocks.services-turnkey`** | `title` Text · `services` Relation has many `Service` |
| **`blocks.cta`** | `title` Text · `description` Text · `cta` shared.cta · `formType` Enumeration (`personal-offer`/`industry`/`service`) |
| **`blocks.faq`** | `title` Text · `items` Repeatable component (`question` Text, `answer` Rich Text) |
| **`blocks.form`** | `title` Text · `formType` Enumeration (`personal-offer`/`industry`/`service`) · `prefilledSubject` Text |
| **`blocks.reviews`** | `title` Text · `items` Repeatable component (`author` Text, `position` Text, `company` Text, `quote` Text, `avatar` Media) |
| **`blocks.video`** | `title` Text · `videoUrl` Text · `poster` Media |
| **`blocks.partners`** | `title` Text · `items` Repeatable component (`logo` Media, `name` Text, `url` Text) — в Phase A без отдельного типа Partner |

---

## 3. Collection Types

### `Product` — карточка оборудования

| Поле | Тип | Заметки |
|---|---|---|
| name | Text (short) | required — "Invis 3D W" |
| slug | UID | targetField: name |
| series | Enumeration | `invis` / `online` / `container` |
| model | Text (short) | "3DW" |
| summary | Text (long) | под hero |
| heroImage | Media (single) | фото устройства |
| features | shared.feature (Repeatable) | ключевые характеристики |
| specs | shared.spec (Repeatable) | техническая таблица |
| usageScenarios | Rich Text | «Сценарии применения» |
| gallery | Media (multiple) | дополнительные фото |
| documents | Media (multiple) | PDF паспорта/сертификаты |
| seo | shared.seo (Component) | |
| blocks | Dynamic Zone | для дополнительных секций под карточкой |

### `Service` — страница услуги

| Поле | Тип | Заметки |
|---|---|---|
| name | Text (short) | required — "Установка и маркирование" |
| slug | UID | targetField: name |
| summary | Text (long) | под hero |
| whenNeeded | Rich Text | «Когда нужна услуга» |
| whatIncluded | Rich Text | «Состав услуги: шаги, что входит» |
| geography | Text (long) | «География и SLA» |
| relatedServices | Relation many-to-many `Service` | для блока «связь с другими услугами полного цикла» |
| heroImage | Media (single) | |
| seo | shared.seo (Component) | |
| blocks | Dynamic Zone | для блоков ниже hero |

### `Solution` — лендинг отраслевого решения

| Поле | Тип | Заметки |
|---|---|---|
| title | Text (short) | required — "Для лизингодателей" |
| slug | UID | targetField: title |
| segment | Enumeration | `leasing` / `freight` / `fleet` |
| summary | Text (long) | |
| heroImage | Media (single) | |
| relatedProducts | Relation has many `Product` | |
| relatedServices | Relation has many `Service` | |
| seo | shared.seo (Component) | |
| blocks | Dynamic Zone | вся «начинка» лендинга |

### `Page` — универсальная страница

Используется для главной и любой нестандартной страницы (контакты, About и т.д.).

| Поле | Тип | Заметки |
|---|---|---|
| title | Text (short) | required |
| slug | UID | targetField: title |
| isHome | Boolean | для главной — true (только одна запись с этим флагом) |
| seo | shared.seo (Component) | |
| blocks | Dynamic Zone | главное — конструктор страницы |

---

## 4. Single Type

### `GlobalSettings` — одна запись на сайт

| Поле | Тип | Заметки |
|---|---|---|
| siteName | Text (short) | "X-Keeper" |
| phone | Text (short) | "+7 ..." |
| email | Email | |
| legalAddress | Text (long) | |
| legalDetails | Rich Text | юр. реквизиты для футера |
| footerLinks | Repeatable component | (`label` Text, `url` Text, `group` Text — для группировки колонок) |
| socialLinks | Repeatable component | (`platform` Enumeration `telegram/whatsapp/vk/youtube`, `url` Text) |
| yandexMetricaId | Text (short) | "104880932" |
| consentText | Rich Text | текст под формами «Нажимая, я соглашаюсь…» |
| navigationHeader | Repeatable component | (`label` Text, `url` Text) — верхнее меню (5 пунктов из §5.1 брифа) |

---

## 5. Public permissions (Settings → Users & Permissions Plugin → Roles → Public)

| Content type | find | findOne |
|---|---|---|
| Page | ✓ | ✓ |
| Product | ✓ | ✓ |
| Service | ✓ | ✓ |
| Solution | ✓ | ✓ |
| GlobalSettings | ✓ | — (single type) |

---

## 6. API Token

Settings → API Tokens → Create new:
- Name: `xkeeper-net-frontend`
- Token type: **Read-only**
- Duration: Unlimited

Скопировать токен (показывается один раз) → положить в `.env.local` фронта:
```
STRAPI_URL=https://cms.xkeeper-net.stage.x-keeper.net
STRAPI_TOKEN=<token>
```

---

## 7. CORS

В `config/middlewares.ts` после бутстрапа Strapi заменить `strapi::cors` секцию на:

```ts
{
  name: 'strapi::cors',
  config: {
    origin: [
      'http://localhost:3000',
      'https://xkeeper-net.stage.x-keeper.net',
    ],
  },
},
```

---

## Что **НЕ заводим** в Phase A

| Тип | Почему откладываем | Чем заменить временно |
|---|---|---|
| `Article` / `LongRead` | Лонгриды «О компании» — в Phase B | `Page` |
| `Document` | Реестр PDF и сертификатов — в Phase B | Media-поле в Product |
| `Partner` | Лизинговые ассоциации | Заглушка в `blocks.partners` без отдельного типа |
| `Office` | Представительства — целая страница | `GlobalSettings.address` или `Page` |
| `Manager` | Менеджеры по продажам | Не нужен для MVP |
| `Lead` | Зеркало amoCRM-лидов | Формы в Phase A — заглушки |

---

## 5 страниц для демо

| Демо-страница | Тип | Slug |
|---|---|---|
| Главная | `Page` (isHome=true) | `/` |
| Для лизингодателей | `Solution` (segment=leasing) | `/solutions/leasing` |
| Invis 3D W | `Product` (series=invis) | `/products/invis-3d-w` |
| Установка и маркирование | `Service` | `/services/install` |
| Контакты | `Page` | `/contacts` |

Контент берём вручную с [x-keeper.netlify.app](https://x-keeper.netlify.app/) по карте [контент-аудита](https://x-keeper.atlassian.net/wiki/spaces/P/pages/2030272513).
