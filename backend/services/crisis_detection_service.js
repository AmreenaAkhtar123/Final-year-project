
const HIGH_RISK_PATTERNS = [
  /\b(?:i want to die|i wish i were dead|i wish i was dead)\b/i,
  /\b(?:i want to kill myself|i am going to kill myself|i'm going to kill myself)\b/i,
  /\b(?:i want to end my life|i plan to end my life|i am planning to end my life)\b/i,
  /\b(?:i am suicidal|i'm suicidal|i am thinking about suicide)\b/i,
  /\b(?:i have a suicide plan|i made a suicide plan|i have a plan to kill myself)\b/i,
  /\b(?:i will kill myself|i will end my life|i intend to kill myself)\b/i,
  /\b(?:i am going to hurt myself|i'm going to hurt myself|i plan to hurt myself)\b/i,
];

const MEDIUM_RISK_PATTERNS = [
  /\b(?:i don't want to live|i do not want to live)\b/i,
  /\b(?:i cannot go on|i can't go on|i cannot keep going|i can't keep going)\b/i,
  /\b(?:there is no reason to live|there's no reason to live)\b/i,
  /\b(?:everyone would be better off without me)\b/i,
  /\b(?:i wish i could disappear forever)\b/i,
  /\b(?:i feel like giving up on life)\b/i,
  /\b(?:i keep thinking about suicide)\b/i,
  /\b(?:i have been feeling hopeless|i've been feeling hopeless|i feel hopeless|i have lost all hope)\b/i,
];

const NEGATION_PATTERNS = [
  /\b(?:i am not suicidal|i'm not suicidal)\b/i,
  /\b(?:i do not want to die|i don't want to die)\b/i,
  /\b(?:i do not want to kill myself|i don't want to kill myself)\b/i,
  /\b(?:i do not want to hurt myself|i don't want to hurt myself)\b/i,
  /\b(?:i am not thinking about suicide|i'm not thinking about suicide)\b/i,
];

const THIRD_PARTY_PATTERNS = [
  /\b(?:my friend|my brother|my sister|my parent|my mother|my father|someone i know)\b[\s\S]{0,100}\b(?:wants to die|want to die|wants to kill himself|wants to kill herself|is suicidal|plans to end (?:his|her|their) life)\b/i,
  /\b(?:my friend|my brother|my sister|someone i know)\b[\s\S]{0,100}\b(?:said|texted|told me|wrote)\b[\s\S]{0,100}\b(?:kill myself|end my life|want to die|suicide)\b/i,
];

const FICTIONAL_CONTEXT_PATTERNS = [
  /\b(?:in the movie|in the film|in the tv show|in the series|in the novel|in the book)\b/i,
  /\b(?:the character|the actor|the actress|the fictional person)\b/i,
  /\b(?:a movie quote|a film quote|a fictional scene)\b/i,
];

function normalizeText(text) {
  return text.toLowerCase().replace(/\s+/g, ' ').trim();
}

function splitIntoClauses(text) {
  return text.split(/(?<=[.!?;])\s+|\s+\bbut\b\s+/i);
}

function detectCrisis(text) {
  if (typeof text !== 'string' || !text.trim()) {
    return {
      detected: false,
      riskLevel: 'none',
      subject: 'self',
      reason: 'empty_or_invalid_input',
    };
  }

  const normalizedText = normalizeText(text);
  const clauses = splitIntoClauses(normalizedText);

  const thirdPartyConcern = THIRD_PARTY_PATTERNS.some((pattern) =>
    pattern.test(normalizedText),
  );

  let highRiskDetected = false;
  let mediumRiskDetected = false;

  for (const clause of clauses) {
    const fictionalContext = FICTIONAL_CONTEXT_PATTERNS.some((pattern) =>
      pattern.test(clause),
    );

    // Ignore a clause clearly describing fictional dialogue.
    // Other clauses in the same message are still evaluated.
    if (fictionalContext) {
      continue;
    }

    const isNegated = NEGATION_PATTERNS.some((pattern) =>
      pattern.test(clause),
    );

    if (isNegated) {
      continue;
    }

    if (HIGH_RISK_PATTERNS.some((pattern) => pattern.test(clause))) {
      highRiskDetected = true;
      continue;
    }

    if (MEDIUM_RISK_PATTERNS.some((pattern) => pattern.test(clause))) {
      mediumRiskDetected = true;
    }
  }

  if (highRiskDetected) {
    return {
      detected: true,
      riskLevel: 'high',
      subject: 'self',
      reason: 'high_risk_statement',
      thirdPartyConcern,
    };
  }

  if (mediumRiskDetected) {
    return {
      detected: true,
      riskLevel: 'medium',
      subject: 'self',
      reason: 'possible_crisis_statement',
      thirdPartyConcern,
    };
  }

  if (thirdPartyConcern) {
    return {
      detected: true,
      riskLevel: 'high',
      subject: 'someone_else',
      reason: 'third_party_crisis_statement',
    };
  }

  return {
    detected: false,
    riskLevel: 'none',
    subject: 'self',
    reason: 'no_matching_crisis_indicators',
  };
}

export { detectCrisis };
