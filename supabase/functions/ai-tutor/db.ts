import type { SupabaseClient } from "npm:@supabase/supabase-js@2.39.0";
import {
  DEFAULT_SETTINGS,
  MAX_SUMMARIES,
  MAX_TARGET_WORDS,
  type TargetWord,
  type TutorSettings,
} from "./types.ts";
import { toSettings, toSummaries, toWords } from "./normalize.ts";

export async function readSettings(
  db: SupabaseClient,
): Promise<TutorSettings> {
  const { data, error } = await db
    .from("tutor_settings")
    .select("english_level, correction_level")
    .maybeSingle();

  if (error) throw new Error(`Ayar okunamadı: ${error.message}`);

  return toSettings(data ?? DEFAULT_SETTINGS);
}

// Zayıf ve sık hata yapılan kelimeler önce gelir.
export async function readTargetWords(
  db: SupabaseClient,
): Promise<TargetWord[]> {
  const { data, error } = await db
    .from("words")
    .select("word, translation")
    .order("mastery_level", { ascending: true })
    .order("error_count", { ascending: false })
    .limit(MAX_TARGET_WORDS);

  if (error) throw new Error(`Kelimeler okunamadı: ${error.message}`);

  return toWords(data ?? []);
}

export async function readSummaries(db: SupabaseClient): Promise<string[]> {
  const { data, error } = await db
    .from("tutor_chats")
    .select("summary")
    .order("created_at", { ascending: false })
    .limit(MAX_SUMMARIES);

  if (error) throw new Error(`Özetler okunamadı: ${error.message}`);

  const rows = (data ?? []) as { summary?: unknown }[];
  return toSummaries(rows.map((row) => row.summary));
}

export async function saveSummary(
  db: SupabaseClient,
  summary: string,
): Promise<void> {
  const { error } = await db.from("tutor_chats").insert({ summary });

  if (error) throw new Error(`Özet kaydedilemedi: ${error.message}`);
}
