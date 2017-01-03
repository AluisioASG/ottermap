/**
 * Repeat the string a number of times.
 */
export function repeatString(s: string, amount: number): string {
  let result = ""
  for (let i = 0; i < amount; ++i) {
    result += s
  }
  return result
}


/**
 * Expand leading tab characters, replacing each of them with the given
 * amount of spaces.
 */
export function expandLeadingTabs(s: string, amount: number): string {
  return s.replace(/^(\t+)/, (match, tabs) => repeatString(" ", amount * tabs.length))
}


/**
 * Trim whitespace characters off the start of the string.
 */
export function trimStart(s: string): string {
  return s.replace(/^\s+/, "")
}


/**
 * Trim whitespace characters off the end of the string.
 */
export function trimEnd(s: string): string {
  return s.replace(/\s+$/, "")
}


/**
 * Trim whitespace off both sides of the string.
 */
export function trim(s: string): string {
 return s.trim()
}


/**
 * Trim indentation off a multiline string, as specified in Python's
 * PEP 257.
 *
 * The following paragraph, adapted from PEP 257, describes the main
 * operations performed:
 *
 * > A uniform amount of indentation is stripped from the second and further
 * > lines of the string, equal to the minimum indentation of all non-blank
 * > lines after the first line.  Any indentation in the first line of the
 * > string (i.e., up to the first newline) is insignificant and removed.
 * > Relative indentation of later lines in the string is retained.  Blank
 * > lines are removed from the beginning and end of the string.
 *
 * By default, trailing whitespace is removed from each line, leading tabs
 * are not expanded, and lines are re-joined after processing with a single
 * newline character.
 */
export function trimIndent(
  s: string,
  expandTabsBy?: number,
  joinLinesWith: string = "\n",
  trimRight: boolean = true,
): string {
  // Don't bother processing empty strings.
  if (s.trim() === "") return ""
  const lines = s.split(/\r?\n/)

  // Process the first line specially.
  const result: string[] = []
  if (expandTabsBy !== undefined) lines[0] = expandLeadingTabs(lines[0], expandTabsBy)
  result.push(trimRight ? trim(lines[0]) : trimStart(lines[0]))

  // Determine the minimum indentation, expanding tabs as we go.
  // Don't consider the first line for the computation.
  let minIndent = +Infinity
  for (let i = 1; i < lines.length; ++i) {
    if (expandTabsBy !== undefined) lines[i] = expandLeadingTabs(lines[i], expandTabsBy)
    const trimmed = trimStart(lines[i])
    if (trimmed.length > 1) {
      minIndent = Math.min(minIndent, lines[i].length - trimmed.length)
    }
  }

  // Now go and actually remove the indentation.
  for (let i = 1; i < lines.length; ++i) {
    const indented = lines[i].substr(minIndent)
    result.push(trimRight ? trimEnd(indented) : indented)
  }

  // Drop initial and final empty lines.
  while (result.length > 0 && result[0].length === 0) result.shift()
  while (result.length > 0 && result[result.length - 1].length === 0) result.pop()

  return result.join(joinLinesWith)
}
