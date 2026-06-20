# Part Sourcing API — querying Digi-Key & Mouser with curl

This is a practical guide to finding parts, checking live stock, and pricing a
BOM for a new design by hitting the InventoryStore HTTP API with `curl`.

You talk to **your own running app**, not to Digi-Key/Mouser directly — the app
holds the API credentials and does the Digi-Key OAuth token dance for you, so
the requests below are plain JSON with no auth headers. (If you ever want to
call Digi-Key's API straight, see the [appendix](#appendix-calling-the-digi-key-api-directly).)

> The app must be running (`go run .` or the `inventorystore` service). The JSON
> API is served over plain HTTP on port **80** and needs no login — it's a
> LAN tool.

## Setup

Pick the host the app runs on and stash it in a shell variable so you can
copy-paste the examples:

```bash
BASE=http://localhost          # or e.g. http://192.168.1.50 on the LAN
```

Most examples pipe through [`jq`](https://jqlang.github.io/jq/) for readable
output. It's optional — drop the `| jq …` to see raw JSON.

> **Live data needs `DIGIKEY_ENV=PRODUCTION` in `.env`.** In `SANDBOX` mode
> Digi-Key returns placeholder catalog/stock data. Mouser endpoints need a valid
> **Search API** key in `MOUSER_API_KEY`; until then `/api/mouser/search` and the
> Mouser half of `/api/stock/check` return an error row, while Digi-Key keeps
> working.

---

## The new-design workflow

You're designing something, you have a rough BOM (manufacturer part numbers, or
specs you want to match), and you want to know **what to buy and whether it's in
stock**. The path:

1. **Find candidate parts** on Digi-Key by spec/keyword → `/api/digikey/search`
2. **Confirm it's purchasable** (stock at Digi-Key *and* Mouser) → `/api/stock/check`
3. **Check if you already have it** in inventory → `/api/parts/search`
4. **Pull it into inventory** when you commit to it → `/api/parts/create-from-mpn`

### 1. Find a part by keyword / spec

`GET /api/digikey/search?q=<keywords>&limit=<n>` searches the live Digi-Key
catalog. Great for "I need a 10k 0402 1% resistor" — pass the spec as keywords.

```bash
curl -s "$BASE/api/digikey/search?q=10k%200402%201%25%200.1W&limit=5" | jq .
```

```jsonc
[
  {
    "mpn": "RC0402FR-0710KL",
    "manufacturer": "YAGEO",
    "description": "RES SMD 10K OHM 1% 1/16W 0402",
    "category": "Chip Resistor - Surface Mount",
    "datasheet_url": "https://www.yageo.com/...pdf",
    "photo_url": "https://...jpg",
    "product_url": "https://www.digikey.com/...",
    "unit_price": 0.01,
    "digikey_stock": 458291,     // quantity available on Digi-Key right now
    "digikey_pn": "311-10.0KLRCT-ND",
    "status": "Active",
    "parameters": [
      { "name": "Resistance", "value": "10 kOhms" },
      { "name": "Tolerance",  "value": "±1%" },
      { "name": "Power (Watts)", "value": "0.063W, 1/16W" }
    ]
  }
]
```

URL-encode the query (`%20` = space, `%25` = `%`), or let curl do it with `-G`:

```bash
curl -s -G "$BASE/api/digikey/search" \
  --data-urlencode "q=0.1uF 16V X7R 0402" \
  --data-urlencode "limit=5" | jq -r '.[] | "\(.mpn)\t\(.digikey_stock)\t\(.description)"'
```

The same thing against Mouser (identical shape, `mouser_stock` / `mouser_pn`):

```bash
curl -s -G "$BASE/api/mouser/search" --data-urlencode "q=LM358 SOIC" --data-urlencode "limit=5" | jq .
```

### 2. Confirm a part is in stock (Digi-Key + Mouser)

`/api/stock/check` queries **every configured distributor at once** and rolls up
the answer. Pass `required=<qty>` to ask "can I buy this many from one supplier?"

```bash
curl -s -G "$BASE/api/stock/check" \
  --data-urlencode "mpn=RC0402FR-0710KL" \
  --data-urlencode "required=500" | jq .
```

```jsonc
{
  "required": 500,
  "all_available": true,          // true only if EVERY requested mpn is buyable
  "results": [
    {
      "mpn": "RC0402FR-0710KL",
      "required": 500,
      "total_stock": 712030,      // summed across suppliers
      "best_stock": 458291,       // most from any single supplier
      "available": true,          // best_stock >= required
      "suppliers": [
        { "supplier": "DigiKey", "supplier_pn": "311-10.0KLRCT-ND",
          "mpn": "RC0402FR-0710KL", "manufacturer": "YAGEO",
          "stock": 458291, "in_stock": true, "unit_price": 0.01,
          "product_url": "https://www.digikey.com/...", "status": "Active" },
        { "supplier": "Mouser", "supplier_pn": "603-RC0402FR-0710KL",
          "stock": 253739, "in_stock": true, "unit_price": 0.01,
          "status": "253739 In Stock" }
      ]
    }
  ]
}
```

If a supplier can't find the part or errors (e.g. bad Mouser key), its row
carries an `"error"` field instead of stock — the other supplier's answer still
comes through.

### 3. Check what you already have on the shelf

Before buying, see if it's already in inventory. `GET /api/parts/search?q=` runs
the same fuzzy spec/keyword search the web UI uses, over your local parts:

```bash
curl -s -G "$BASE/api/parts/search" --data-urlencode "q=10k 0402" | jq -r \
  '.[] | "\(.name)\tstock=\(.total_stock)\t@\(.primary_location_name)"'
```

```jsonc
[
  {
    "id": 142,
    "name": "RC0402FR-0710KL",
    "description": "RES SMD 10K OHM 1% 1/16W 0402",
    "photo_url": "https://...jpg",
    "primary_location_name": "Cab A • Drawer 3",
    "total_stock": 1840,
    "all_locations": "Cab A • Drawer 3",
    "archived": false
  }
]
```

### 4. Pull the part into inventory

Once you commit to a part, create it from its MPN. The app fetches full details
(description, datasheet, photo, parameters, supplier part numbers + price breaks)
from Digi-Key — and **falls back to Mouser** if Digi-Key has no match.

```bash
curl -s -X POST "$BASE/api/parts/create-from-mpn" \
  -H "Content-Type: application/json" \
  -d '{"mpn":"RC0402FR-0710KL"}' | jq .
```

Force a specific distributor with `"supplier"` (`"mouser"` or `"digikey"`):

```bash
curl -s -X POST "$BASE/api/parts/create-from-mpn" \
  -H "Content-Type: application/json" \
  -d '{"mpn":"RC0402FR-0710KL","supplier":"mouser"}' | jq .
```

```jsonc
{
  "id": 142,
  "name": "RC0402FR-0710KL",
  "description": "RES SMD 10K OHM 1% 1/16W 0402",
  "category": "Chip Resistor - Surface Mount",
  "datasheet_url": "https://...pdf",
  "photo_url": "https://...jpg",
  "parameters": [ { "name": "Resistance", "value": "10 kOhms" }, … ],
  "supplier_part_numbers": [
    { "supplier": "DigiKey", "part_number": "311-10.0KLRCT-ND" }
  ]
}
```

This only adds the **part** to the catalog — it doesn't add physical stock. To
record stock on a shelf, use [`/api/stock/add-by-mpn`](#post-apistockadd-by-mpn).

---

## Pricing a whole BOM in one shot

`/api/stock/check` accepts a **list** of MPNs via POST — ideal for a new design's
BOM. It tells you, for every line, whether you can buy your target quantity.

```bash
curl -s -X POST "$BASE/api/stock/check" \
  -H "Content-Type: application/json" \
  -d '{
        "required": 100,
        "mpns": [
          "RC0402FR-0710KL",
          "GRM188R71H104KA93D",
          "LM358DR",
          "SOME-OBSOLETE-PART"
        ]
      }' | jq '{all_available, short: [.results[] | select(.available==false) | .mpn]}'
```

```json
{
  "all_available": false,
  "short": [ "SOME-OBSOLETE-PART" ]
}
```

`all_available` is your go/no-go for the build; `short` is the list of lines you
can't source at qty 100 from any single distributor.

### From a BOM file

If your BOM MPNs are one-per-line in a file, build the request with `jq`:

```bash
# mpns.txt: one manufacturer part number per line
jq -Rn --argjson req 100 '{required:$req, mpns:[inputs | select(length>0)]}' mpns.txt \
  | curl -s -X POST "$BASE/api/stock/check" -H "Content-Type: application/json" -d @- \
  | jq -r '.results[] | "\(.available|if . then "OK " else "SHORT" end)\t\(.best_stock)\t\(.mpn)"'
```

```
OK 	458291	RC0402FR-0710KL
OK 	120544	GRM188R71H104KA93D
OK 	88210	LM358DR
SHORT	0	SOME-OBSOLETE-PART
```

You can also `GET` a few MPNs inline with repeated `mpn=` params or a comma list:

```bash
curl -s "$BASE/api/stock/check?mpn=LM358DR&mpn=RC0402FR-0710KL&required=10" | jq .all_available
curl -s "$BASE/api/stock/check?mpns=LM358DR,RC0402FR-0710KL" | jq .all_available
```

---

## Endpoint reference

Base URL is your app host (`$BASE`). All responses are JSON.

| Method | Path | Purpose |
| --- | --- | --- |
| `GET` | `/api/digikey/search?q=&limit=` | Search the live Digi-Key catalog by keyword/spec. |
| `GET` | `/api/mouser/search?q=&limit=` | Search the live Mouser catalog (needs a Search API key). |
| `GET`/`POST` | `/api/stock/check` | Confirm live stock for one or many MPNs across Digi-Key + Mouser. |
| `GET` | `/api/parts/search?q=` | Fuzzy search **your** inventory (name, description, R/C/V values). |
| `POST` | `/api/parts/create-from-mpn` | Add a part to the catalog from its MPN (Digi-Key, fallback Mouser). |
| `POST` | `/api/parts/create-manual` | Add a part with no distributor lookup. |
| `POST` | `/api/stock/add-by-mpn` | Record physical stock at a location (optionally auto-fetching the part). |
| `GET` | `/api/parts/unassigned` | List parts still in the "Unassigned" category. |
| `GET` | `/api/locations` | List storage locations (and `POST /api/locations/add` to create one). |

Common parameters:

- **`q`** — keyword/spec string (URL-encode, or use `curl -G --data-urlencode`).
- **`limit`** — max results, default 5, capped at 50 (search endpoints).
- **`required`** — desired quantity for `/api/stock/check`; a line is `available`
  when one supplier has at least this many. Omit (or 0) to mean "any stock > 0".
- **`mpn` / `mpns`** — single, repeated, or comma-separated part numbers
  (`/api/stock/check`, GET form); or a JSON `"mpns": [...]` array (POST form).

### POST `/api/parts/create-manual`

For a part Digi-Key/Mouser won't have (custom, mechanical, internal):

```bash
curl -s -X POST "$BASE/api/parts/create-manual" -H "Content-Type: application/json" \
  -d '{"name":"BRKT-LID-V2","description":"Laser-cut lid bracket","category_name":"Mechanical"}' | jq .
```

### POST `/api/stock/add-by-mpn`

Records physical stock at a location. With `"fetch_data": true` (the default) it
will create/enrich the part from Digi-Key/Mouser first; set it `false` to skip
the lookup and use the `description`/`category_name` you pass.

```bash
curl -s -X POST "$BASE/api/stock/add-by-mpn" -H "Content-Type: application/json" \
  -d '{
        "mpn": "RC0402FR-0710KL",
        "quantity": 5000,
        "location_name": "Cab A • Drawer 3",
        "fetch_data": true
      }' | jq .
```

Required fields: `mpn`, `quantity` (>0), `location_name`. Returns the created
stock row.

---

## Appendix: calling the Digi-Key API directly

If you'd rather hit Digi-Key without the app (e.g. from a script on another
machine), you need a Digi-Key API app (Client ID/Secret) and the OAuth
client-credentials flow. Use `https://api.digikey.com` for production data or
`https://sandbox-api.digikey.com` for the sandbox.

**1. Get a bearer token** (valid ~30 min):

```bash
TOKEN=$(curl -s -X POST "https://api.digikey.com/v1/oauth2/token" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "client_id=$DIGIKEY_CLIENT_ID" \
  -d "client_secret=$DIGIKEY_CLIENT_SECRET" \
  -d "grant_type=client_credentials" | jq -r .access_token)
```

**2. Product details** for an exact part number:

```bash
curl -s "https://api.digikey.com/products/v4/search/RC0402FR-0710KL/productdetails" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-DIGIKEY-Client-Id: $DIGIKEY_CLIENT_ID" \
  -H "X-DIGIKEY-Locale-Site: US" \
  -H "X-DIGIKEY-Locale-Language: en" \
  -H "X-DIGIKEY-Locale-Currency: USD" \
  -H "Accept: application/json" | jq '.Product | {mpn:.ManufacturerProductNumber, stock:.QuantityAvailable, price:.UnitPrice}'
```

**3. Keyword search:**

```bash
curl -s -X POST "https://api.digikey.com/products/v4/search/keyword" \
  -H "Authorization: Bearer $TOKEN" \
  -H "X-DIGIKEY-Client-Id: $DIGIKEY_CLIENT_ID" \
  -H "X-DIGIKEY-Locale-Site: US" -H "X-DIGIKEY-Locale-Language: en" -H "X-DIGIKEY-Locale-Currency: USD" \
  -H "Content-Type: application/json" \
  -d '{"Keywords":"10k 0402 1%","Limit":5,"Offset":0}' \
  | jq '.Products[] | {mpn:.ManufacturerProductNumber, stock:.QuantityAvailable}'
```

Mouser's API (once you have a Search API key) is simpler — an API key in the
query string, no OAuth:

```bash
curl -s -X POST "https://api.mouser.com/api/v1/search/partnumber?apiKey=$MOUSER_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"SearchByPartRequest":{"mouserPartNumber":"RC0402FR-0710KL","partSearchOptions":""}}' \
  | jq '.SearchResults.Parts[] | {mpn:.ManufacturerPartNumber, stock:.AvailabilityInStock}'
```

The app wraps all of the above so you don't have to manage tokens or vendor
response shapes — prefer the `/api/...` endpoints unless you specifically need
to go around it.
