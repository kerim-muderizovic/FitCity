# FitCity

## Stripe Payments (Test Mode)

### Why this flow
Payments are confirmed **only** by Stripe webhooks. The app does **not** activate memberships or mark bookings as paid on the client redirect. This prevents fake “success” redirects from granting access without a real payment.

### Required env vars
Set these values (see `.env.example`):
- `STRIPE_SECRET_KEY`
- `STRIPE_PUBLISHABLE_KEY`
- `STRIPE_WEBHOOK_SECRET`
- `STRIPE_CURRENCY` (default: `eur`)
- `STRIPE_SUCCESS_URL` (default: `http://localhost:8081/payments/stripe/success`)
- `STRIPE_CANCEL_URL` (default: `http://localhost:8081/payments/stripe/cancel`)
- `ALLOW_FAKE_PAYMENTS` (optional, default `false`)

### Local setup
1. Set env vars (see `.env.example`) and ensure they are loaded by Docker.
2. Start backend:

```bash
docker compose up -d --build
```

3. Run Stripe CLI to forward webhooks:

```bash
stripe login
stripe listen --forward-to localhost:8081/api/webhooks/stripe
```

4. Use Stripe test card:

```text
4242 4242 4242 4242
```

### How it works
- The app creates a Stripe Checkout session.
- The user pays in the browser.
- Stripe sends `checkout.session.completed` to `/api/webhooks/stripe`.
- The backend validates the signature and **then**:
  - creates the membership / marks booking paid
  - writes a Payment record with Stripe IDs
  - writes a PaymentAudit entry

### Manual (fake) payments for school/demo
If Stripe is not configured, users can choose **“Mark as paid (local)”** in the app.  
This calls a backend endpoint that immediately marks the membership/booking as paid.

Enable by setting:
```
ALLOW_FAKE_PAYMENTS=true
```

This is intended **only** for demo/school use.

### Troubleshooting
- If payment stays “Waiting for confirmation”, make sure the Stripe CLI is running.
- If webhook fails: check the `STRIPE_WEBHOOK_SECRET` from Stripe CLI output.
- If checkout doesn’t open: verify the app can launch external browser and the URL is not empty.
