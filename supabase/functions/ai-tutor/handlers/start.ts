import { userClient } from "../auth.ts";
import { readSettings, readSummaries, readTargetWords } from "../db.ts";
import { json } from "../http.ts";
import { chatJson } from "../llm.ts";
import { plainText } from "../parse.ts";
import { memoryBlock, personaRules, targetWordBlock } from "../prompts/persona.ts";
import { START_TASK } from "../prompts/start.ts";

export async function handleStart(req: Request): Promise<Response> {
  const db = userClient(req);

  const [settings, words, summaries] = await Promise.all([
    readSettings(db),
    readTargetWords(db),
    readSummaries(db),
  ]);

  const system = [
    personaRules(settings),
    targetWordBlock(words),
    memoryBlock(summaries),
    START_TASK,
  ].join("\n\n");

  const data = await chatJson<{ reply?: unknown }>(
    [
      { role: "system", content: system },
      { role: "user", content: "Start the lesson now." },
    ],
    {
      maxTokens: 400,
      repair: (raw) => {
        const reply = plainText(raw);
        return reply ? { reply } : null;
      },
    },
  );

  const reply = typeof data.reply === "string" ? data.reply.trim() : "";
  if (!reply) throw new Error("Açılış mesajı üretilemedi.");

  return json({
    success: true,
    reply,
    session: { settings, targetWords: words, summaries },
  });
}
