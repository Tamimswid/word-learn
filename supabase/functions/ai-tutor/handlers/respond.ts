import { userClient } from "../auth.ts";
import { readSettings } from "../db.ts";
import { fail, json } from "../http.ts";
import { chatJson, type LlmMessage } from "../llm.ts";
import { plainText } from "../parse.ts";
import { toCorrections, toSettings, toSummaries, toTurns, toWords } from "../normalize.ts";
import { memoryBlock, personaRules, targetWordBlock } from "../prompts/persona.ts";
import { RESPOND_TASK } from "../prompts/respond.ts";
import { MAX_MESSAGE_LENGTH } from "../types.ts";

export async function handleRespond(
  req: Request,
  body: Record<string, unknown>,
): Promise<Response> {
  const userMessage = typeof body.userMessage === "string"
    ? body.userMessage.trim()
    : "";

  if (!userMessage) return fail("userMessage zorunlu.", 400);
  if (userMessage.length > MAX_MESSAGE_LENGTH) {
    return fail("userMessage çok uzun.", 400);
  }

  const db = userClient(req);
  const settings = body.settings
    ? toSettings(body.settings)
    : await readSettings(db);

  const words = toWords(body.targetWords);
  const summaries = toSummaries(body.summaries);
  const history = toTurns(body.messages);

  const system = [
    personaRules(settings),
    targetWordBlock(words),
    memoryBlock(summaries),
    RESPOND_TASK,
  ].join("\n\n");

  const messages: LlmMessage[] = [
    { role: "system", content: system },
    ...history.map((turn) => ({ role: turn.role, content: turn.content })),
    { role: "user", content: userMessage },
  ];

  const data = await chatJson<{ reply?: unknown; corrections?: unknown }>(
    messages,
    {
      maxTokens: 700,
      // Model düz metin dönerse cevap olarak kabul et, düzeltme olmadan.
      repair: (raw) => {
        const reply = plainText(raw);
        return reply ? { reply, corrections: [] } : null;
      },
    },
  );

  const reply = typeof data.reply === "string" ? data.reply.trim() : "";
  if (!reply) throw new Error("Öğretmen cevabı üretilemedi.");

  return json({
    success: true,
    reply,
    corrections: toCorrections(data.corrections),
  });
}
