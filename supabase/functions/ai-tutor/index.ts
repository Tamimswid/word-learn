import { handleEnd } from "./handlers/end.ts";
import { handleRespond } from "./handlers/respond.ts";
import { handleStart } from "./handlers/start.ts";
import { corsHeaders, fail } from "./http.ts";

type Body = Record<string, unknown>;
type Handler = (req: Request, body: Body) => Promise<Response>;

const handlers: Record<string, Handler> = {
  start: (req) => handleStart(req),
  respond: handleRespond,
  end: handleEnd,
};

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return fail("Yalnızca POST desteklenir.", 405);
  }

  try {
    const body = (await req.json().catch(() => ({}))) as Body;
    const action = typeof body.action === "string" ? body.action : "";
    const handler = handlers[action];

    if (!handler) {
      return fail(`Geçersiz action: ${action || "(boş)"}`, 400);
    }

    return await handler(req, body);
  } catch (error) {
    const message = error instanceof Error
      ? error.message
      : "Bilinmeyen sunucu hatası.";
    return fail(message, 500);
  }
});
