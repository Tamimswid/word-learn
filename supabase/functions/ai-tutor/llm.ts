import { tryExtractJson } from "./parse.ts";

const DEFAULT_MODEL = "@cf/meta/llama-3.3-70b-instruct-fp8-fast";

export interface LlmMessage {
  role: "system" | "user" | "assistant";
  content: string;
}

interface CloudflareConfig {
  accountId: string;
  authToken: string;
  model: string;
}

export interface ChatJsonOptions<T> {
  maxTokens?: number;
  // Model JSON yazmayı tamamen reddederse düz metinden sonuç üretir.
  repair?: (rawText: string) => T | null;
}

// Secret eklendikten sonra deploy edilmeden de görülsün diye her çağrıda okunur.
function config(): CloudflareConfig {
  return {
    accountId: Deno.env.get("CLOUDFLARE_ACCOUNT_ID") ?? "",
    authToken: Deno.env.get("CLOUDFLARE_AUTH_TOKEN") ?? "",
    model: Deno.env.get("AI_MODEL") ?? DEFAULT_MODEL,
  };
}

async function callModel(
  messages: LlmMessage[],
  maxTokens: number,
  cfg: CloudflareConfig,
): Promise<string> {
  const url =
    `https://api.cloudflare.com/client/v4/accounts/${cfg.accountId}/ai/run/${cfg.model}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${cfg.authToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      messages,
      temperature: 0.4,
      max_tokens: maxTokens,
    }),
  });

  if (!response.ok) {
    throw new Error(
      `Cloudflare HTTP ${response.status}: ${await response.text()}`,
    );
  }

  const payload = await response.json();
  if (!payload?.success) {
    throw new Error(`Cloudflare AI: ${JSON.stringify(payload?.errors)}`);
  }

  const raw = payload.result?.response;
  if (raw && typeof raw === "object") return JSON.stringify(raw);

  return String(raw ?? "");
}

// Model düz metin döndürürse ikinci denemeye eklenen sert hatırlatma.
const JSON_NUDGE =
  "SYSTEM NOTICE: your previous answer was plain text, not JSON. " +
  "Answer again with ONLY one JSON object matching the required shape. " +
  "First character: { — last character: } — no other text before or after.";

export async function chatJson<T>(
  messages: LlmMessage[],
  options: ChatJsonOptions<T> = {},
): Promise<T> {
  const cfg = config();

  if (!cfg.accountId || !cfg.authToken) {
    // Değer yazdırmadan, yalnızca benzer ada sahip anahtarları raporla.
    const similar = Object.keys(Deno.env.toObject()).filter((key) =>
      /cloudflare|cf_|^ai_/i.test(key)
    );
    throw new Error(
      "Cloudflare kimlik bilgileri tanımlı değil." +
        ` (CLOUDFLARE_ACCOUNT_ID=${cfg.accountId ? "var" : "yok"},` +
        ` CLOUDFLARE_AUTH_TOKEN=${cfg.authToken ? "var" : "yok"};` +
        ` benzer anahtarlar: ${similar.join(", ") || "yok"})`,
    );
  }

  const maxTokens = options.maxTokens ?? 700;
  let request = messages;
  let lastError: unknown = null;
  let lastRaw = "";

  for (let attempt = 0; attempt < 2; attempt += 1) {
    try {
      const raw = await callModel(request, maxTokens, cfg);
      const parsed = tryExtractJson(raw);
      if (parsed !== null) return parsed as T;

      lastRaw = raw;
      lastError = new Error(`AI çıktısı JSON değil: ${raw.slice(0, 200)}`);
      // Aynı istek tekrar aynı sonucu verir; sert hatırlatma ekle.
      request = [...messages, { role: "user", content: JSON_NUDGE }];
    } catch (error) {
      lastError = error;
    }
  }

  // JSON alınamadıysa düz metin tamir edilebilir mi diye bak.
  const repaired = options.repair?.(lastRaw) ?? null;
  if (repaired !== null) return repaired;

  throw lastError instanceof Error
    ? lastError
    : new Error(String(lastError));
}
