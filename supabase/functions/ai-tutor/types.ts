export type EnglishLevel = "A1" | "A2" | "B1" | "B2" | "C1" | "C2";
export type CorrectionLevel = "low" | "medium" | "high";

export interface TutorSettings {
  english_level: EnglishLevel;
  correction_level: CorrectionLevel;
}

export interface TargetWord {
  word: string;
  translation: string;
}

export interface ChatTurn {
  role: "user" | "assistant";
  content: string;
}

export interface Correction {
  original: string;
  corrected: string;
  suggestion: string;
  explanation: string;
}

export interface TutorReply {
  reply: string;
  corrections: Correction[];
}

export const DEFAULT_SETTINGS: TutorSettings = {
  english_level: "B1",
  correction_level: "medium",
};

export const MAX_HISTORY_TURNS = 8;
export const MAX_TARGET_WORDS = 5;
export const MAX_SUMMARIES = 2;
export const MAX_MESSAGE_LENGTH = 1200;
