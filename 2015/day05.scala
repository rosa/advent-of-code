/* --- Day 5: Doesn't He Have Intern-Elves For This? --- */

import scala.io.Source

def readLines( filename:String ) : Iterator[String] = {
  return Source.fromFile(filename).getLines()
}

/* A nice string is one with all of the following properties:
 * It contains at least three vowels (aeiou only), like aei, xazegov, or aeiouaeiouaeiou.
 * It contains at least one letter that appears twice in a row, like xx, abcdde (dd), or aabbccdd (aa, bb, cc, or dd).
 * It does not contain the strings ab, cd, pq, or xy, even if they are part of one of the other requirements.
 */
def isNice( s:String ) : Boolean = {
  var vowels = """([aeiou].*){3}""".r
  var forbidden = """ab|cd|pq|xy""".r

  return vowels.findFirstIn(s) != None && forbidden.findFirstIn(s) == None && hasDoubleLetter(s)
}

def hasDoubleLetter( s:String ) : Boolean = {
  s.zipWithIndex.foreach{ case (char, index) =>
    if ( index < s.length() - 1 && char == s(index + 1) )
      return true
  }

  return false
}

println(readLines("inputs/input05.txt").count{ isNice })

// --- Part Two ---

/* Now, a nice string is one with all of the following properties:
 * It contains a pair of any two letters that appears at least twice in the string without overlapping,
 * like xyxy (xy) or aabcdefgaa (aa), but not like aaa (aa, but it overlaps).
 * It contains at least one letter which repeats with exactly one letter between them, like xyx, abcdefeghi (efe), or even aaa.
 */
def isNiceWithNewRules( s:String ) : Boolean = {
  return hasRepeatedPair(s) && hasDoubleLetterWithOneInBetween(s)
}

def hasRepeatedPair( s:String ) : Boolean = {
  s.zipWithIndex.foreach{ case (char, index) =>
    if ( index < s.length() - 2 && s.substring(index + 2).indexOf(s"$char${s(index + 1)}") >= 0)
      return true
  }

  return false
}

def hasDoubleLetterWithOneInBetween( s:String ) : Boolean = {
  s.zipWithIndex.foreach{ case (char, index) =>
    if ( index < s.length() - 2 && char == s(index + 2) )
      return true
  }

  return false
}

println(readLines("inputs/input05.txt").count{ isNiceWithNewRules })
